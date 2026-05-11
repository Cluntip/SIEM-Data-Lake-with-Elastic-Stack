#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$SCRIPT_DIR"

if docker info >/dev/null 2>&1; then
  DC=(docker compose)
else
  DC=(sudo docker compose)
fi

mkdir -p evidence

"${DC[@]}" ps > evidence/zeek-status.txt

if [ ! -s logs/current/conn.log ]; then
  echo "conn.log is empty. Run ./setup-zeek.sh and wait for Zeek to finish processing." >&2
  exit 1
fi

head -n 10 logs/current/conn.log > evidence/conn-sample.json

LATEST_INDEX="$(curl -s -k -u elastic:SecurePassword123! \
  "https://localhost:9200/_cat/indices/zeek-*?h=index" | awk 'NF {print $1}' | tail -n 1)"

if [ -n "$LATEST_INDEX" ]; then
  curl -s -k -u elastic:SecurePassword123! \
    "https://localhost:9200/${LATEST_INDEX}/_search?pretty&size=5" \
    > evidence/elasticsearch-proof.json
else
  curl -s -k -u elastic:SecurePassword123! \
    "https://localhost:9200/zeek-*/_count?pretty" \
    > evidence/elasticsearch-proof.json
fi

echo "Evidence written to:"
echo "- zeek/evidence/zeek-status.txt"
echo "- zeek/evidence/conn-sample.json"
echo "- zeek/evidence/elasticsearch-proof.json"
echo
echo "If elasticsearch-proof.json shows count 0 or no hits, start Elastic with ../setup.sh and wait for Logstash ingestion."