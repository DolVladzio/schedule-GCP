##################################################################
locals {
  acls_map = { for a in var.acls : a.name => a.cidr }

  vpcs_map = { for vpc in var.networks : vpc.name[var.environment] => vpc }
  psa_ranges_map = {
    for net in var.networks :
    net.name[var.environment] => {
      name                    = "psa-range-${net.name[var.environment]}"
      cidr                    = "${net.psa_range}"
      ip_version              = net.ip_version
      prefix_length           = net.prefix_length
      address_type            = net.address_type
      purpose                 = net.purpose
      service                 = net.service
      update_on_creation_fail = net.update_on_creation_fail
      deletion_policy         = net.deletion_policy
    }
  }

  sg_to_instances_map = { for sg in var.security_groups : sg.name => sg.attach_to }
}
##################################################################
resource "google_compute_network" "vpc" {
  for_each                = local.vpcs_map
  name                    = each.key
  auto_create_subnetworks = false
}
##################################################################
resource "google_compute_subnetwork" "subnet" {
  for_each = {
    for subnet in flatten([
      for network in var.networks : [
        for subnet in network.subnets : {
          key                  = "${network.name[var.environment]}-${subnet.name}"
          network_name         = network.name
          subnet_data          = subnet
          aggregation_interval = network.aggregation_interval
          flow_sampling        = network.flow_sampling
          metadata             = network.metadata
        }
      ]
    ]) : subnet.key => subnet
  }

  name          = each.value.subnet_data.name
  ip_cidr_range = each.value.subnet_data.cidr
  region        = var.region
  network       = google_compute_network.vpc[each.value.network_name[var.environment]].id

  log_config {
    aggregation_interval = each.value.aggregation_interval
    flow_sampling        = each.value.flow_sampling
    metadata             = each.value.metadata
  }

  depends_on = [google_compute_network.vpc]
}
##################################################################
resource "google_compute_firewall" "ingress" {
  for_each = {
    for sg in var.security_groups : sg.name => sg
    if length(sg.ingress) > 0
  }

  name        = each.value.name
  network     = google_compute_network.vpc[each.value.vpc[var.environment]].self_link
  target_tags = each.value.attach_to

  dynamic "allow" {
    for_each = each.value.ingress
    content {
      protocol = allow.value.protocol
      ports    = [tostring(allow.value.port)]
    }
  }

  depends_on = [google_compute_network.vpc]

  source_ranges = distinct(flatten([
    for rule in each.value.ingress :
    contains(keys(local.acls_map), rule.source) ? [local.acls_map[rule.source]] : ["0.0.0.0/0"]
    if !contains(keys(local.sg_to_instances_map), rule.source)
  ]))

  source_tags = distinct(flatten([
    for rule in each.value.ingress :
    contains(keys(local.sg_to_instances_map), rule.source) ? local.sg_to_instances_map[rule.source] : []
  ]))
}
##################################################################
resource "google_compute_router" "nat_router" {
  for_each = google_compute_network.vpc

  name    = "${each.key}-nat-router"
  network = each.value.self_link
  region  = var.region

  depends_on = [google_compute_network.vpc]
}
##################################################################
resource "google_compute_router_nat" "cloud_nat" {
  for_each = local.vpcs_map

  name   = "${each.key}-nat"
  router = google_compute_router.nat_router[each.key].name
  region = var.region

  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat

  depends_on = [google_compute_network.vpc]
}
##################################################################
resource "google_compute_global_address" "default" {
  for_each = local.psa_ranges_map

  name          = each.value.name
  project       = var.project_id
  provider      = google-beta
  ip_version    = each.value.ip_version
  prefix_length = each.value.prefix_length
  address_type  = each.value.address_type
  purpose       = each.value.purpose
  network       = google_compute_network.vpc[each.key].self_link

  depends_on = [google_compute_network.vpc]
}
##################################################################
resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = local.psa_ranges_map

  provider                = google-beta
  network                 = google_compute_network.vpc[each.key].self_link
  service                 = each.value.service
  reserved_peering_ranges = [google_compute_global_address.default[each.key].name]
  update_on_creation_fail = each.value.update_on_creation_fail

  deletion_policy = each.value.deletion_policy

  depends_on = [google_compute_network.vpc]
}
##################################################################