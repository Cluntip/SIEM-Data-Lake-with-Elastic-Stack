#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_dir="${lab_dir}/backup"
timestamp="$(date +%Y%m%d-%H%M%S)"
archive_path="${backup_dir}/thehive-lab-${timestamp}.tar.gz"

if [[ -f "${lab_dir}/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${lab_dir}/.env"
  set +a
fi

mkdir -p "${backup_dir}"

docker compose -f "${lab_dir}/docker-compose.yml" exec -T \
  -e MARIADB_ROOT_PASSWORD="${MISP_DB_ROOT_PASSWORD:-changeit-root}" \
  -e MARIADB_DATABASE="${MISP_DB_NAME:-misp}" \
  misp-db sh -lc '
  mariadb-dump -uroot -p"${MARIADB_ROOT_PASSWORD}" "${MARIADB_DATABASE}"
' > "${backup_dir}/misp-db-${timestamp}.sql"

tar -czf "${archive_path}" \
  -C "${lab_dir}" \
  .env \
  config \
  volumes \
  scripts \
  data \
  backup/misp-db-${timestamp}.sql

echo "Created ${archive_path}"
