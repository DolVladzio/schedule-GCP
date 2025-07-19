##################################################################
variable "environment" {}
##################################################################
variable "static_ips" {
  description = "List of static IPs to reserve"
  type = list(object({
    name = object({
      dev  = string
      prod = string
    })
    type = string
    region = object({
      dev  = string
      prod = string
    })
  }))
}
##################################################################