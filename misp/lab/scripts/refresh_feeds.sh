#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_dir="$(cd "${script_dir}/.." && pwd)"

docker compose -f "${lab_dir}/docker-compose.yml" exec -T misp-core bash -lc '
  cd /var/www/MISP &&
  ./app/Console/cake Admin updateGalaxies &&
  ./app/Console/cake Admin updateTaxonomies &&
  ./app/Console/cake Admin updateWarningLists &&
  ./app/Console/cake Admin updateNoticeLists &&
  ./app/Console/cake Admin updateObjectTemplates
'
