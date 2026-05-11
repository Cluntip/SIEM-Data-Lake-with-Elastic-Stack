#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR="$SCRIPT_DIR/evidence"
mkdir -p "$OUTDIR"

echo "Copying logs to $OUTDIR"
cp -r "$SCRIPT_DIR/logs" "$OUTDIR/" || true
if docker ps --filter ancestor=zeek-lab -q | grep -q .; then
  echo "Zeek container running; fetching live logs (docker logs)..."
  docker compose -f "$SCRIPT_DIR/docker-compose.yml" logs --no-color > "$OUTDIR/docker-logs.txt" || true
fi

echo "Evidence copied to $OUTDIR"
