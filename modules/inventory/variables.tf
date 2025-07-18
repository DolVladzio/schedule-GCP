##################################################################
variable "inventory" {}
##################################################################
variable "inventory_info" {
  type = list(object({
    name         = string
    content_type = string
  }))
  description = "List of inventory info with name and content_type"
}
##################################################################
variable "ansible_bucket_name" {}
##################################################################