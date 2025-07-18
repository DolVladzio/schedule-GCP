##################################################################
variable "databases" {
  description = "List of database configurations"
  type = list(object({
    name    = string
    network = string
    type    = string
    version = string
    size    = string
    database_flags = list(object({
      name  = string
      value = string
    }))
    backup_configuration = list(object({
      enabled                        = bool
      start_time                     = string
      point_in_time_recovery_enabled = bool
    }))
    zone            = list(string)
    subnets         = list(string)
    port            = number
    security_groups = list(string)
    region          = optional(string)
    secondary_zone  = optional(string)
  }))
}
##################################################################
variable "private_networks" {
  description = "Map of network name to VPC self-link"
  type        = map(string)
}
##################################################################
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
##################################################################
variable "subnet_self_links" {
  description = "Map of subnet name to self-link"
  type        = map(string)
}
##################################################################
variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}
##################################################################
variable "db_pass" {}
##################################################################
variable "db_username" {}
##################################################################