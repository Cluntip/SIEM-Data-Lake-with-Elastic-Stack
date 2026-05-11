#!/usr/bin/env bash
set -euo pipefail

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

if [[ -f "${COMPOSE_FILE}" ]]; then
  ${DOCKER_CMD} compose -f "${COMPOSE_FILE}" down -v || true
fi

# Remove target lab container if present.
${DOCKER_CMD} rm -f web-dvwa >/dev/null 2>&1 || true

echo "Pruning unused Docker objects (volumes, networks, images not in use)..."
${DOCKER_CMD} system prune -f

echo "Cleanup complete."
