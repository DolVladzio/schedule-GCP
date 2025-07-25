##################################################################
locals {
  config = var.monitoring_config
}
##################################################################
resource "google_logging_metric" "log_based_metrics" {
  for_each = { for m in local.config.log_based_metrics : m.name[var.environment] => m }

  name        = each.value.name[var.environment]
  description = each.value.description
  filter      = each.value.filter

  metric_descriptor {
    metric_kind = each.value.metric_kind
    value_type  = each.value.value_type
    unit        = each.value.unit
  }

  label_extractors = each.value.label_extractors
}
##################################################################
resource "google_monitoring_alert_policy" "alerts" {
  for_each = { for a in local.config.alert_policies : a.name[var.environment] => a }

  display_name = each.value.name[var.environment]
  combiner     = each.value.combiner
  enabled      = true

  dynamic "conditions" {
    for_each = { for c in each.value.conditions : c.name[var.environment] => c }

    content {
      display_name = conditions.value.name[var.environment]
      condition_threshold {
        filter          = conditions.value.metric_filter[var.environment]
        comparison      = conditions.value.comparison
        threshold_value = conditions.value.threshold
        duration        = conditions.value.duration

        aggregations {
          alignment_period   = conditions.value.duration
          per_series_aligner = conditions.value.aligner
        }
      }
    }
  }

  notification_channels = [
    for ch in local.config.notification_channels : google_monitoring_notification_channel.channels[ch.name[var.environment]].name
  ]

  depends_on = [
    google_logging_metric.log_based_metrics
  ]
}
##################################################################
resource "google_monitoring_notification_channel" "channels" {
  for_each = {
    for ch in local.config.notification_channels : ch.name[var.environment] => ch
  }

  display_name = each.value.name[var.environment]
  type         = each.value.type
  labels       = each.value.labels
}
##################################################################