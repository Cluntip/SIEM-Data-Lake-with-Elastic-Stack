#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$SCRIPT_DIR"

echo "Building Zeek lab image..."
docker build -t zeek-lab:latest "$LAB_DIR"

echo "Creating required directories if missing"
mkdir -p "$LAB_DIR/logs"
mkdir -p "$LAB_DIR/pcaps"

echo "Starting Zeek lab via docker-compose"
docker compose -f "$LAB_DIR/docker-compose.yml" up -d

echo "Zeek lab started. Use ./status-zeek-lab.sh to check logs and status."
