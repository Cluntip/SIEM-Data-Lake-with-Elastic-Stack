# Phase 2 Report — Building a Risk-Driven SOC (AIU)

Project: Phase 2 — SOC Implementation & Operations

Executive summary

This document walks through the implemented detection rules, Kibana dashboard, TheHive playbook, and vulnerability integration. It includes a hypothetical incident walkthrough from detection to case closure.

1) Custom detections

- Suspicious Process Accessing LSASS (EQL)
- Mass File Encryption Detection (Query threshold)
- Suspicious PowerShell Download and Execute (EQL)

2) SOC Dashboard

Contains real-time alert count, top alerted hosts, alerts by severity timeline, and OpenVAS vulnerabilities.

3) Incident Response Playbook

Contain: isolate host with Wazuh active response.
Investigate: use Kibana Timeline to reconstruct chain.
Communicate: use TheHive email template to notify CISO.

4) Vulnerability Management

OpenVAS scheduled scans (script included) and a Lens visualization for critical/high vulnerabilities by asset criticality.

5) Walkthrough (Hypothetical)

Detection: Mass File Encryption rule triggers an alert for host HOST-123 with 120 .encrypted renames within 1 minute.
Investigation: Use Kibana Timeline to search logs-endpoint.events.* for the host, ingest process/file network events, identify PID and initial vector (Phishing -> PowerShell encoded payload).
Containment: Use Wazuh `agent_control` to isolate server network.
Case Management: Create TheHive case from the detection; the case template pre-populates the steps and tasks.

6) Deliverables

- Detection rule JSON files (artifacts/phase2/detection_rules)
- Kibana saved objects (artifacts/phase2/kibana_saved_objects/soc_overview.ndjson)
- Lens saved object (artifacts/phase2/lens/vuln_lens.ndjson)
- TheHive case template (artifacts/phase2/thehive/case_template.json)
- OpenVAS schedule placeholder script (artifacts/phase2/openvas/schedule_scan.sh)

References and appendices: include screenshots and exported objects.
