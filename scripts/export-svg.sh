#!/usr/bin/env bash
# Export Structurizr diagrams to SVG via Puppeteer (Docker)
#
# Usage:
#   scripts/export-svg.sh           — export to structurizr/export/
#   scripts/export-svg.sh my_dir    — export to specified directory
#
# Requirements: Docker, running docker compose (Structurizr Lite)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_SUBDIR="${1:-structurizr/export}"

# Load variables from .env
if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a; source "${PROJECT_DIR}/.env"; set +a
fi

NETWORK="${DOCKER_NETWORK:?DOCKER_NETWORK variable is not set. Check your .env file}"
CONTAINER="${STRUCTURIZR_CONTAINER_NAME:?STRUCTURIZR_CONTAINER_NAME variable is not set. Check your .env file}"
STRUCTURIZR_URL="http://${CONTAINER}:8080/workspace/diagrams"
PUPPETEER_IMAGE="ghcr.io/puppeteer/puppeteer:24"

# --- Check if Structurizr is running ---
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Structurizr is not running. Starting docker compose up -d ..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d
  echo "Waiting for Structurizr to be ready (up to 30 sec)..."
  for i in $(seq 1 30); do
    if curl -sf "http://${CONTAINER}:8080" > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

# --- Connect dev container to Structurizr network (if not already connected) ---
DEVCONTAINER_ID="$(hostname)"
if ! docker network inspect "${NETWORK}" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null | grep -q "${DEVCONTAINER_ID}"; then
  echo "Connecting dev container to ${NETWORK} network..."
  docker network connect "${NETWORK}" "${DEVCONTAINER_ID}" 2>/dev/null || true
fi

# --- Wait for Structurizr to respond ---
echo "Checking Structurizr availability..."
for i in $(seq 1 30); do
  if curl -sf "${STRUCTURIZR_URL}" > /dev/null 2>&1; then
    echo "Structurizr is available."
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "ERROR: Structurizr is not responding at ${STRUCTURIZR_URL}" >&2
    exit 1
  fi
  sleep 1
done

# --- Create SVG output directory with write permissions for puppeteer container (uid 10042) ---
mkdir -p "${PROJECT_DIR}/${OUTPUT_SUBDIR}"
chmod 777 "${PROJECT_DIR}/${OUTPUT_SUBDIR}"

# --- Run Puppeteer in Docker ---
echo "Starting diagram export..."
docker run --rm \
  --network "${NETWORK}" \
  -v "${HOST_PROJECT_ROOT}/scripts/export-diagrams.js:/home/pptruser/export-diagrams.js:ro" \
  -v "${HOST_PROJECT_ROOT}/${OUTPUT_SUBDIR}:/output" \
  "${PUPPETEER_IMAGE}" \
  node /home/pptruser/export-diagrams.js "${STRUCTURIZR_URL}" /output

echo ""
echo "SVG files saved to ${OUTPUT_SUBDIR}/"
ls -1 "${PROJECT_DIR}/${OUTPUT_SUBDIR}"/*.svg 2>/dev/null || echo "(no files found — check logs above)"
