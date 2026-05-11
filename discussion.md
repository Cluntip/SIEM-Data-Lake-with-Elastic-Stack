# Phase 2 Discussion Runbook

This is the short version for the discussion. Use it as a quick checklist, not a full lab procedure.

## 0. Setup before the discussion

Run these first so everything is open before you start presenting:

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack"
bash setup.sh
```

Wait until the setup finishes, then open or refresh these pages in separate tabs:

- Kibana: http://localhost:5610
- SOC Overview Dashboard: http://localhost:5610/app/dashboards#/view/ef21e77d-dde6-4434-977a-b63cd0b27f09
- Saved Objects: http://localhost:5601/app/management/kibana/objects
- TheHive: http://localhost:9000
- OpenVAS: https://localhost:8443
- MISP: https://localhost:8444
- MISP HTTP fallback: http://localhost:8082

If a page asks you to log in or shows a certificate warning, keep the page open and continue:

- Kibana uses `elastic / SecurePassword123!`
- OpenVAS may show an HTTPS warning before the login page
- TheHive and MISP should be reachable as browser tabs before you start

## 🔐 Credentials (lab)

Use these credentials during the short discussion. Keep this file local — these are lab-only secrets.

| Platform | Service | URL | Username | Password |
|----------|---------|-----|----------|----------|
| Elastic Stack | Kibana (UI) | http://localhost:5610 | `elastic` | `SecurePassword123!` |
| Elastic Stack | Elasticsearch API | https://localhost:9210 | `elastic` | `SecurePassword123!` |
| Wazuh | Dashboard | https://localhost:9443 | `admin` | `SecretPassword` |
| Wazuh | API | https://localhost:55000 | `wazuh-wui` | `MyS3cr37P450r.*-` |
| OpenVAS / GVM | GSA Web UI | https://127.0.0.1:8443 | `admin` | `GvmLab@2026!` |
| DVWA (scan target) | Web UI | http://127.0.0.1:8085 | `admin` | `password` |
| TheHive | Web UI / Admin | http://localhost:9000 | `admin@thehive.local` | `secret` |
| TheHive | API Key (admin) | TheHive > Account > API | `admin` | (see admin UI to copy API key) |
| MISP | Web UI (HTTPS) | https://localhost:8444 | `admin@admin.test` | `LabPass!2024` |
| MISP | Web UI (HTTP fallback) | http://localhost:8082 | `admin@admin.test` | `LabPass!2024` |
| MISP | MySQL (container) | (internal) | `misp` | `mispdemo` |
| MISP | MySQL root | (internal) | `root` | `changeit-root` |

Notes:
- If you changed any passwords during initial setup, use the updated values (check `README.md` or module-specific scripts).
- TheHive admin API key must be copied from the admin UI (avoid storing API keys in plaintext files).
- If OpenVAS GSA password was reset during first-run, run `./reset-admin-password.sh` in `gvm` and update this file accordingly.


## 1. Open the project and prove the lab exists

Start from the project root and mention the key UIs:

- Kibana: http://localhost:5610
- TheHive: http://localhost:9000
- OpenVAS: https://localhost:8443
- MISP: https://localhost:8444

If asked, the default Elastic login is `elastic / SecurePassword123!`.

## 2. Show the three required detections in Kibana

Open Kibana Security > Detections > Rules and point to these rules:

- Suspicious Process Accessing LSASS
- Mass File Encryption Detection
- Suspicious PowerShell Download and Execute

Say that they cover credential theft, ransomware-style encryption, and PowerShell abuse.

## 3. Show the dashboard is not empty

Open the SOC Overview Dashboard and show the visible panels and title.

Use the verified fallback dashboard if needed:

- SOC Overview Dashboard
- Kibana rules are live
- Dashboard is visible
- OpenVAS, TheHive, and MISP are the related tools for the demo

## 4. Show vulnerability handling

Open OpenVAS/GVM at https://localhost:8443 and show that it reaches the login page.

If the browser shows a certificate warning, just note it and continue.

## 5. Show incident response structure

Open TheHive at http://localhost:9000 if it is available.

Show the case template and point out the three playbook stages:

- Contain
- Investigate
- Communicate

## 6. Close with the one-line story

Say the flow is:

- detect in Elastic
- confirm in Kibana
- prioritize vulnerabilities in OpenVAS
- document response in TheHive

## 7. If asked about caveats

Mention only the truth from the validation pass:

- TheHive and MISP were not reachable during that session
- the fallback SOC dashboard is the one to show live
