##################################################################
resource "google_sql_database_instance" "primary" {
  for_each         = { for db in var.databases : db.name => db }
  name             = each.value.name
  region           = var.region
  database_version = "${upper(each.value.type)}_${each.value.version}"

  settings {
    tier              = "db-g1-${each.value.size}"
    availability_type = each.value.secondary_zone != null ? "REGIONAL" : "ZONAL"

    database_flags {
      name  = each.value.database_flags_name
      value = "${lookup(each.value, "database_flags_value", 0)}"
    }

    dynamic "location_preference" {
      for_each = [1]
      content {
        zone           = "${var.region}-${each.value.zone[0]}"
        secondary_zone = each.value.secondary_zone != null ? "${var.region}-${each.value.secondary_zone}" : null
      }
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "20:50"
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = lookup(var.private_networks, each.value.network)
    }
  }

  deletion_protection = false
}
##################################################################
resource "google_sql_database" "databases" {
  for_each = google_sql_database_instance.primary
  name     = each.key
  instance = each.value.name
}
##################################################################
resource "google_sql_user" "users" {
  for_each = google_sql_database_instance.primary
  name     = var.db_username
  instance = google_sql_database_instance.primary[each.key].name
  password = var.db_pass
}
##################################################################