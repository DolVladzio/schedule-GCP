# 📝 GCP File Upload Module

This Terraform module creates **local files** and uploads them as objects to **Google Cloud Storage (GCS)**.  
Because sometimes even the cloud needs you to write things down first. ☁️🗒️

---

## 🚀 Features

✅ Create local files on the machine running Terraform (`local_file`)  
✅ Upload those files to a specified GCS bucket (`google_storage_bucket_object`)  
✅ Supports dynamic filenames, bucket names, and content

---

## 🗂️ Resources

### 📝 `local_file`
Writes a file to disk with the specified content. This can be a manifest, a config file, or anything else you need to materialize before uploading.

### 🪣 `google_storage_bucket_object`
Uploads a file from disk into a GCS bucket as a named object.

---