#!/bin/bash
set -euo pipefail
#########################################################################
CONFIG_PATH=$1
KEY_FILE="${2%.json}.json"
ENV_FILE="./gcp_cloud_env.sh"
PROJECT_ID=$(gcloud config get-value project)
# Service account
SERVICE_ACCOUNT_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' "$CONFIG_PATH")
DESCRIPTION="The service account for the Terraform"
# Bucket
BUCKET_LOCATION=$(grep -oP '"state_bucket_location_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
NEW_BUCKET_NAME=""
# Artifact registry
ARTIFACT_REGISTRY_GCP=$(grep -oP '"artifact_registry_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_FORMAT=$(grep -oP '"artifact_registry_gcp_format":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_LOCATION=$(grep -oP '"artifact_registry_gcp_location":\s*"\K[^"]+' "$CONFIG_PATH")
ARTIFACT_REGISTRY_GCP_DESCRIPTION="The artifact registry for the docker images"
# Secrets
SECRET_NAME_DB_USERNAME=$(grep -oP '"secret_name_db_username":\s*"\K[^"]+' "$CONFIG_PATH")
SECRET_NAME_DB_PASS=$(grep -oP '"secret_name_db_pass":\s*"\K[^"]+' "$CONFIG_PATH")
DB_PASS=$(grep -oP '"db_pass":\s*"\K[^"]+' "$CONFIG_PATH")
DB_USERNAME=$(grep -oP '"db_user":\s*"\K[^"]+' "$CONFIG_PATH")
#########################################################################
if [[ -z "$PROJECT_ID" ]]; then
	echo "=== Error: Unable to retrieve GCP project ID. Use 'gcloud config set project YOUR_PROJECT_ID' ==="
	exit 1
else
	echo "=== The project's ID: '$PROJECT_ID' ==="
	echo
fi
#########################################################################
REQUIRED_APIS=(
	"iamcredentials.googleapis.com"
	"iam.googleapis.com"
	"compute.googleapis.com"
	"cloudresourcemanager.googleapis.com"
	"serviceusage.googleapis.com"
	"storage.googleapis.com"
	"artifactregistry.googleapis.com"
	"secretmanager.googleapis.com"
	"sqladmin.googleapis.com"
	"monitoring.googleapis.com"
	"logging.googleapis.com"
	"cloudtrace.googleapis.com"
	"servicenetworking.googleapis.com"
	"container.googleapis.com"
	"dns.googleapis.com"
)

echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
	echo "- Enabling the '$api'..."
	gcloud services enable "$api" --project="$PROJECT_ID" || echo "=== Failed to enable the $api ==="
done
echo "=== All required APIs were enabled ==="
echo
#########################################################################
echo "=== Checking for the service account: $SERVICE_ACCOUNT_NAME... ==="
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" > /dev/null 2>&1; then
	echo "=== The service account: $SERVICE_ACCOUNT_NAME already exists. ==="
else
	echo "=== Creating service account: $SERVICE_ACCOUNT_NAME ==="
	gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
		--description="$DESCRIPTION" \
		--display-name="$SERVICE_ACCOUNT_NAME"
	echo
fi
echo
#########################################################################
IAM_ROLES=(
	"editor"
	"secretmanager.secretAccessor"
	"iam.serviceAccountUser"
	"logging.logWriter"
	"monitoring.metricWriter"
	"monitoring.viewer"
	"servicenetworking.admin"
	"compute.networkAdmin"
	"storage.objectAdmin"
	"container.admin"
	"container.clusterAdmin"
	"artifactregistry.reader"
	"artifactregistry.writer"
)

for iam_role in "${IAM_ROLES[@]}"; do
	echo "=== Binding the role '$iam_role' to a service account... ==="
	gcloud projects add-iam-policy-binding "$PROJECT_ID" \
		--member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
		--role="roles/$iam_role" || echo "=== The role binding may already exist ==="
	echo
done
echo "=== All iam roles were enabled ==="
echo
#########################################################################
echo "=== Checking if the key file: $KEY_FILE already exists ==="
if [[ -f "$KEY_FILE" ]]; then
	echo "=== The key file: $KEY_FILE already exists. ==="
	echo
else
	echo "=== Creating the key file: $KEY_FILE ==="
	gcloud iam service-accounts keys create "$KEY_FILE" \
		--iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
	echo
fi
echo

base64 "$KEY_FILE" > tfbase64
#########################################################################
check_secret_exists() {
    gcloud secrets describe "$1" --project="$2" &>/dev/null
}
# Function to create a secret if it doesn't already exist
create_secret() {
    SECRET_NAME=$1
    PROJECT_ID=$2
    SECRET_VALUE=$3

    if check_secret_exists "$SECRET_NAME" "$PROJECT_ID"; then
        echo "=== The secret '$SECRET_NAME' already exists. ==="
    else
        echo "Creating the secret: '$SECRET_NAME'..."
        if gcloud secrets create "$SECRET_NAME" \
                --replication-policy="automatic" \
                --project="$PROJECT_ID"; then
            echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" \
                --data-file=- \
                --project="$PROJECT_ID"
            echo "=== The secret: '$SECRET_NAME' created and value added. ==="
        else
            echo "=== Failed to create the secret: '$SECRET_NAME'. ==="
            exit 1
        fi
    fi
}
create_secret "$SECRET_NAME_DB_USERNAME" "$PROJECT_ID" "$DB_USERNAME"
create_secret "$SECRET_NAME_DB_PASS" "$PROJECT_ID" "$DB_PASS"

echo
#########################################################################
echo "=== Creating a bucket ==="
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    if gsutil ls -b "gs://$TF_VAR_cloud_bucket" > /dev/null 2>&1; then
        echo "=== The bucket: gs://$TF_VAR_cloud_bucket already exists. ==="
        NEW_BUCKET_NAME="$TF_VAR_cloud_bucket"
    fi
fi

if [ -z "$NEW_BUCKET_NAME" ]; then
    BUCKET_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' "$CONFIG_PATH")
    NEW_BUCKET_NAME="${BUCKET_NAME}-$(date +'%Y-%m-%d-%H-%M-%S')"

    echo "=== Creating the bucket: gs://$NEW_BUCKET_NAME ==="
    gcloud storage buckets create "gs://$NEW_BUCKET_NAME" \
        --location="$BUCKET_LOCATION" \
        --uniform-bucket-level-access

    echo "=== Enabling versioning on gs://$NEW_BUCKET_NAME ==="
    gsutil versioning set on "gs://$NEW_BUCKET_NAME" || echo "=== Versioning already enabled ==="

    cat > "$ENV_FILE" <<EOL
export TF_VAR_cloud_bucket=$NEW_BUCKET_NAME
EOL
fi
echo
#########################################################################
if gcloud artifacts repositories describe "${ARTIFACT_REGISTRY_GCP}" \
		--location="${ARTIFACT_REGISTRY_GCP_LOCATION}" &>/dev/null; then
    echo "=== The artifact registry: '${ARTIFACT_REGISTRY_GCP}' already exists. ==="
else
    echo "=== Creating the artifact registry: '${ARTIFACT_REGISTRY_GCP}'... ==="
    if gcloud artifacts repositories create "${ARTIFACT_REGISTRY_GCP}" \
        --repository-format="${ARTIFACT_REGISTRY_GCP_FORMAT}" \
        --location="${ARTIFACT_REGISTRY_GCP_LOCATION}" \
        --description="${ARTIFACT_REGISTRY_GCP_DESCRIPTION}"; then
        echo "=== The artifact registry: '${ARTIFACT_REGISTRY_GCP}' was created successfully! ==="
    else
        echo "=== Failed to create the artifact registry: '${ARTIFACT_REGISTRY_GCP}'. ==="
        exit 1
    fi
fi
#########################################################################
# startTerraformAndApply() {
# 	echo "=== Initializing Terraform ==="
# 	terraform init \
# 		-backend-config="bucket=$1" \
# 		-reconfigure
# 	echo "=== Terraform initialized ==="
	
# 	echo "=== Applying Terraform ==="
# 	terraform apply -auto-approve
# 	echo "=== Terraform apply completed ==="
# }
# startTerraformAndApply "$NEW_BUCKET_NAME"
#########################################################################