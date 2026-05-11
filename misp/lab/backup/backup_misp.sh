#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_dir="$(cd "${script_dir}/.." && pwd)"
backup_dir="${lab_dir}/backup"
timestamp="$(date +%Y%m%d-%H%M%S)"
archive_path="${backup_dir}/misp-backup-${timestamp}.tar.gz"

if [[ -f "${lab_dir}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${lab_dir}/.env"
  set +a
fi

mkdir -p "${backup_dir}"

docker compose -f "${lab_dir}/docker-compose.yml" exec -T \
  -e MARIADB_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
  -e MARIADB_DATABASE="${MYSQL_DATABASE}" \
  db sh -lc '
  mariadb-dump -uroot -p"${MARIADB_ROOT_PASSWORD}" "${MARIADB_DATABASE}"
' > "${backup_dir}/misp-db-${timestamp}.sql"

tar -czf "${archive_path}" \
  -C "${lab_dir}" \
  .env \
  config \
  files \
  gnupg \
  logs \
  scripts \
  data \
  backup/misp-db-${timestamp}.sql

echo "Created ${archive_path}"
