#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Zeek lab directory: $SCRIPT_DIR"

echo
echo "Local logs (tail):"
ls -la "$SCRIPT_DIR/logs" || true
tail -n 40 "$SCRIPT_DIR/logs"/* 2>/dev/null || true

echo
echo "Docker processes (filter by zeek):"
docker ps --filter ancestor=zeek-lab -a || true
