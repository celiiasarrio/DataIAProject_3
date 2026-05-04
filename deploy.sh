#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ID="project3grupo6"
REGION="europe-west1"
REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${PROJECT_ID}"
BACKEND_SERVICE="${PROJECT_ID}-backend"
AGENT_SERVICE="${PROJECT_ID}-agent"

echo "==> Configuring Docker for Artifact Registry..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

echo "==> Creating Artifact Registry (if not exists)..."
terraform -chdir="${SCRIPT_DIR}/terraform" init
terraform -chdir="${SCRIPT_DIR}/terraform" apply -target=google_artifact_registry_repository.docker -auto-approve

echo "==> Building backend image..."
docker build -t "${REGISTRY}/backend:latest" "${SCRIPT_DIR}/backend"

echo "==> Pushing backend image..."
docker push "${REGISTRY}/backend:latest"

echo "==> Building agent image..."
docker build -t "${REGISTRY}/agent:latest" "${SCRIPT_DIR}/agent"

echo "==> Pushing agent image..."
docker push "${REGISTRY}/agent:latest"

echo "==> Building frontend image..."
docker build -t "${REGISTRY}/frontend:latest" "${SCRIPT_DIR}/frontend"

echo "==> Pushing frontend image..."
docker push "${REGISTRY}/frontend:latest"

echo "==> Deploying infrastructure..."
terraform -chdir="${SCRIPT_DIR}/terraform" apply -auto-approve

echo "==> Resolving deployed service URLs..."
BACKEND_URL=$(gcloud run services describe "${BACKEND_SERVICE}" --region "${REGION}" --format 'value(status.url)')
AGENT_URL=$(gcloud run services describe "${AGENT_SERVICE}" --region "${REGION}" --format 'value(status.url)')

echo "==> Rebuilding frontend image with backend and agent URLs..."
docker build \
  --build-arg VITE_BACKEND_URL="${BACKEND_URL}" \
  --build-arg VITE_AGENT_URL="${AGENT_URL}" \
  -t "${REGISTRY}/frontend:latest" \
  "${SCRIPT_DIR}/frontend"

echo "==> Pushing rebuilt frontend image..."
docker push "${REGISTRY}/frontend:latest"

echo "==> Refreshing infrastructure with the final frontend image..."
terraform -chdir="${SCRIPT_DIR}/terraform" apply -auto-approve

echo "==> Done!"
terraform -chdir="${SCRIPT_DIR}/terraform" output frontend_url
