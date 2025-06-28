#########################################################################
CONFIG_PATH=$1
KEY_FILE="${2%.json}.json"
PROJECT_ID=$(gcloud config get-value project)
# Secrets
SECRET_NAME_DB_USERNAME=$(grep -oP '"secret_name_db_username":\s*"\K[^"]+' "$CONFIG_PATH")
SECRET_NAME_DB_PASS=$(grep -oP '"secret_name_db_pass":\s*"\K[^"]+' "$CONFIG_PATH")
SECRET_NAME_GAR_BASE64=$(grep -oP '"jenkins_gar_base64":\s*"\K[^"]+' "$CONFIG_PATH")
# Artifact registry
ARTIFACT_REGISTRY_GCP=$(grep -oP '"artifact_registry_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_FORMAT=$(grep -oP '"artifact_registry_gcp_format":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_LOCATION=$(grep -oP '"artifact_registry_gcp_location":\s*"\K[^"]+' "$CONFIG_PATH")
# Bucket
NEW_BUCKET_NAME=$(grep -oP 'state-bucket-name-[^ ]*' "gcp_cloud_env.sh")

export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
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
delete_secret "$SECRET_NAME_GAR_BASE64" "$PROJECT_ID"
#########################################################################
echo "=== Deleting the bucket: ${NEW_BUCKET_NAME}... ==="

if gcloud storage buckets delete "gs://${NEW_BUCKET_NAME}" --project=${PROJECT_ID}; then
	echo "=== The bucket: ${NEW_BUCKET_NAME} was deleted! ==="
else
	echo "=== === The bucket: ${NEW_BUCKET_NAME} wasn't deleted! Perhaps it's not exist( ==="
fi
#########################################################################
# echo "=== Deleting the artifact registry: ${ARTIFACT_REGISTRY_GCP}... ==="
#########################################################################