#!/usr/bin/env bash
set -euo pipefail

# Deploys intentionally vulnerable target container for lab-only scanning.
# Do not expose this container to untrusted networks.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"

DOCKER_CMD="docker"
if ! docker ps >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
  else
    echo "Error: Docker is installed but not accessible and sudo is unavailable." >&2
    exit 1
  fi
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose.yaml not found. Run ./setup-gvm.sh first."
  exit 1
fi

# Ensure GVM stack is started (network creation).
${DOCKER_CMD} compose -f "${COMPOSE_FILE}" up -d >/dev/null

NETWORK_NAME="$(${DOCKER_CMD} network ls --format '{{.Name}}' | grep -E '^greenbone-community-edition_default$|^gvm_default$' | head -n1 || true)"
if [[ -z "${NETWORK_NAME}" ]]; then
  # Fallback: pick the most recent network containing 'greenbone' and '_default'.
  NETWORK_NAME="$(${DOCKER_CMD} network ls --format '{{.Name}}' | grep 'greenbone' | grep '_default' | head -n1 || true)"
fi

if [[ -z "${NETWORK_NAME}" ]]; then
  echo "Could not determine GVM docker network." >&2
  exit 1
fi

${DOCKER_CMD} rm -f web-dvwa >/dev/null 2>&1 || true
${DOCKER_CMD} run -d \
  --name web-dvwa \
  --network "${NETWORK_NAME}" \
  -p 127.0.0.1:8085:80 \
  vulnerables/web-dvwa

echo "DVWA deployed as target."
echo "Container: web-dvwa"
echo "Host URL: http://127.0.0.1:8085"
echo "Scan target IP suggestion: resolve with 'docker inspect -f {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}} web-dvwa'"
