##################################################################
resource "local_file" "ansible_inventory" {
  content  = var.inventory
  filename = "${path.module}/../../inventory/inventory.ini"
}
##################################################################
resource "google_storage_bucket_object" "inventory_ini" {
  for_each     = { for inventory in var.inventory_info : inventory.name => inventory }
  name         = each.value.name
  bucket       = var.ansible_bucket_name
  source       = "${path.module}/../../inventory/inventory.ini"
  content_type = each.value.content_type

  metadata = {
    last_updated = timestamp()
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
##################################################################