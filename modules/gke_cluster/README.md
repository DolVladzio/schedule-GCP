# 🗄️ GCP GKE Cluster Module

This Terraform module provisions Google Kubernetes Engine (**GKE**) resources:  
✅ A **GKE Cluster** (`google_container_cluster`)  
✅ One or more **Node Pools** (`google_container_node_pool`)  

…so you can deploy your k8s workloads like the cloud-native pro you are. 🚀

---

## 🚀 Features

✅ Create a regional or zonal GKE cluster (`google_container_cluster`)  
✅ Add one or more node pools with custom machine types, autoscaling, and more (`google_container_node_pool`)  
✅ Supports private clusters, shielded nodes, and workload identity  
✅ Compatible with existing VPC and subnets

---

## 🗂️ Resources

### ☸️ `google_container_cluster`
Creates the GKE cluster control plane, including options for:
- Private or public clusters
- Master authorized networks
- Logging & monitoring
- IP allocation policies
- Workload Identity

### 🧱 `google_container_node_pool`
Adds one or more node pools to your cluster:
- Set machine type & disk size
- Enable autoscaling & auto-repair
- Use preemptible (spot) VMs if desired

---