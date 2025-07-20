##################################################################
variable "environment" {}
##################################################################
variable "clusters" {
  description = "Map of GKE clusters to create"
  type = map(object({
    name = object({
      dev  = string
      prod = string
    })
    location = object({
      dev  = string
      prod = string
    })
    network = object({
      dev  = string
      prod = string
    })
    subnetwork = object({
      dev  = string
      prod = string
    })
    initial_node_count       = number
    deletion_protection      = bool
    remove_default_node_pool = bool
    enable_private_nodes     = bool
    enable_private_endpoint  = bool
    node_pools = optional(list(object({
      name = string
      machine_type = object({
        dev  = string
        prod = string
      })
      min_node_count = number
      max_node_count = object({
        dev  = string
        prod = string
      })
      disk_size_gb = optional(number)
      oauth_scopes = optional(list(string))
      auto_upgrade = optional(bool)
      auto_repair  = optional(bool)
    })), [])
    authorized_networks = list(object({
      cidr_block   = string
      display_name = string
    }))
    private_cluster    = bool
    kubernetes_version = string
  }))
}
##################################################################
variable "vpc_self_links" {
  description = "Map of network name to VPC self_link"
  type        = map(string)
}
##################################################################
variable "subnet_self_links" {
  description = "Map from network-subnet name to self_link"
  type        = map(string)
}
##################################################################
variable "service_account_email" {}
##################################################################