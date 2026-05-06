#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${ENV_FILE:-${SCRIPT_DIR}/.env.cloudrun}"

if [ -f "${ENV_FILE}" ]; then
  set -a
  . "${ENV_FILE}"
  set +a
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "Error: gcloud no está instalado o no está en PATH."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker no está instalado o no está en PATH."
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "Error: docker buildx no está disponible."
  exit 1
fi

PROJECT_ID="${PROJECT_ID:-project3grupo6}"
REGION="${REGION:-europe-west1}"
REPOSITORY="${REPOSITORY:-${PROJECT_ID}}"
SERVICE_NAME="${SERVICE_NAME:-${PROJECT_ID}-agent}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
IMAGE_URI="${IMAGE_URI:-${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/agent:${IMAGE_TAG}}"
PLATFORM="${PLATFORM:-linux/amd64}"

BACKEND_BASE_URL="${BACKEND_BASE_URL:?BACKEND_BASE_URL es obligatorio}"
GOOGLE_GENAI_USE_VERTEXAI="${GOOGLE_GENAI_USE_VERTEXAI:-TRUE}"
GOOGLE_CLOUD_PROJECT="${GOOGLE_CLOUD_PROJECT:-${PROJECT_ID}}"
GOOGLE_CLOUD_LOCATION="${GOOGLE_CLOUD_LOCATION:-${REGION}}"
MODEL="${MODEL:-gemini-2.5-flash}"
HTTP_TIMEOUT_SECONDS="${HTTP_TIMEOUT_SECONDS:-15}"
FIRESTORE_PROJECT="${FIRESTORE_PROJECT:-${PROJECT_ID}}"
FIRESTORE_DATABASE="${FIRESTORE_DATABASE:-(default)}"
AGENT_SERVICE_ACCOUNT="${AGENT_SERVICE_ACCOUNT:-}"
ALLOW_UNAUTHENTICATED="${ALLOW_UNAUTHENTICATED:-true}"

echo "==> Configuring gcloud project..."
gcloud config set project "${PROJECT_ID}" >/dev/null

echo "==> Configuring Docker for Artifact Registry..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

echo "==> Building and pushing agent image for ${PLATFORM}..."
docker buildx build \
  --platform "${PLATFORM}" \
  --provenance=false \
  --tag "${IMAGE_URI}" \
  --push \
  "${SCRIPT_DIR}"

ENV_VARS="BACKEND_BASE_URL=${BACKEND_BASE_URL},GOOGLE_GENAI_USE_VERTEXAI=${GOOGLE_GENAI_USE_VERTEXAI},GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT},GOOGLE_CLOUD_LOCATION=${GOOGLE_CLOUD_LOCATION},MODEL=${MODEL},HTTP_TIMEOUT_SECONDS=${HTTP_TIMEOUT_SECONDS},FIRESTORE_PROJECT=${FIRESTORE_PROJECT},FIRESTORE_DATABASE=${FIRESTORE_DATABASE}"

DEPLOY_ARGS=(
  run deploy "${SERVICE_NAME}"
  --project "${PROJECT_ID}"
  --region "${REGION}"
  --platform managed
  --image "${IMAGE_URI}"
  --port 8080
  --cpu 1
  --memory 1Gi
  --min-instances 0
  --max-instances 1
  --set-env-vars "${ENV_VARS}"
)

if [ -n "${AGENT_SERVICE_ACCOUNT}" ]; then
  DEPLOY_ARGS+=(--service-account "${AGENT_SERVICE_ACCOUNT}")
fi

if [ "${ALLOW_UNAUTHENTICATED}" = "true" ]; then
  DEPLOY_ARGS+=(--allow-unauthenticated)
else
  DEPLOY_ARGS+=(--no-allow-unauthenticated)
fi

echo "==> Deploying Cloud Run service..."
gcloud "${DEPLOY_ARGS[@]}"

echo "==> Agent URL"
gcloud run services describe "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --format 'value(status.url)'
