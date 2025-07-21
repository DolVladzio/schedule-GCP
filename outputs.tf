### Network ######################################################
output "subnet_self_links_by_name" {
  description = "Map of subnets"
  value       = module.network.subnet_self_links_by_name
}
### Static ips ###################################################
output "ip_addresses" {
  description = "Map of subnets"
  value       = module.static_ips.ip_addresses
}
##################################################################