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
  echo "compose.yaml not found. Run ./setup-gvm.sh first."
  exit 1
fi

echo "Checking feed sync method in gvmd container..."
if ${DOCKER_CMD} compose -f "${COMPOSE_FILE}" exec -T -u gvmd gvmd sh -lc 'command -v greenbone-feed-sync >/dev/null 2>&1'; then
  echo "Triggering manual feed synchronization inside gvmd..."
  ${DOCKER_CMD} compose -f "${COMPOSE_FILE}" exec -u gvmd gvmd greenbone-feed-sync
else
  echo "greenbone-feed-sync command not present in this image."
  echo "Feed data is synchronized by the Greenbone data containers and gvmd startup jobs."
  echo "Showing recent feed-related logs instead:"
  ${DOCKER_CMD} compose -f "${COMPOSE_FILE}" logs --tail=120 gvmd ospd-openvas
fi

echo
echo "Feed sync command executed. Track progress with:"
echo "${DOCKER_CMD} compose -f \"${COMPOSE_FILE}\" logs -f gvmd ospd-openvas"
