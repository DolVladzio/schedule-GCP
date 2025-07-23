##################################################################
variable "project_id" {
  type        = string
  description = "GCP project ID"
}
##################################################################
variable "region" {
  type        = string
  description = "GCP region (e.g. europe-central2)"
}
##################################################################
variable "project_os" {
  type        = string
  description = "Key for OS lookup (e.g. ubuntu)"
}
##################################################################
variable "environment" {}
##################################################################
variable "vm_instances" {
  type = list(object({
    name = object({
      dev  = string
      prod = string
    })
    size = string
    zone = string
    subnet = object({
      dev  = string
      prod = string
    })
    public_ip                 = bool
    enable_vtpm               = bool
    enable_secure_boot        = bool
    allow_stopping_for_update = bool
  }))
  description = "List of VMs (from config.json)"
}
##################################################################
variable "subnet_self_links_map" {
  type        = map(string)
  description = "Map of subnet name → self_link (from network module)"
}
##################################################################
variable "ssh_keys" {
  description = "SSH public keys"
}
##################################################################
variable "service_account_email" {
  type        = string
  description = "Service account email for the VM"
}
##################################################################
