##################################################################
data "google_secret_manager_secret_version" "db_username" {
  secret  = local.config.project.secret_name_db_username
  project = local.config.project.name
  version = "latest"
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = local.config.project.secret_name_db_pass
  project = local.config.project.name
  version = "latest"
}
##################################################################
locals {
  config = jsondecode(file("${path.module}/../schedule-config/config.json"))

  fixed_region_map = {
    gcp = "europe-west3"
  }

  region = local.fixed_region_map["gcp"]

  ssh_keys              = local.config.project.keys
  service_account_email = local.config.project.service_account_email

  primary_gke_key = keys(module.gke_cluster.cluster_endpoints)[0]
}
##################################################################
module "network" {
  source            = "./modules/network"
  project_id        = local.config.project.name
  region            = local.region
  networks          = local.config.network
  acls              = local.config.network[0].subnets
  security_groups   = local.config.security_groups
  health_check_port = var.health_check_port
}
##################################################################
module "db-instance" {
  source            = "./modules/db-instance"
  project_id        = local.config.project.name
  region            = local.region
  databases         = local.config.databases
  private_networks  = module.network.vpc_self_links
  subnet_self_links = module.network.subnet_self_links_by_name
  db_username       = data.google_secret_manager_secret_version.db_username.secret_data
  db_pass           = data.google_secret_manager_secret_version.db_password.secret_data

  depends_on = [module.network]
}
##################################################################
module "vm" {
  source                = "./modules/vm"
  project_id            = local.config.project.name
  region                = local.region
  project_os            = local.config.project.os
  vm_instances          = local.config.vm_instances
  subnet_self_links_map = module.network.subnet_self_links_by_name
  ssh_keys              = local.ssh_keys
  service_account_email = local.service_account_email

  depends_on = [module.network]
}
##################################################################
module "static_ips" {
  source     = "./modules/static_ips"
  static_ips = local.config.static_ips
}
##################################################################
module "cloudflare_dns" {
  source               = "git@github.com:DolVladzio/cloudflare_dns.git?ref=main"
  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_api_token = var.cloudflare_api_token
  dns_records_config   = local.config.dns_records
  resource_dns_map     = module.static_ips.ip_addresses
}
##################################################################
module "gke_cluster" {
  source                = "./modules/gke_cluster"
  clusters              = local.config.gke_clusters
  vpc_self_links        = module.network.vpc_self_links
  subnet_self_links     = module.network.subnet_self_links_by_name
  service_account_email = local.config.project.service_account_email

  depends_on = [module.network]
}
##################################################################
module "cloud_monitoring" {
  source            = "./modules/cloud_monitoring"
  monitoring_config = local.config.monitoring

  depends_on = [module.gke_cluster]
}
##################################################################