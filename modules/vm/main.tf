##################################################################
locals {
  # map “size” strings to real GCP machine types
  size_map = {
    small  = "e2-small"
    medium = "e2-medium"
    large  = "e2-large"
  }

  os_map = {
    ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}
##################################################################
resource "google_compute_instance" "vm" {
  for_each = { for vm in var.vm_instances : vm.name => vm }

  project      = var.project_id
  name         = each.key
  machine_type = lookup(local.size_map, each.value.size, each.value.size)
  zone         = "${var.region}-${each.value.zone}"

  boot_disk {
    initialize_params {
      image = lookup(local.os_map, var.project_os, local.os_map["ubuntu"])
    }
  }

  shielded_instance_config {
    enable_vtpm        = each.value.enable_vtpm
    enable_secure_boot = each.value.enable_secure_boot
  }

  allow_stopping_for_update = each.value.allow_stopping_for_update

  network_interface {
    subnetwork = var.subnet_self_links_map[each.value.subnet[var.environment]]
    
    dynamic "access_config" {
      for_each = each.value.public_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    block-project-ssh-keys = "${each.value.block-project-ssh-keys}"
    startup-script = templatefile("${path.root}/shell_scripts/metadata.sh", {
      ssh_keys = join("\n", var.ssh_keys)
    })
  }

  tags = concat(
    tolist(each.value.tags),
    lookup(each.value, "security_groups", []),
    ["monitoring"]
  )

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
##################################################################