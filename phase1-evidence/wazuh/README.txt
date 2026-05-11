=== Wazuh Evidence Note ===
Date: Tue Mar 17 2026

Wazuh cannot run simultaneously with Elastic Stack because both bind to port 9200.
For screenshot capture, start Wazuh after stopping Elastic Stack:

  cd /path/to/project && bash stop.sh
  cd wazuh/single-node && sudo docker-compose up -d

Wazuh access:
  Dashboard: https://localhost (port 443)
  Credentials: admin / SecretPassword

Wazuh containers (single-node):
  wazuh.manager
  wazuh.indexer
  wazuh.dashboard

Evidence to capture when running:
  - sudo docker-compose ps  (in wazuh/single-node/)
  - Wazuh dashboard with active agents and security events
  - Wazuh API: POST https://localhost:55000/security/user/authenticate
