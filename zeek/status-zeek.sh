#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if docker info >/dev/null 2>&1; then
  DC=(docker compose)
else
  DC=(sudo docker compose)
fi

"${DC[@]}" ps

echo
if [ -s logs/current/conn.log ]; then
  echo "Sample conn.log lines:"
  head -n 5 logs/current/conn.log
else
  echo "conn.log not populated yet. Wait a few seconds and rerun."
fi