##################################################################
variable "environment" {}
##################################################################
variable "monitoring_config" {
  description = "Monitoring configuration object"
  type = object({
    notification_channels = list(object({
      name = object({
        dev  = string
        prod = string
      })
      type   = string
      labels = map(string)
    }))

    log_based_metrics = list(object({
      name = object({
        dev  = string
        prod = string
      })
      description      = string
      filter           = string
      metric_kind      = string
      value_type       = string
      unit             = string
      label_extractors = optional(map(string), {})
    }))

    alert_policies = list(object({
      name = object({
        dev  = string
        prod = string
      })
      combiner = string
      conditions = list(object({
        name = object({
          dev  = string
          prod = string
        })
        metric_filter = string
        threshold     = number
        duration      = string
        comparison    = string
        aligner       = string
      }))
    }))
  })
}
##################################################################