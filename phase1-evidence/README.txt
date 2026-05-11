=== Phase 1 Evidence Package ===
AIU Capstone Project: Integrated SOC Laboratory
Date: March 17, 2026
Student: Amr Hamada

--- CONTENTS ---

elastic/
  docker-ps.txt         - Container status for Elastic Stack (es01, es02, es03, Kibana, Logstash)
  cluster-health.json   - Elasticsearch cluster health API response (green, 3 nodes, 100%)
  indices.txt           - All indices with document counts (includes logs-000001 and zeek-2026.03.17)

wazuh/
  README.txt            - Instructions for Wazuh evidence capture; Wazuh requires Elastic stopped first
                          (port 9200 conflict). Screenshots to be added here.

gvm/
  docker-ps.txt         - Container status for OpenVAS/GVM (18+ containers including DVWA)

zeek/
  conn.log              - Live Zeek connection log in JSON format (from zeek/logs/current/)
  conn-sample.json      - Sample structured Zeek conn records
  elasticsearch-proof.json - Elasticsearch query result showing zeek-2026.03.17 index with hits
  zeek-status.txt       - Zeek container status and conn.log preview

--- PLATFORMS ---
Elastic Stack 8.17.1    https://localhost:5601   elastic / SecurePassword123!
Wazuh 4.9.0             https://localhost        admin / SecretPassword
OpenVAS/GVM 26.19.0     https://localhost:8443   admin / GvmLab@2026!
Zeek NSM                (no auth - ships to Elastic)
