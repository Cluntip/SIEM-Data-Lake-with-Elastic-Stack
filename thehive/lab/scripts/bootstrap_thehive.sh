#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${lab_dir}/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${lab_dir}/.env"
  set +a
fi

wait_for_url() {
  local label="$1"
  local url="$2"
  echo "Waiting for ${label} at ${url}..."
  until curl -ksS "${url}" >/dev/null; do
    sleep 5
  done
}

wait_for_url "MISP" "http://localhost:${MISP_HTTP_PORT:-8082}/users/heartbeat"
wait_for_url "TheHive" "http://localhost:${THEHIVE_PORT:-9000}"

echo "Services are responding."
echo "If MISP_API_KEY is still empty, open MISP, generate the API key, set it in .env, and restart TheHive."
echo "TheHive: http://localhost:${THEHIVE_PORT:-9000}"
echo "MISP: http://localhost:${MISP_HTTP_PORT:-8082}"
echo "Kibana: http://localhost:${KIBANA_PORT:-5630}"
