#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if docker info >/dev/null 2>&1; then
  DC=(docker compose)
else
  DC=(sudo docker compose)
fi

mkdir -p logs/current evidence pcap

"${DC[@]}" up --build -d --remove-orphans

echo
echo "Zeek stack started."
echo "- Status: ./status-zeek.sh"
echo "- conn.log: zeek/logs/current/conn.log"
echo "- Evidence: ./collect-evidence.sh"