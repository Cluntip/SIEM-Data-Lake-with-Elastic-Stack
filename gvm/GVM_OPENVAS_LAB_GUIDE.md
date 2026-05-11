# Vulnerability Management with OpenVAS (GVM)

This guide integrates Greenbone Vulnerability Management into this project as a third security module, alongside Elastic Stack SIEM and Wazuh.

## Objective

Deploy and operate Greenbone Community Edition (GVM/OpenVAS) in Docker, run vulnerability scans on authorized lab targets, and export actionable reports.

## Integration Design

- GVM module path: `gvm/`
- Isolation: Separate compose stack and volumes
- Port conflict handling:
  - Wazuh uses `443`
  - GVM remapped to `https://127.0.0.1:8443`
- Lab target container: `web-dvwa` on `127.0.0.1:8085`

## Lab Requirements

- RAM: 8GB minimum (12GB+ recommended when other stacks run)
- Disk: 20GB minimum free space
- Docker + Docker Compose plugin
- Linux or Windows host (this integration is optimized for Linux shell scripts)

## Task Breakdown and Execution

### 1. Containerized Infrastructure Deployment

1. `cd gvm`
2. `chmod +x *.sh`
3. `./setup-gvm.sh`
4. Validate running services:
   - `./status-gvm.sh`

Expected:
- Official Greenbone compose downloaded to `gvm/compose.yaml`
- Containers start successfully
- GVM URL available at `https://127.0.0.1:8443`

### 2. Configuration and Feed Synchronization

1. Set admin password immediately:
   - `./reset-admin-password.sh 'StrongPassword!123'`
2. Trigger feed sync:
   - `./sync-feeds.sh`
3. Monitor feed progress:
   - `docker compose -f compose.yaml logs -f gvmd ospd-openvas`

Expected:
- Feed jobs complete without persistent errors
- Scan configs and NVT data available in UI

### 3. Target Environment Setup

1. Deploy lab target:
   - `./deploy-targets.sh`
2. Get target IP for scanner target definition:
   - `docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-dvwa`

Expected:
- `web-dvwa` running
- Reachable from GVM network

### 4. Vulnerability Scanning Operations

1. Open browser:
   - `https://127.0.0.1:8443`
2. Login with `admin` and your password.
3. Create target in GSA:
   - Name: `DVWA Target`
   - Hosts: `<dvwa_container_ip>`
   - Port list: `All IANA assigned TCP`
4. Create task:
   - Name: `DVWA Full and Fast`
   - Scan Config: `Full and fast`
   - Target: `DVWA Target`
5. Start task and monitor to completion.

Expected:
- Task status reaches `Done`
- Vulnerabilities appear with severity ratings

### 5. Reporting and Scheduling

1. Open report for completed task.
2. Filter by severity:
   - Critical
   - High
   - Medium
   - Low
3. Export report format:
   - PDF, CSV, or XML
4. Configure schedule for recurring scans (e.g., daily/weekly).

Expected:
- Final report file generated and downloaded
- Schedule saved successfully

## Completion Criteria Checklist

- [ ] Docker installed and GVM containers running
- [ ] GSA accessible at `https://127.0.0.1:8443`
- [ ] Admin login successful
- [ ] Feed synchronization completed
- [ ] Target defined
- [ ] Scan executed successfully
- [ ] Findings visible by severity
- [ ] Report exported (PDF/CSV/XML)
- [ ] Automated schedule configured
- [ ] Environment cleanup performed

## Operational Commands

- Start/update GVM: `./setup-gvm.sh`
- Refresh compose from official source: `./setup-gvm.sh --refresh`
- Show status: `./status-gvm.sh`
- Sync feeds: `./sync-feeds.sh`
- Deploy target: `./deploy-targets.sh`
- Stop stack: `./stop-gvm.sh`
- Full cleanup: `./cleanup-gvm.sh`

## Cleanup

1. Stop stack:
   - `./stop-gvm.sh`
2. Full lab reset:
   - `./cleanup-gvm.sh`

## Troubleshooting

### UI not reachable
- Confirm bound port with `docker compose -f compose.yaml ps`
- Check reverse proxy logs:
  - `docker compose -f compose.yaml logs nginx gsad`

### Feed sync takes very long
- First run can take significant time.
- Monitor:
  - `docker compose -f compose.yaml logs -f gvmd ospd-openvas`

### Port conflict
- If `8443` in use, run setup with environment override:
  - `GVM_WEB_PORT=9443 ./setup-gvm.sh --refresh`

### Resource pressure
- Stop Elastic/Wazuh while syncing/scanning:
  - `bash stop.sh`
  - `cd wazuh/single-node && sudo docker-compose down`

## Security Notes

- Use only authorized targets.
- Keep DVWA confined to localhost/lab network.
- Rotate default credentials.
- Do not expose GVM externally without hardening.

## References

- Greenbone Community Containers:
  - https://greenbone.github.io/docs/latest/22.4/container/index.html
- OpenVAS Scanner:
  - https://github.com/greenbone/openvas-scanner
- Greenbone Community Portal:
  - https://community.greenbone.net/
