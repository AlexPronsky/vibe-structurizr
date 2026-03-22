#!/usr/bin/env bash
# Structurizr DSL validation via Structurizr Lite API
#
# The script calls GET /api/workspace/1 with HMAC authorization,
# which forces DSL parsing on the server.
# If the DSL is invalid, the API returns an error in JSON.
#
# Usage:
#   scripts/validate-dsl.sh
#
# Exit code: 0 — DSL is valid, 1 — parsing error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load variables from .env
if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a; source "${PROJECT_DIR}/.env"; set +a
fi

NETWORK="${DOCKER_NETWORK:?DOCKER_NETWORK variable is not set. Check your .env file}"
CONTAINER="${STRUCTURIZR_CONTAINER_NAME:?STRUCTURIZR_CONTAINER_NAME variable is not set. Check your .env file}"
STRUCTURIZR_BASE="http://${CONTAINER}:8080"

# --- Check if Structurizr is running ---
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Structurizr is not running. Starting docker compose up -d ..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d
  echo "Waiting for Structurizr to be ready (up to 30 sec)..."
  for i in $(seq 1 30); do
    if curl -sf "${STRUCTURIZR_BASE}" > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

# --- Connect dev container to Structurizr network ---
DEVCONTAINER_ID="$(hostname)"
if ! docker network inspect "${NETWORK}" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null | grep -q "${DEVCONTAINER_ID}"; then
  docker network connect "${NETWORK}" "${DEVCONTAINER_ID}" 2>/dev/null || true
fi

# --- Restart to reset DSL cache ---
echo "Restarting Structurizr to reset DSL cache..."
docker compose -f "${PROJECT_DIR}/docker-compose.yml" restart > /dev/null 2>&1

# Wait for full readiness — /workspace/diagrams should contain StructurizrApiClient
PAGE=""
for i in $(seq 1 30); do
  PAGE=$(curl -sf "${STRUCTURIZR_BASE}/workspace/diagrams" 2>/dev/null || true)
  if echo "$PAGE" | grep -q 'StructurizrApiClient'; then
    break
  fi
  PAGE=""
  sleep 1
done

if [ -z "$PAGE" ]; then
  echo "ERROR: Structurizr is not responding after restart" >&2
  exit 1
fi
API_KEY=$(echo "$PAGE" | grep -A6 'StructurizrApiClient(' | sed -n '4p' | grep -oP '"[^"]*"' | tr -d '"')
API_SECRET=$(echo "$PAGE" | grep -A6 'StructurizrApiClient(' | sed -n '5p' | grep -oP '"[^"]*"' | tr -d '"')

if [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "ERROR: Failed to extract API keys from Structurizr" >&2
  exit 1
fi

# --- Call API with HMAC authorization ---
NONCE=$(date +%s%3N)
CONTENT_MD5="d41d8cd98f00b204e9800998ecf8427e"
CONTENT="GET
/api/workspace/1
${CONTENT_MD5}

${NONCE}
"

HMAC_HEX=$(printf '%s' "$CONTENT" | openssl dgst -sha256 -hmac "$API_SECRET" -hex 2>/dev/null | sed 's/^.* //')
HMAC_B64=$(printf '%s' "$HMAC_HEX" | base64 -w0)
MD5_B64=$(printf '%s' "$CONTENT_MD5" | base64 -w0)

RESPONSE=$(curl -s \
  -H "Content-MD5: ${MD5_B64}" \
  -H "Nonce: ${NONCE}" \
  -H "X-Authorization: ${API_KEY}:${HMAC_B64}" \
  "${STRUCTURIZR_BASE}/api/workspace/1")

# --- Check result ---
# Successful response contains JSON with "model" field, error — "success":false field
if echo "$RESPONSE" | grep -q '"success":false'; then
  # Extract error message via Python (reliable JSON parsing)
  ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','unknown error'))" 2>/dev/null || echo "$RESPONSE")
  echo "DSL ERROR: ${ERROR_MSG}" >&2
  exit 1
fi

if echo "$RESPONSE" | grep -q '"model"'; then
  echo "DSL is valid."
  exit 0
fi

echo "WARNING: Unexpected API response. Check manually." >&2
echo "$RESPONSE" | head -c 500 >&2
exit 1
