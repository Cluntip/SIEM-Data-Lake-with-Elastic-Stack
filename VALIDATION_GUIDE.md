# 🔍 Complete Validation Guide - SIEM & Wazuh Setup

## Overview
This guide will walk you through validating BOTH projects:
1. **Elastic Stack SIEM & Data Lake** (Original project)
2. **Wazuh SIEM Endpoint Security** (New deployment)

---

## ✅ PART 1: ELASTIC STACK SIEM VALIDATION

### Step 1.1: Verify Elastic Stack Services

```bash
# Navigate to main project directory
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack"

# Check all services status
./status.sh
```

**Expected Output:**
- ✅ All 7 containers should be "healthy" or "running"
- es01, es02, es03 (Elasticsearch nodes)
- kibana01
- fleet-server
- logstash
- customer-api

**Validation Commands:**
```bash
# Check Elasticsearch cluster health
curl -k -u elastic:SecurePassword123! https://localhost:9200/_cluster/health?pretty

# Expected: "status" : "green" or "yellow", "number_of_nodes" : 3

# Check Kibana
curl http://localhost:5601/api/status

# Expected: HTTP 200, "state":"green"

# Test Customer API
curl http://localhost:8081/api/customers | jq

# Expected: JSON list of customers
```

### Step 1.2: Access Kibana Dashboard

1. **Open Browser**: http://localhost:5601
2. **Login**:
   - Username: `elastic`
   - Password: `SecurePassword123!`
3. **Verify**:
   - ✅ Dashboard loads successfully
   - ✅ No error messages
   - ✅ Left sidebar accessible

### Step 1.3: Verify Data Ingestion

**In Kibana:**
1. Navigate to **Discover** (left sidebar)
2. Select index pattern: `logs-*` or `customer-logs-*`
3. **Expected**:
   - ✅ Logs should appear (if simulate-events.sh was run)
   - ✅ Time range selector shows recent data
   - ✅ Field list populated on the left

**Command Line Check:**
```bash
# Check if indices exist
curl -k -u elastic:SecurePassword123! https://localhost:9200/_cat/indices?v

# Expected: See indices like customer-logs-*, logs-*, .fleet-*, etc.

# Count documents in customer logs
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/customer-logs-*/_count?pretty

# Expected: "count" > 0 (if data was generated)
```

### Step 1.4: Test Event Generation

```bash
# Generate test events
./simulate-events.sh

# Wait 30 seconds for processing
sleep 30

# Verify events in Kibana Discover
# Or check via API:
curl -k -u elastic:SecurePassword123! \
  "https://localhost:9200/customer-logs-*/_search?size=5&pretty"
```

### Step 1.5: Verify ILM Policies

**In Kibana:**
1. Go to **Management** → **Stack Management**
2. Click **Index Lifecycle Policies** (under Data)
3. **Expected**:
   - ✅ See `customer-logs-policy`
   - ✅ Phases: Hot, Warm, Cold, Delete configured

**Command Line:**
```bash
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_ilm/policy/customer-logs-policy?pretty
```

### Step 1.6: Verify Security Rules

**In Kibana:**
1. Go to **Security** → **Rules** (or **Alerts**)
2. **Expected to see**:
   - ✅ SSH Brute Force Detection
   - ✅ Multiple Failed Login Attempts
   - ✅ Suspicious Network Connections
   - ✅ Data Exfiltration Detection

### ✅ Elastic Stack Validation Checklist

- [ ] All 7 containers running
- [ ] Elasticsearch cluster health: green/yellow
- [ ] Kibana accessible and login successful
- [ ] Data visible in Discover
- [ ] Indices created (customer-logs-*)
- [ ] Events generated successfully
- [ ] ILM policies configured
- [ ] Security rules present

---

## ✅ PART 2: WAZUH SIEM VALIDATION

### Step 2.1: Verify Wazuh Infrastructure

```bash
# Navigate to Wazuh directory
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh"

# Check containers
cd single-node
sudo docker-compose ps
```

**Expected Output:**
```
NAME                            STATUS
single-node-wazuh.dashboard-1   Up (healthy)
single-node-wazuh.indexer-1     Up (healthy)
single-node-wazuh.manager-1     Up (healthy)
```

**Validation Commands:**
```bash
# Check all Wazuh containers
sudo docker ps | grep wazuh

# Expected: 3 containers running

# Check dashboard logs
sudo docker logs single-node-wazuh.dashboard-1 --tail 20

# Expected: No critical errors, "Server running at https://0.0.0.0:5601"

# Check manager logs
sudo docker logs single-node-wazuh.manager-1 --tail 20

# Expected: "wazuh-analysisd: INFO", "rootcheck scan finished"
```

### Step 2.2: Access Wazuh Dashboard

1. **Open Browser**: https://localhost:443
2. **Accept Certificate Warning**:
   - Click "Advanced"
   - Click "Proceed to localhost (unsafe)"
3. **Login**:
   - Username: `admin`
   - Password: `SecretPassword`
4. **Verify**:
   - ✅ Dashboard loads (may take 30-60 seconds first time)
   - ✅ Welcome screen or main dashboard visible
   - ✅ No critical errors

### Step 2.3: Verify API Authentication

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh"

# Get authentication token
TOKEN=$(curl -k -u wazuh-wui:'MyS3cr37P450r.*-' \
  -X POST 'https://localhost:55000/security/user/authenticate' 2>/dev/null | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)

echo "Token: ${TOKEN:0:50}..."

# Expected: Token displayed (JWT string starting with "eyJ...")

# List agents
curl -k -X GET "https://localhost:55000/agents?pretty=true" \
  -H "Authorization: Bearer $TOKEN" | head -30

# Expected: JSON response with manager agent (ID 000)
```

### Step 2.4: Verify Custom Detection Rules

```bash
# Check rules file exists
sudo docker exec single-node-wazuh.manager-1 \
  cat /var/ossec/etc/rules/local_rules.xml | head -30

# Expected: XML with custom rules (100100-100109)

# Verify manager loaded rules
sudo docker exec single-node-wazuh.manager-1 \
  /var/ossec/bin/wazuh-control info | grep -i rule

# Check for errors in manager logs
sudo docker logs single-node-wazuh.manager-1 2>&1 | grep -i "error\|critical" | tail -10

# Expected: No rule-related errors
```

### Step 2.5: Verify Rule Details

```bash
# Check specific custom rules are present
sudo docker exec single-node-wazuh.manager-1 \
  grep -A 5 "rule id=\"100100\"" /var/ossec/etc/rules/local_rules.xml

# Expected: PowerShell detection rule details

sudo docker exec single-node-wazuh.manager-1 \
  grep -A 5 "rule id=\"100101\"" /var/ossec/etc/rules/local_rules.xml

# Expected: EICAR malware detection rule

# List all custom rule IDs
sudo docker exec single-node-wazuh.manager-1 \
  grep "rule id=" /var/ossec/etc/rules/local_rules.xml

# Expected: Rules 100100-100109
```

### Step 2.6: Deploy Wazuh Agent (CRITICAL STEP)

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh"

# Deploy agent
./deploy-agents.sh

# Wait for deployment (2-3 minutes)
# Script will install Wazuh agent in Ubuntu container
```

**Expected Output:**
```
=== Wazuh Agent Deployment ===

[+] Deploying Ubuntu agent: wazuh-agent-linux-001
[+] Installing Wazuh agent in container
[+] Starting Wazuh agent service
[✓] Agent wazuh-agent-linux-001 deployed successfully

=== Agent Deployment Complete ===
```

**Verify Agent Connection:**
```bash
# Check agent status via manager
sudo docker exec single-node-wazuh.manager-1 \
  /var/ossec/bin/agent_control -l

# Expected: Agent listed with status "Active"

# Check agent logs
sudo docker logs wazuh-agent-linux-001 | tail -20

# Access agent container
sudo docker exec -it wazuh-agent-linux-001 /bin/bash
# Inside container:
# service wazuh-agent status
# exit
```

**In Wazuh Dashboard:**
1. Navigate to **Agents** (left sidebar)
2. **Expected**:
   - ✅ See agent "agent-linux-001"
   - ✅ Status: "Active" or "Online" (green)
   - ✅ Last Keep Alive: Recent timestamp

### Step 2.7: Run Threat Simulations

```bash
# Execute all threat scenarios
./simulate-threats.sh

# Wait 2-3 minutes for completion
```

**Expected Output:**
```
=== Wazuh Threat Simulation & Testing ===

=== 1. EICAR Malware Test ===
[✓] EICAR test files created

=== 2. File Integrity Monitoring Test ===
[✓] File integrity test completed

=== 3. Privilege Escalation Simulation ===
[✓] Privilege escalation simulation completed

=== 4. Suspicious Process Execution ===
[✓] Suspicious process simulation completed

=== 5. Suspicious File Download Simulation ===
[✓] Download simulation completed

=== 6. Log Injection Simulation ===
[✓] Log injection completed

=== 7. Rootkit Detection Simulation ===
[✓] Rootkit simulation completed

=== Simulation Complete ===
```

### Step 2.8: Verify Alert Detection

**Wait 5 minutes** after simulations for events to process, then:

**In Wazuh Dashboard:**
1. Go to **Security Events** or **Discover**
2. Set time range to "Last 1 hour"
3. **Search for alerts**:
   ```
   # In search bar, try these queries:
   rule.groups:"malware"
   rule.id:100101
   rule.level >= 10
   agent.name:"agent-linux-001"
   ```

**Expected to see:**
- ✅ Malware alerts (EICAR detection)
- ✅ File integrity alerts
- ✅ Privilege escalation alerts
- ✅ Various security events from simulations

**Command Line Verification:**
```bash
# Check manager alerts
sudo docker exec single-node-wazuh.manager-1 \
  tail -50 /var/ossec/logs/alerts/alerts.log

# Search for specific rule
sudo docker exec single-node-wazuh.manager-1 \
  grep "Rule: 100101" /var/ossec/logs/alerts/alerts.log | tail -5

# Expected: EICAR detection alerts
```

### Step 2.9: Verify MITRE ATT&CK Mapping

**In Wazuh Dashboard:**
1. Navigate to **Intelligence** → **MITRE ATT&CK**
2. **Expected**:
   - ✅ See tactics and techniques
   - ✅ Coverage for: T1059.001, T1068, T1046, T1105, T1564.001, T1110, T1070.006

**Query for MITRE techniques:**
```
rule.mitre.id:*
rule.mitre.id:"T1059.001"
rule.mitre.id:"T1068"
```

### ✅ Wazuh Validation Checklist

- [ ] All 3 containers running (indexer, manager, dashboard)
- [ ] Dashboard accessible at https://localhost:443
- [ ] API authentication successful (JWT token obtained)
- [ ] Custom rules file present (local_rules.xml)
- [ ] No rule errors in manager logs
- [ ] Agent deployed and visible
- [ ] Agent status: Active/Online
- [ ] Threat simulations executed successfully
- [ ] Alerts visible in dashboard
- [ ] EICAR malware detected (Rule 100101)
- [ ] MITRE ATT&CK mappings present

---

## ✅ PART 3: DOCUMENTATION VERIFICATION

### Step 3.1: Verify Documentation Files

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh"

# List all documentation
ls -lh *.md *.sh *.xml

# Expected files:
# - WAZUH_DEPLOYMENT_GUIDE.md
# - INVESTIGATION_GUIDE.md
# - PROJECT_COMPLETION_SUMMARY.md
# - QUICK_REFERENCE.md
# - COMPLETE_TASK_CHECKLIST.md
# - deploy-agents.sh
# - simulate-threats.sh
# - configure-rules.sh
# - local_rules.xml
```

### Step 3.2: Review Key Documentation

```bash
# Quick reference for commands
cat QUICK_REFERENCE.md | less

# Investigation guide for KQL queries
cat INVESTIGATION_GUIDE.md | less

# Deployment guide
cat WAZUH_DEPLOYMENT_GUIDE.md | less

# Complete checklist
cat COMPLETE_TASK_CHECKLIST.md | less
```

---

## ✅ PART 4: COMPREHENSIVE SYSTEM CHECK

### Final Validation Script

Create and run this comprehensive check:

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh"

cat > full-validation.sh << 'EOF'
#!/bin/bash
echo "=== COMPREHENSIVE VALIDATION ==="
echo ""

# Elastic Stack Check
echo "1. ELASTIC STACK STATUS:"
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack"
docker ps --filter "name=elk" --format "table {{.Names}}\t{{.Status}}" | head -8
echo ""

# Wazuh Check
echo "2. WAZUH STATUS:"
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/wazuh/single-node"
sudo docker-compose ps
echo ""

# Elasticsearch Health
echo "3. ELASTICSEARCH HEALTH:"
curl -sk -u elastic:SecurePassword123! https://localhost:9200/_cluster/health?pretty | grep -E "status|number_of_nodes"
echo ""

# Wazuh API
echo "4. WAZUH API:"
TOKEN=$(curl -sk -u wazuh-wui:'MyS3cr37P450r.*-' -X POST 'https://localhost:55000/security/user/authenticate' | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)
if [ -n "$TOKEN" ]; then
    echo "✅ API Authentication: SUCCESS"
else
    echo "❌ API Authentication: FAILED"
fi
echo ""

# Wazuh Agents
echo "5. WAZUH AGENTS:"
sudo docker exec single-node-wazuh.manager-1 /var/ossec/bin/agent_control -l 2>/dev/null || echo "Check manually"
echo ""

# Custom Rules
echo "6. CUSTOM RULES:"
RULES=$(sudo docker exec single-node-wazuh.manager-1 grep -c "rule id=" /var/ossec/etc/rules/local_rules.xml 2>/dev/null)
echo "Custom rules found: $RULES"
echo ""

echo "=== VALIDATION COMPLETE ==="
EOF

chmod +x full-validation.sh
./full-validation.sh
```

---

## 🎯 SUCCESS CRITERIA

### Elastic Stack SIEM ✅
- All 7 containers healthy
- Cluster health: green
- Kibana accessible
- Data ingesting
- Events generated
- ILM policies active

### Wazuh SIEM ✅
- All 3 containers healthy
- Dashboard accessible
- API responding
- Custom rules loaded (9 rules)
- Agent online
- Alerts detected
- MITRE mappings visible

---

## 🚨 TROUBLESHOOTING

### Elastic Stack Issues

**Issue**: Containers not starting
```bash
# Check logs
docker logs elk-es01-1
docker logs elk-kibana01-1

# Increase memory
docker-compose down
# Edit docker-compose.yml: increase ES_JAVA_OPTS to -Xms2g -Xmx2g
docker-compose up -d
```

**Issue**: Cluster health red
```bash
# Check cluster
curl -sk -u elastic:SecurePassword123! https://localhost:9200/_cluster/health?pretty

# Check unassigned shards
curl -sk -u elastic:SecurePassword123! https://localhost:9200/_cat/shards?h=index,shard,state,unassigned.reason
```

### Wazuh Issues

**Issue**: Dashboard not accessible
```bash
# Check logs
sudo docker logs single-node-wazuh.dashboard-1 --tail 50

# Restart dashboard
cd single-node
sudo docker-compose restart wazuh.dashboard
```

**Issue**: Agent not connecting
```bash
# Check agent logs
sudo docker logs wazuh-agent-linux-001

# Check manager listening
sudo docker exec single-node-wazuh.manager-1 netstat -tlnp | grep 1514

# Restart agent
sudo docker restart wazuh-agent-linux-001
```

**Issue**: Rules not loading
```bash
# Check for errors
sudo docker logs single-node-wazuh.manager-1 | grep -i "error\|critical"

# Verify XML syntax
sudo docker exec single-node-wazuh.manager-1 cat /var/ossec/etc/rules/local_rules.xml

# Restart manager
cd single-node
sudo docker-compose restart wazuh.manager
```

**Issue**: No alerts showing
```bash
# Check if agent is sending data
sudo docker exec single-node-wazuh.manager-1 tail -f /var/ossec/logs/alerts/alerts.log

# Re-run simulations
cd ..
./simulate-threats.sh

# Check alert count
sudo docker exec single-node-wazuh.manager-1 wc -l /var/ossec/logs/alerts/alerts.log
```

---

## 📊 EXPECTED RESULTS SUMMARY

After completing all validation steps:

### Port Usage
| Port | Service | Status |
|------|---------|--------|
| 5601 | Kibana (Elastic) | ✅ Running |
| 9200 | Elasticsearch | ✅ Running |
| 9300 | ES Transport | ✅ Running |
| 8081 | Customer API | ✅ Running |
| 443 | Wazuh Dashboard | ✅ Running |
| 55000 | Wazuh API | ✅ Running |
| 1514 | Wazuh Agent | ✅ Listening |

### Container Count
- **Elastic Stack**: 7 containers
- **Wazuh**: 3 containers + 1 agent
- **Total**: 11 containers running

### Data & Rules
- **Elastic**: ILM policies, index templates, security rules
- **Wazuh**: 9 custom detection rules with MITRE mappings
- **Events**: Generated from simulations visible in both systems

---

## ✅ FINAL CHECKLIST

Print this and check off as you validate:

```
ELASTIC STACK SIEM:
[ ] Services running (7 containers)
[ ] Elasticsearch healthy
[ ] Kibana accessible
[ ] Data visible
[ ] Events generated
[ ] ILM configured

WAZUH SIEM:
[ ] Services running (3 containers)
[ ] Dashboard accessible
[ ] API authenticated
[ ] Rules loaded (9 rules)
[ ] Agent deployed
[ ] Agent online
[ ] Simulations executed
[ ] Alerts detected

DOCUMENTATION:
[ ] All guides present (5 files)
[ ] Scripts executable (3 scripts)
[ ] README updated
[ ] Validation guide reviewed
```

---

## 🎓 Next Steps After Validation

1. **Explore Dashboards**: Navigate through Kibana and Wazuh UIs
2. **Create Visualizations**: Use templates from INVESTIGATION_GUIDE.md
3. **Configure Alerts**: Set up monitors using provided templates
4. **Review Events**: Analyze detected threats from simulations
5. **Practice Queries**: Use KQL queries from INVESTIGATION_GUIDE.md
6. **Test Detection**: Create custom alerts and test triggers
7. **Document Findings**: Note any interesting patterns or issues

---

**Validation Complete!** 🎉

Both SIEM systems are deployed, configured, and tested. You now have:
- Production-grade Elastic Stack SIEM with 3-node cluster
- Wazuh endpoint security with custom detection rules
- Comprehensive documentation and automation
- Real-world threat simulations and detection capabilities
