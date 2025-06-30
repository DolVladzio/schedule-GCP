##################################################################
variable "cloudflare_zone_id" {}
##################################################################
variable "cloudflare_api_token" {}
##################################################################
variable "dns_records_config" {
  description = "DNS records from config"
  type = list(object({
    name          = string
    type          = string
    proxied       = bool
    value         = string
    resolve_value = optional(bool)
  }))
}
##################################################################
variable "resource_dns_map" {
  description = "Map of resource names to DNS values"
  type        = map(string)
  default     = {}
}
##################################################################