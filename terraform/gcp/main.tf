##################################################################
locals {
  config = jsondecode(file("${path.module}/../config.json"))

  fixed_region_map = {
    gcp = "europe-west3"
  }

  region = local.fixed_region_map["gcp"]

  db_password = "password"
  db_username = "user"

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
  db_pass           = local.db_password
  db_username       = local.db_username

  depends_on = [module.network]
}
##################################################################
module "static_ips" {
  source     = "./modules/static_ips"
  static_ips = local.config.static_ips
}
##################################################################
module "cloudflare_dns" {
  source               = "../shared_modules/cloudflare_dns"
  cloudflare_zone_id   = var.cloudflare_zone_id
  dns_records_config   = local.config.dns_records
  resource_dns_map     = module.static_ips.ip_addresses
  cloudflare_api_token = var.cloudflare_api_token
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