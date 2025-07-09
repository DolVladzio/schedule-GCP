##################################################################
resource "local_file" "ansible_inventory" {
  content  = var.inventory
  filename = "${path.module}/../../inventory/inventory.ini"
}
##################################################################
resource "google_storage_bucket_object" "inventory_ini" {
  name   = "inventory.ini"
  bucket = "ansible-inventory-file"
  source = "${path.module}/../../inventory/inventory.ini"
  content_type = "text/plain"
}
##################################################################