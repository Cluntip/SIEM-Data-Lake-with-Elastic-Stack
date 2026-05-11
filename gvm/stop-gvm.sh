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

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose.yaml not found. Nothing to stop."
  exit 0
fi

${DOCKER_CMD} compose -f "${COMPOSE_FILE}" down

echo
echo "Greenbone stack stopped."
echo "To remove all GVM data volumes too:"
echo "${DOCKER_CMD} compose -f \"${COMPOSE_FILE}\" down -v"
