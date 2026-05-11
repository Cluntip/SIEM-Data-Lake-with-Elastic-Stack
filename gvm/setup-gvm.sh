#!/usr/bin/env bash
set -euo pipefail

# Greenbone Community Edition setup for this lab.
# Downloads the official compose file and applies local port overrides.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
COMPOSE_URL="https://greenbone.github.io/docs/latest/_static/compose.yaml"

GVM_WEB_PORT="${GVM_WEB_PORT:-8443}"
GVM_GMP_PORT="${GVM_GMP_PORT:-9392}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed or not in PATH." >&2
  exit 1
fi

DOCKER_CMD="docker"
if ! docker ps >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
  else
    echo "Error: Docker is installed but not accessible and sudo is unavailable." >&2
    exit 1
  fi
fi

if ! ${DOCKER_CMD} compose version >/dev/null 2>&1; then
  echo "Error: docker compose plugin is required." >&2
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" || "${1:-}" == "--refresh" ]]; then
  echo "[1/5] Downloading Greenbone compose file..."
  curl -fsSL "${COMPOSE_URL}" -o "${COMPOSE_FILE}"
else
  echo "[1/5] Using existing compose file: ${COMPOSE_FILE}"
fi

echo "[2/5] Applying local port mapping overrides..."
# Avoid conflict with Wazuh dashboard on 443.
sed -i 's/127.0.0.1:443:443/127.0.0.1:'"${GVM_WEB_PORT}"':443/g' "${COMPOSE_FILE}"
sed -i 's/127.0.0.1:9392:9392/127.0.0.1:'"${GVM_GMP_PORT}"':9392/g' "${COMPOSE_FILE}"

echo "[3/5] Pulling images (first run can take time)..."
${DOCKER_CMD} compose -f "${COMPOSE_FILE}" pull

echo "[4/5] Starting Greenbone stack..."
${DOCKER_CMD} compose -f "${COMPOSE_FILE}" up -d

echo "[5/5] Showing running services..."
${DOCKER_CMD} compose -f "${COMPOSE_FILE}" ps

echo
echo "GVM should be available at: https://127.0.0.1:${GVM_WEB_PORT}"
echo "Default admin user exists; set a strong password with:"
echo "${DOCKER_CMD} compose -f \"${COMPOSE_FILE}\" exec -u gvmd gvmd gvmd --user=admin --new-password='ChangeMeNow!'"
echo
echo "Tip: Feed sync may take time on first run; monitor with:"
echo "${DOCKER_CMD} compose -f \"${COMPOSE_FILE}\" logs -f gvmd ospd-openvas"
