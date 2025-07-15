##################################################################
variable "health_check_port" {
  description = "Port used for health checks (default: 6443 for K3s)"
  type        = number
  default     = 6443
}
##################################################################