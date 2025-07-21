##################################################################
resource "google_sql_database_instance" "primary" {
  for_each         = { for db in var.databases : db.name[var.environment] => db }
  name             = each.value.name[var.environment]
  region           = var.region
  database_version = "${upper(each.value.type)}_${each.value.version}"

  settings {
    tier              = "db-g1-${each.value.size}"
    availability_type = each.value.secondary_zone != null ? "REGIONAL" : "ZONAL"

    dynamic "database_flags" {
      for_each = each.value.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "location_preference" {
      for_each = [1]
      content {
        zone           = "${var.region}-${each.value.zone[0]}"
        secondary_zone = each.value.secondary_zone != null ? "${var.region}-${each.value.secondary_zone}" : null
      }
    }

    dynamic "backup_configuration" {
      for_each = each.value.backup_configuration
      content {
        enabled                        = backup_configuration.value.enabled
        start_time                     = backup_configuration.value.start_time
        point_in_time_recovery_enabled = backup_configuration.value.point_in_time_recovery_enabled
      }
    }

    ip_configuration {
      ipv4_enabled    = each.value.ipv4_enabled
      private_network = var.private_networks[each.value.network[var.environment]]
    }
  }

  deletion_protection = each.value.deletion_protection
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