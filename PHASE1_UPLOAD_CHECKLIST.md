# Phase 1 Upload Checklist (AIU Capstone)

## What You Must Upload

## 1. Single PDF Report (Required)

Generate one PDF from `PHASE1_REPORT_DRAFT.md` (or equivalent) that contains:

- Risk Register and NIST CSF Control Mapping table.
- SOC Architecture Diagram with data flows.
- Data Source Onboarding Plan.
- Stand-alone working edition evidence section (Elastic, Wazuh, OpenVAS, Zeek).

Minimum PDF sections:
1. Executive Summary
2. Top 5 Risks + Control Mapping
3. Architecture Diagram
4. Data Source Onboarding Plan
5. Platform Evidence
6. Conclusion

## 2. Stand-Alone Working Edition Evidence (Required by Assignment)

Attach either screenshots in the PDF or a supplemental ZIP with evidence files.

### Elastic Stack Evidence
- `docker ps` output showing ES/Kibana/Fleet containers.
- Kibana screenshot with ingested logs.
- Cluster health output (`_cluster/health`).

### Wazuh Evidence
- `wazuh/single-node` `docker-compose ps` output.
- Wazuh dashboard screenshot with alerts/events.
- Wazuh API auth and sample result.

### OpenVAS/GVM Evidence
- `gvm/status-gvm.sh` output or `docker compose ps`.
- GSA login/dashboard screenshot.
- Scan task/report screenshot (example: DVWA scan findings).

### Zeek Evidence
- `zeek/status-zeek.sh` output showing the Zeek containers running.
- `zeek/logs/current/conn.log` with sample JSON connection records.
- `zeek/evidence/elasticsearch-proof.json` showing hits in `zeek-*`.

Current implementation paths:
- `zeek/setup-zeek.sh`
- `zeek/status-zeek.sh`
- `zeek/collect-evidence.sh`
- `zeek/logs/current/conn.log`
- `zeek/evidence/zeek-status.txt`
- `zeek/evidence/conn-sample.json`
- `zeek/evidence/elasticsearch-proof.json`

## 3. Suggested Submission Package Structure

If your instructor allows multiple files:

- `Phase1_AIU_SOC_Report.pdf` (required)
- `phase1-evidence.zip` (recommended)

Inside `phase1-evidence.zip`:
- `elastic/` screenshots + health outputs
- `wazuh/` screenshots + API outputs
- `gvm/` screenshots + scan evidence
- `zeek/` screenshots + conn log + ingest proof

## 4. Platform Readiness Before Final Submission

Current repo confirms:
- Elastic Stack: ready
- Wazuh: ready
- OpenVAS/GVM: ready
- Zeek: ready

Before final upload, refresh the platform evidence so the screenshots and JSON proof files are current:
- `bash status.sh`
- `cd wazuh/single-node && sudo docker-compose ps`
- `cd gvm && ./status-gvm.sh`
- `cd zeek && ./status-zeek.sh && ./collect-evidence.sh`

## 5. Final Pre-Upload Quality Check

- PDF includes all 3 required assignment deliverables.
- Risk table has 5 risks, each mapped to 3-5 NIST CSF controls.
- Architecture clearly shows data flow into Elasticsearch/Kibana.
- Onboarding plan includes all required sources:
  - Windows Security Events
  - Linux System Auth logs
  - Zeek conn logs
  - Wazuh alerts
  - OpenVAS results
- Evidence section proves platform operation.
- Zeek proof file shows hits in `zeek-*`.
- File names are clean and professional.
