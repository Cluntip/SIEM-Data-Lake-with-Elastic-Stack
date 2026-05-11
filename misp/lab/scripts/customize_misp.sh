#!/usr/bin/env bash
set -euo pipefail

base_url="${BASE_URL:-https://localhost:8444}"
admin_password="${ADMIN_PASSWORD:-LabPass!2024}"
admin_email="${ADMIN_EMAIL:-admin@admin.test}"
admin_org="${ADMIN_ORG:-SIEM Threat Lab}"
modules_url="${MISP_MODULES_FQDN:-http://misp-modules:6666}"

wait_for_misp() {
  echo "Waiting for MISP to answer on ${base_url}..."
  until curl -ks "${base_url}/users/heartbeat" >/dev/null; do
    sleep 5
  done
}

run_cake() {
  sudo -u www-data /var/www/MISP/app/Console/cake "$@"
}

set_setting() {
  local name="$1"
  local value="$2"
  run_cake Admin setSetting -q "$name" "$value" >/dev/null
}

wait_for_misp
cd /var/www/MISP

set_setting "MISP.org" "$admin_org"
set_setting "MISP.live" true
set_setting "MISP.log_auth" true
set_setting "Plugin.Enrichment_services_url" "$modules_url"
set_setting "Plugin.Import_services_url" "$modules_url"
set_setting "Plugin.Export_services_url" "$modules_url"
set_setting "SimpleBackgroundJobs.enabled" true
set_setting "SimpleBackgroundJobs.supervisor_host" "127.0.0.1"
set_setting "SimpleBackgroundJobs.supervisor_port" "9001"
set_setting "SimpleBackgroundJobs.supervisor_password" "supervisor"
set_setting "SimpleBackgroundJobs.redis_host" "redis"
set_setting "SimpleBackgroundJobs.redis_port" "6379"
set_setting "Security.require_password_confirmation" false

run_cake user change_pw 1 "$admin_password" >/dev/null
run_cake Admin live 1 >/dev/null

echo "MISP customization complete for ${admin_email}"
