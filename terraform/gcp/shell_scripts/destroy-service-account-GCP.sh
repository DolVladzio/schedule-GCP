#!/bin/bash
set -euo pipefail
#########################################################################
CONFIG_PATH=$1
KEY_FILE="${2%.json}.json"
PROJECT_ID=$(gcloud config get-value project)
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
# Secrets
SECRET_NAME_DB_USERNAME=$(grep -oP '"secret_name_db_username":\s*"\K[^"]+' "$CONFIG_PATH")
SECRET_NAME_DB_PASS=$(grep -oP '"secret_name_db_pass":\s*"\K[^"]+' "$CONFIG_PATH")
# Artifact registry
ARTIFACT_REGISTRY_GCP=$(grep -oP '"artifact_registry_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_FORMAT=$(grep -oP '"artifact_registry_gcp_format":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_LOCATION=$(grep -oP '"artifact_registry_gcp_location":\s*"\K[^"]+' "$CONFIG_PATH")
# Bucket
NEW_BUCKET_NAME=$(grep -oP 'state-bucket-name-[^ ]*' "gcp_cloud_env.sh")
#########################################################################
destroyTerraform() {
	echo "=== Destroying Terraform ==="
	terraform destroy --auto-approve
	echo "=== Terraform destroyed ==="
}
destroyTerraform "$NEW_BUCKET_NAME"
#########################################################################
check_secret_exists() {
    gcloud secrets describe "$1" --project="$2" &>/dev/null
}
# Function to delete a secret if it exists
delete_secret() {
    SECRET_NAME=$1
    PROJECT_ID=$2

    echo "=== Deleting the secret: '$SECRET_NAME'... ==="
	if gcloud secrets delete "$SECRET_NAME" --quiet; then
		echo "=== The secret: ${SECRET_NAME} was deleted! ==="
		echo
	else 
		echo "=== The secret: ${SECRET_NAME} wasn't deleted! Perhaps it's not exist( ==="
		echo
	fi
}

delete_secret "$SECRET_NAME_DB_USERNAME" "$PROJECT_ID"
delete_secret "$SECRET_NAME_DB_PASS" "$PROJECT_ID"
#########################################################################
if gcloud storage buckets describe "gs://${NEW_BUCKET_NAME}" \
		--project="${PROJECT_ID}" &>/dev/null; then
    echo "=== The bucket: gs://${NEW_BUCKET_NAME} exists. Deleting it... ==="
    if gcloud storage buckets delete "gs://${NEW_BUCKET_NAME}" \
		--project="${PROJECT_ID}"; then
        echo "=== The bucket: hs://${NEW_BUCKET_NAME} was deleted! ==="
    else
        echo "=== Failed to delete the bucket: ${NEW_BUCKET_NAME}. ==="
        exit 1
    fi
else
    echo "=== The bucket: ${NEW_BUCKET_NAME} does not exist. Nothing to delete. ==="
fi
echo
#########################################################################
if gcloud artifacts repositories describe "${ARTIFACT_REGISTRY_GCP}" \
		--location="${ARTIFACT_REGISTRY_GCP_LOCATION}" &>/dev/null; then
    echo "=== The artifact registry: '${ARTIFACT_REGISTRY_GCP}' exists. Deleting it... ==="
    if gcloud artifacts repositories delete "${ARTIFACT_REGISTRY_GCP}" \
			--location="${ARTIFACT_REGISTRY_GCP_LOCATION}" \
			--quiet; then
        echo "=== The artifact registry: '${ARTIFACT_REGISTRY_GCP}' was deleted successfully! ==="
    else
        echo "=== Failed to delete the artifact registry: '${ARTIFACT_REGISTRY_GCP}'. ==="
        exit 1
    fi
else
    echo "=== The artifact registry: '${ARTIFACT_REGISTRY_GCP}' does not exist. Nothing to delete. ==="
fi
echo
#########################################################################
echo "=== Everything was destroyed successfully! ==="
#########################################################################
