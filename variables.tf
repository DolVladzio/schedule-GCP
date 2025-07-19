##################################################################
variable "health_check_port" {
  description = "Port used for health checks (default: 6443 for K3s)"
  type        = number
  default     = 6443
}
##################################################################
variable "environment" {
  description = "Value of the env either the dev or the prod"
}
##################################################################