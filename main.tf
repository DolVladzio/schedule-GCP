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
  config = jsondecode(file("${path.module}/../schedule-terraform-config/terraform.json"))
  # config = jsondecode(file("${path.module}/terraform.json"))

  region = local.config.project.region[var.environment]

  ssh_keys              = local.config.project.keys
  service_account_email = local.config.project.service_account_email

  # primary_gke_key = keys(module.gke_cluster.cluster_endpoints)[0]

  db_name = "maindb"

  # inventory = templatefile("${path.module}/inventory.tpl", {
  #   bastion_host       = module.vm.public_ips["bastion"]
  #   cloud_sql_instance = "${local.config.project.name}:${local.region}:${local.config.databases[0].name}"

  #   db_host     = module.db-instance.db_hosts[local.db_name]
  #   db_user     = module.db-instance.db_users[local.db_name]
  #   db_password = module.db-instance.db_passwords[local.db_name]
  #   db_port     = module.db-instance.db_ports[local.db_name]
  #   db_name     = module.db-instance.db_names[local.db_name]

  #   static_ips = module.static_ips.ip_addresses
  # })
}
##################################################################
module "network" {
  source            = "./modules/network"
  environment       = var.environment
  project_id        = local.config.project.name
  region            = local.region
  networks          = local.config.network
  acls              = local.config.network[0].subnets
  security_groups   = local.config.security_groups
  health_check_port = var.health_check_port
}
##################################################################
module "db-instance" {
  source           = "./modules/db-instance"
  environment      = var.environment
  project_id       = local.config.project.name
  region           = local.region
  databases        = local.config.databases
  private_networks = module.network.vpc_self_links
  db_username      = data.google_secret_manager_secret_version.db_username.secret_data
  db_pass          = data.google_secret_manager_secret_version.db_password.secret_data

  depends_on = [module.network]
}
##################################################################
module "vm" {
  source                = "./modules/vm"
  environment           = var.environment
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
  source      = "./modules/static_ips"
  environment = var.environment
  static_ips  = local.config.static_ips
}
##################################################################
module "cloudflare_dns" {
  source               = "git@github.com:DolVladzio/cloudflare_dns.git?ref=main"
  environment          = var.environment
  cloudflare_api_token = local.config.project.cloudflare_api_token
  dns_records_config   = local.config.dns_records
  resource_dns_map     = module.static_ips.ip_addresses
}
##################################################################
module "gke_cluster" {
  source                = "./modules/gke_cluster"
  environment           = var.environment
  clusters              = local.config.gke_clusters
  vpc_self_links        = module.network.vpc_self_links
  subnet_self_links     = module.network.subnet_self_links_by_name
  service_account_email = local.config.project.service_account_email

  depends_on = [module.network]
}
##################################################################
# module "cloud_monitoring" {
#   source            = "./modules/cloud_monitoring"
#   monitoring_config = local.config.monitoring

#   depends_on = [module.gke_cluster]
# }
##################################################################
# module "inventory" {
#   source              = "./modules/inventory"
#   inventory           = local.inventory
#   ansible_bucket_name = local.config.project.ansible_bucket_name
#   inventory_info      = local.config.inventory_info

#   depends_on = [
#     "module.static_ips",
#     "module.db-instance",
#     "module.vm"
#   ]
# }
##################################################################