# 📈 GCP Logging & Monitoring Module

This Terraform module provisions Google Cloud **Logging Metrics**, **Monitoring Alert Policies**, and **Notification Channels**, so you can keep an eye on your infrastructure like a hawk… or at least a caffeinated squirrel. ☕🐿️

---

## 🚀 Features

✅ Create **Log-based Metrics** (`google_logging_metric`)  
✅ Define **Alert Policies** (`google_monitoring_alert_policy`)  
✅ Configure **Notification Channels** (`google_monitoring_notification_channel`)  
✅ Easily integrate GCP monitoring into your CI/CD workflows  

---

## 🗂️ Resources

### 📊 `google_logging_metric`
Defines a log-based metric in Cloud Logging that can later be used as a condition in monitoring alert policies.  
For example: count occurrences of specific log entries.

### 🚨 `google_monitoring_alert_policy`
Creates a Cloud Monitoring alert policy that triggers when a specific metric meets a threshold or condition.  
Can be used to notify you when things go sideways.

### ✉️ `google_monitoring_notification_channel`
Configures notification channels such as:
- Email
- SMS
- Slack webhook
- PagerDuty
- …etc.  
These are linked to your alert policies to actually send out the distress signal.

---