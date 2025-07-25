##################################################################
locals {
  cluster_node_pools = flatten([
    for cluster_key, cluster in var.clusters : [
      for pool in cluster.node_pools : merge(
        pool,
        {
          cluster_key      = cluster_key
          cluster_name     = cluster.name[var.environment]
          cluster_location = cluster.location[var.environment]
          pool_key         = "${cluster_key}-${pool.name}"
        }
      )
    ]
  ])

  node_pools_map = {
    for pool in local.cluster_node_pools : pool.pool_key => pool
  }
}
##################################################################
resource "google_container_cluster" "gke" {
  for_each = var.clusters
  name     = each.value.name[var.environment]
  location = each.value.location[var.environment]

  deletion_protection = each.value.deletion_protection

  initial_node_count       = each.value.initial_node_count[var.environment]
  remove_default_node_pool = each.value.remove_default_node_pool

  network    = var.vpc_self_links[each.value.network[var.environment]]
  subnetwork = var.subnet_self_links[each.value.subnetwork[var.environment]]

  node_config {
    service_account = var.service_account_email
  }

  dynamic "private_cluster_config" {
    for_each = each.value.private_cluster ? [1] : []
    content {
      enable_private_nodes    = each.value.enable_private_nodes
      enable_private_endpoint = each.value.enable_private_endpoint
    }
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = each.value.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  ip_allocation_policy {}
}
##################################################################
resource "google_container_node_pool" "custom_node_pools" {
  for_each = local.node_pools_map
  name     = each.value.name
  location = each.value.cluster_location
  cluster  = google_container_cluster.gke[each.value.cluster_key].name

  node_config {
    service_account = var.service_account_email
    machine_type    = each.value.machine_type[var.environment]
    image_type      = each.value.image_type
    disk_size_gb    = lookup(each.value, "disk_size_gb", 20)
    oauth_scopes = lookup(each.value, "oauth_scopes", [
      "https://www.googleapis.com/auth/cloud-platform"
    ])
    workload_metadata_config {
      mode = each.value.workload_metadata_config
    }
  }

  autoscaling {
    min_node_count = each.value.min_node_count[var.environment]
    max_node_count = each.value.max_node_count[var.environment]
  }

  management {
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
    auto_repair  = lookup(each.value, "auto_repair", true)
  }

  depends_on = [google_container_cluster.gke]
}
##################################################################