##################################################################
resource "google_compute_global_address" "static_global_ip" {
  for_each = {
    for ip in var.static_ips : ip.name[var.environment] => ip
    if ip.type == "global"
  }

  name = each.value.name
}
##################################################################
resource "google_compute_address" "static_regional_ip" {
  for_each = {
    for ip in var.static_ips : ip.name[var.environment] => ip
    if ip.type == "regional"
  }

  name   = each.value.name[var.environment]
  region = each.value.region[var.environment]
}
##################################################################