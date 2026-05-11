#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
NEW_PASSWORD="${1:-}"

DOCKER_CMD="docker"
if ! docker ps >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
  else
    echo "Error: Docker is installed but not accessible and sudo is unavailable." >&2
    exit 1
  fi
fi

if [[ -z "${NEW_PASSWORD}" ]]; then
  echo "Usage: ./reset-admin-password.sh '<new-password>'"
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose.yaml not found. Run ./setup-gvm.sh first."
  exit 1
fi

${DOCKER_CMD} compose -f "${COMPOSE_FILE}" exec -u gvmd gvmd \
  gvmd --user=admin --new-password="${NEW_PASSWORD}"

echo "Admin password updated."
