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

  lifecycle {
    replace_triggered_by = [filesha256("${path.module}/../../inventory/inventory.ini")]
  }

  depends_on = [
    local_file.ansible_inventory
  ]
}
##################################################################