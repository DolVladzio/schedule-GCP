# 🗄️ GCP Cloud SQL Module

This Terraform module provisions Google Cloud **SQL instances**, **databases**, and **users**, so you can have a database party 🎉 with the least amount of manual clicking.

---

## 🚀 Features

✅ Create **Cloud SQL Instances** (`google_sql_database_instance`)  
✅ Create one or more **Databases** inside the instance (`google_sql_database`)  
✅ Create one or more **Users** for access control (`google_sql_user`)  
✅ Supports regional or zonal deployments  
✅ Configurable flags, backups, SSL, and private networking  

---

## 🗂️ Resources

### 🖥️ `google_sql_database_instance`
Creates the Cloud SQL instance itself, with options to configure machine tier, region, high availability, backups, maintenance windows, IP configuration, and more.

### 📂 `google_sql_database`
Creates one or more logical databases in your Cloud SQL instance.

### 👤 `google_sql_user`
Creates users in the instance with specific usernames and passwords, ready to connect to your DBs.

---