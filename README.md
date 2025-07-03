# Terraform GCP Infrastructure Setup

This project sets up a complete infrastructure on Google Cloud Platform (GCP) using Terraform. It provisions resources such as VPC networks, GKE clusters, Cloud SQL instances, static IPs, and integrates with Cloudflare DNS and Cloud Monitoring.

---

## **Project Structure**
The configuration is organized into reusable modules for better maintainability and scalability:
- `network`: Configures VPCs, subnets, and firewall rules.
- `db-instance`: Provisions Cloud SQL instances.
- `static_ips`: Allocates static IP addresses.
- `cloudflare_dns`: Manages DNS records via Cloudflare.
- `gke_cluster`: Deploys GKE clusters.
- `cloud_monitoring`: Sets up monitoring configurations.

---

## **Prerequisites**
1. **Google Cloud CLI**: Install and authenticate using `gcloud auth login`.
2. **Terraform**: Ensure Terraform is installed and configured (`>= 1.0` recommended).
3. **Cloudflare API Token**: Required for managing DNS records.
4. **Config File**: A `config.json` file is required at the root level to supply input data.
