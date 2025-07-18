# 🖥️ GCP Compute Instance Module

This Terraform module provisions **Compute Engine VM instances** (`google_compute_instance`) in Google Cloud Platform.

Spin up your virtual machines like a boss, complete with disks, networking, metadata, and even shielded configs. 🧰✨

---

## 🚀 Features

✅ Provision one or more VM instances  
✅ Choose machine type, boot disk image, and zone  
✅ Attach to networks and subnets  
✅ Add custom metadata and service accounts  
✅ Enable Shielded VM options (vTPM, integrity monitoring)  
✅ Optionally attach external static IPs

---

## 🗂️ Resource

### 🖥️ `google_compute_instance`
Creates a Compute Engine VM instance in the specified project and zone, with support for:
- Boot disk configuration
- Optional customer-managed encryption keys (CMEK)
- Metadata & startup scripts
- Labels & tags
- Shielded VM settings

---