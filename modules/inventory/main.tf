##################################################################
resource "local_file" "ansible_inventory" {
  content  = var.inventory
  filename = "${path.module}/../../../schedule-Ansible/inventory/inventory.ini"
}
##################################################################