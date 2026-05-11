# MISP Threat Intelligence Lab

This lab uses the official MISP Docker images to stand up a working threat-intelligence platform for IOC ingestion, event handling, module enrichment, API automation, and backups.

## What it includes

- MISP core and MISP modules
- MariaDB and Redis
- A mail sink for demo notifications
- A post-start customization script
- CSV import, REST export, feed refresh, and backup helpers

## Quick Start

1. Start from the lab directory.
2. Make the helper scripts executable once.
3. Bring the stack up with Docker Compose.
4. Log in at `https://localhost:8444` with `admin@admin.test` and `LabPass!2024`.

```bash
cd misp/lab
chmod +x scripts/*.sh backup/*.sh
docker compose pull
docker compose up -d
```

## Demo Flow

1. Open MISP and show the default organization and admin account.
2. Create or open a test event and bulk import the sample IOCs from `data/iocs.csv`.
3. Use the API export helper to pull the event back out as JSON or CSV.
4. Show the maintenance script that refreshes galaxies, taxonomies, warning lists, and object templates.
5. Run the backup script and point to the generated archive.

## Automation Helpers

- `scripts/customize_misp.sh`: waits for the instance, sets core settings, and applies the lab admin password.
- `scripts/import_iocs.py`: creates a test event and imports attributes from CSV.
- `scripts/export_iocs.py`: exports an event from the REST API.
- `scripts/refresh_feeds.sh`: runs the built-in MISP maintenance updates.
- `backup/backup_misp.sh`: captures the database and mounted lab state.

## Notes

- The container startup behavior is aligned with the upstream `misp-docker` model: environment variables are enforced at startup, the modules service is separate, and the customize script is executed after MISP initialization.
- Advanced correlation can be enabled from the MISP Server Settings UI if you want to demonstrate the toggle live during the presentation.
