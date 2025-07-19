# ### GKE cluster ##################################################
# output "gke_cluster_endpoints" {
#   description = "Map of GKE cluster names to their API endpoints"
#   value       = module.gke_cluster.cluster_endpoints
# }

# output "gke_cluster_ca_certificates" {
#   description = "Map of GKE cluster names to their CA certificates"
#   value       = module.gke_cluster.cluster_ca_certificates
# }
# ##################################################################
output "subnet_self_links_by_name" {
  description = "Map of subnets"
  value       = module.network.subnet_self_links_by_name
}
##################################################################