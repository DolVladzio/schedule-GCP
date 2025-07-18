# 🌐 GCP Static IP Module

This Terraform module provisions **static IP addresses** in Google Cloud:  
✅ Regional IPs (`google_compute_address`)  
✅ Global IPs (`google_compute_global_address`)  

For when you just can’t let go of that perfect, beautiful IP. 📌

---

## 🚀 Features

✅ Reserve a **regional static IP** (`google_compute_address`)  
✅ Reserve a **global static IP** (`google_compute_global_address`)  
✅ Supports custom names, descriptions, and labels  
✅ IPv4 and IPv6 (where supported)

---

## 🗂️ Resources

### 📍 `google_compute_address`
Reserves a regional static IP address in a given region. Useful for load balancers, VM instances, or anything tied to a region.

### 🌍 `google_compute_global_address`
Reserves a global static IP address. Usually used with global resources like HTTP(S) load balancers.

---