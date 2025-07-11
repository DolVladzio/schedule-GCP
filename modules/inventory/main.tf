##################################################################
resource "local_file" "ansible_inventory" {
  content  = var.inventory
  filename = "${path.module}/../../inventory/inventory.ini"
}
##################################################################
resource "google_storage_bucket_object" "inventory_ini" {
  name         = "inventory.ini"
  bucket       = var.ansible_bucket_name
  source       = "${path.module}/../../inventory/inventory.ini"
  content_type = "text/plain"

  metadata = {
    last_updated = timestamp()
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
##################################################################