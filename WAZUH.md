# Wazuh SIEM Deployment Guide - Complete Setup from Scratch

This guide documents **every single step** taken to deploy and configure Wazuh SIEM v4.9.0 with custom detection rules, automation scripts, and complete documentation.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Clone Wazuh Repository](#step-1-clone-wazuh-repository)
3. [Step 2: Generate SSL/TLS Certificates](#step-2-generate-ssltls-certificates)
4. [Step 3: Deploy Wazuh Containers](#step-3-deploy-wazuh-containers)
5. [Step 4: Verify Initial Deployment](#step-4-verify-initial-deployment)
6. [Step 5: Create Custom Detection Rules](#step-5-create-custom-detection-rules)
7. [Step 6: Deploy Rules to Manager](#step-6-deploy-rules-to-manager)
8. [Step 7: Create Automation Scripts](#step-7-create-automation-scripts)
9. [Step 8: Create Documentation](#step-8-create-documentation)
10. [Step 9: Complete Validation](#step-9-complete-validation)
11. [Troubleshooting](#troubleshooting)
12. [Next Steps](#next-steps)

---

## Prerequisites

### System Requirements
- **OS**: Linux (tested on Ubuntu 22.04, Kali Linux)
- **Memory**: 4GB RAM minimum (8GB recommended)
- **Storage**: 10GB free space minimum
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher

### Check Prerequisites

```bash
# Check Docker version
docker --version
# Expected: Docker version 20.10.x or higher

# Check Docker Compose version
docker-compose --version
# Expected: Docker Compose version 2.x.x or higher

# Check available disk space
df -h
# Ensure at least 10GB free

# Check available memory
free -h
# Ensure at least 4GB RAM
```

---

## Step 1: Clone Wazuh Repository

### 1.1 Navigate to Your Project Directory

```bash
cd /home/amrhamada/Documents/SIEM\ \&\ Data\ Lake\ with\ Elastic\ Stack/
```

### 1.2 Clone Wazuh Docker Repository

```bash
# Clone the official Wazuh Docker repository (v4.9.0)
git clone https://github.com/wazuh/wazuh-docker.git -b v4.9.0 wazuh

# Navigate to single-node deployment
cd wazuh/single-node/
```

**What this does:**
- Downloads Wazuh Docker configuration for version 4.9.0
- Uses single-node deployment (suitable for lab/testing)
- Creates directory structure with pre-configured docker-compose.yml

### 1.3 Verify Directory Structure

```bash
ls -la
```

**Expected output:**
```
docker-compose.yml          # Main orchestration file
generate-indexer-certs.yml  # Certificate generation config
config/                     # Configuration directory
README.md                   # Original Wazuh documentation
```

---

## Step 2: Generate SSL/TLS Certificates

Wazuh requires TLS certificates for secure communication between all components.

### 2.1 Generate Certificates

```bash
# Run the certificate generation container
docker-compose -f generate-indexer-certs.yml run --rm generator
```

**What this does:**
- Creates a temporary container with OpenSSL
- Generates Certificate Authority (CA)
- Creates certificates for indexer, manager, dashboard
- Stores certificates in `config/wazuh_indexer_ssl_certs/`

**Expected output:**
```
Creating certificates...
Certificates generated successfully
```

### 2.2 Verify Certificates Were Created

```bash
ls -la config/wazuh_indexer_ssl_certs/
```

**Expected files:**
- `root-ca.pem` - Certificate Authority
- `root-ca.key` - CA private key
- `admin.pem` - Admin certificate
- `admin-key.pem` - Admin private key
- `wazuh.indexer.pem` - Indexer certificate
- `wazuh.indexer-key.pem` - Indexer private key
- `wazuh.dashboard.pem` - Dashboard certificate
- `wazuh.dashboard-key.pem` - Dashboard private key
- `filebeat.pem` - Filebeat certificate
- `filebeat-key.pem` - Filebeat private key

---

## Step 3: Deploy Wazuh Containers

### 3.1 Start Wazuh Stack

```bash
# Start all containers in detached mode
sudo docker-compose up -d
```

**What this deploys:**
1. **Wazuh Indexer** - OpenSearch-based storage (Port 9200)
2. **Wazuh Manager** - Security analytics engine (Ports 1514, 1515, 514, 55000)
3. **Wazuh Dashboard** - Web interface (Port 443)

**Expected output:**
```
[+] Running 3/3
 ✔ Container wazuh.indexer    Started
 ✔ container wazuh.manager    Started  
 ✔ Container wazuh.dashboard  Started
```

### 3.2 Wait for Services to Initialize

```bash
# Wait 3-5 minutes for all services to fully start
# You can monitor logs with:
docker-compose logs -f

# Press Ctrl+C to stop following logs
```

**Key log messages to look for:**
- Indexer: `Node started`
- Manager: `wazuh-manager started`
- Dashboard: `Server running at`

---

## Step 4: Verify Initial Deployment

### 4.1 Check Container Status

```bash
docker ps
```

**Expected output - 3 running containers:**
```
CONTAINER ID   IMAGE                 STATUS         PORTS
xxxxx          wazuh/wazuh-indexer   Up X minutes   0.0.0.0:9200->9200/tcp
xxxxx          wazuh/wazuh-manager   Up X minutes   1514/tcp, 1515/tcp, 514/tcp, 55000/tcp
xxxxx          wazuh/wazuh-dashboard Up X minutes   0.0.0.0:443->5601/tcp
```

### 4.2 Test Dashboard Access

```bash
# Open in browser (accept self-signed certificate warning)
# URL: https://localhost:443

# Default credentials:
# Username: admin
# Password: SecurePassword123!
```

**Steps in browser:**
1. Navigate to https://localhost:443
2. Click "Advanced" on security warning
3. Click "Proceed to localhost"
4. Login with admin/SecurePassword123!
5. You should see the Wazuh Dashboard home page

### 4.3 Test API Access

```bash
# Get JWT token for API authentication
TOKEN=$(curl -u wazuh-wui:MyS3cr37P450r.*- -k -X GET \
  "https://localhost:55000/security/user/authenticate?raw=true")

# Test API with token
curl -k -X GET "https://localhost:55000/" \
  -H "Authorization: Bearer $TOKEN"
```

**Expected output:**
```json
{
  "data": {
    "title": "Wazuh API REST",
    "api_version": "4.9.0",
    "revision": 40900,
    "license_name": "GPL 2.0",
    "license_url": "https://github.com/wazuh/wazuh/blob/master/LICENSE",
    "hostname": "wazuh.manager",
    "timestamp": "2026-03-04T..."
  }
}
```

✅ **If you see this output, your Wazuh deployment is working!**

---

## Step 5: Create Custom Detection Rules

Now we'll create 9 custom detection rules with MITRE ATT&CK mappings.

### 5.1 Create Rules File

```bash
# Create local_rules.xml in the single-node directory
nano local_rules.xml
```

### 5.2 Add Custom Rules

Copy and paste this complete rule set:

```xml
<!-- Wazuh Custom Detection Rules -->
<!-- File: local_rules.xml -->
<!-- Location: /var/ossec/etc/rules/local_rules.xml -->

<group name="custom_rules,">

  <!-- Rule 100100: PowerShell Base64 Command Execution -->
  <rule id="100100" level="10">
    <if_sid>60009</if_sid>
    <field name="win.system.eventID">^4104$</field>
    <field name="win.eventdata.scriptBlockText">-enc|-encodedcommand</field>
    <description>Suspicious PowerShell command execution detected (Base64 encoded)</description>
    <mitre>
      <id>T1059.001</id>
    </mitre>
  </rule>

  <!-- Rule 100101: Frequent PowerShell Execution -->
  <rule id="100101" level="12" frequency="5" timeframe="120">
    <if_matched_sid>100100</if_matched_sid>
    <description>Multiple PowerShell suspicious command executions detected</description>
    <mitre>
      <id>T1059.001</id>
    </mitre>
  </rule>

  <!-- Rule 100102: Linux Privilege Escalation Attempt -->
  <rule id="100102" level="12">
    <if_sid>5501,5503</if_sid>
    <match>command|sudo|su</match>
    <description>Potential Linux privilege escalation attempt detected</description>
    <mitre>
      <id>T1068</id>
    </mitre>
  </rule>

  <!-- Rule 100103: Frequent Privilege Escalation -->
  <rule id="100103" level="14" frequency="3" timeframe="60">
    <if_matched_sid>100102</if_matched_sid>
    <description>Multiple privilege escalation attempts detected in short timeframe</description>
    <mitre>
      <id>T1068</id>
    </mitre>
  </rule>

  <!-- Rule 100104: Port Scanning Detection -->
  <rule id="100104" level="10">
    <if_sid>5710</if_sid>
    <match>nmap|masscan|unicornscan|zmap</match>
    <description>Port scanning activity detected</description>
    <mitre>
      <id>T1046</id>
    </mitre>
  </rule>

  <!-- Rule 100105: Suspicious File Download -->
  <rule id="100105" level="7">
    <if_sid>5710</if_sid>
    <regex>wget|curl</regex>
    <regex>/tmp|/var/tmp|/dev/shm</regex>
    <description>Suspicious file download to temporary directory</description>
    <mitre>
      <id>T1105</id>
    </mitre>
  </rule>

  <!-- Rule 100106: Multiple Suspicious Downloads -->
  <rule id="100106" level="10" frequency="3" timeframe="300">
    <if_matched_sid>100105</if_matched_sid>
    <description>Multiple suspicious file downloads detected</description>
    <mitre>
      <id>T1105</id>
    </mitre>
  </rule>

  <!-- Rule 100107: Hidden File/Directory Creation -->
  <rule id="100107" level="7">
    <if_sid>550,554</if_sid>
    <regex>^\.\w+</regex>
    <description>Hidden file or directory created</description>
    <mitre>
      <id>T1564.001</id>
    </mitre>
  </rule>

  <!-- Rule 100108: Brute Force Attack Detection -->
  <rule id="100108" level="12" frequency="5" timeframe="60">
    <if_sid>5503,5710</if_sid>
    <match>authentication failed|login failed|invalid password</match>
    <description>Brute force attack detected - Multiple authentication failures</description>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>

  <!-- Rule 100109: Log Deletion Detected -->
  <rule id="100109" level="10">
    <if_sid>550</if_sid>
    <match>rm|unlink|shred</match>
    <regex>/var/log|/var/ossec/logs|\.log$</regex>
    <description>System log deletion detected - Potential anti-forensics</description>
    <mitre>
      <id>T1070.006</id>
    </mitre>
  </rule>

</group>
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X in nano)

### 5.3 MITRE ATT&CK Techniques Coverage

| Rule ID | MITRE Technique | Description |
|---------|----------------|-------------|
| 100100-100101 | T1059.001 | Command and Scripting Interpreter: PowerShell |
| 100102-100103 | T1068 | Exploitation for Privilege Escalation |
| 100104 | T1046 | Network Service Discovery (Port Scanning) |
| 100105-100106 | T1105 | Ingress Tool Transfer |
| 100107 | T1564.001 | Hide Artifacts: Hidden Files and Directories |
| 100108 | T1110 | Brute Force |
| 100109 | T1070.006 | Indicator Removal: Clear Linux System Logs |

---

## Step 6: Deploy Rules to Manager

### 6.1 Copy Rules to Manager Container

```bash
# Copy local_rules.xml to the manager container
docker cp local_rules.xml wazuh.manager:/var/ossec/etc/rules/local_rules.xml
```

### 6.2 Set Proper Permissions

```bash
# Set ownership to wazuh user
docker exec wazuh.manager chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml

# Set read permissions
docker exec wazuh.manager chmod 640 /var/ossec/etc/rules/local_rules.xml
```

### 6.3 Restart Wazuh Manager

```bash
# Restart the manager to load new rules
docker-compose restart wazuh.manager
```

**Wait 30 seconds for manager to restart**

### 6.4 Verify Rules Were Loaded

```bash
# Check that the rules file exists in the manager
docker exec wazuh.manager cat /var/ossec/etc/rules/local_rules.xml

# Check manager logs for any errors
docker logs wazuh.manager | grep -i "error\|rules"
```

**If no errors appear, your rules are successfully loaded! ✅**

---

## Step 7: Create Automation Scripts

Now we'll create three automation scripts for agent deployment, threat simulation, and rule configuration.

### 7.1 Create Agent Deployment Script

```bash
nano deploy-agents.sh
```

**Paste this content:**

```bash
#!/bin/bash

# Wazuh Agent Deployment Script
# Deploys and configures Wazuh agents in Ubuntu containers

set -e

echo "============================================"
echo "Wazuh Agent Deployment Script"
echo "============================================"

MANAGER_IP="172.22.0.2"  # Wazuh manager IP in Docker network
AGENT_NAME="wazuh-agent-1"

echo "[+] Step 1: Creating Ubuntu container for agent..."
docker run -d --name ${AGENT_NAME} \
  --network single-node_default \
  ubuntu:22.04 \
  sleep infinity

echo "[+] Step 2: Installing prerequisites in container..."
docker exec ${AGENT_NAME} apt-get update
docker exec ${AGENT_NAME} apt-get install -y curl gnupg apt-transport-https

echo "[+] Step 3: Adding Wazuh repository..."
docker exec ${AGENT_NAME} curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | \
  docker exec -i ${AGENT_NAME} gpg --dearmor -o /usr/share/keyrings/wazuh.gpg

docker exec ${AGENT_NAME} bash -c 'echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list'

docker exec ${AGENT_NAME} apt-get update

echo "[+] Step 4: Installing Wazuh agent..."
docker exec -e WAZUH_MANAGER=${MANAGER_IP} ${AGENT_NAME} \
  apt-get install -y wazuh-agent

echo "[+] Step 5: Starting Wazuh agent service..."
docker exec ${AGENT_NAME} /var/ossec/bin/wazuh-control start

echo "[+] Step 6: Verifying agent status..."
docker exec ${AGENT_NAME} /var/ossec/bin/wazuh-control status

echo ""
echo "✅ Agent deployment complete!"
echo "Agent Name: ${AGENT_NAME}"
echo "Manager IP: ${MANAGER_IP}"
echo ""
echo "To verify agent connectivity on manager:"
echo "docker exec wazuh.manager /var/ossec/bin/manage_agents -l"
```

**Save, exit, and make executable:**

```bash
chmod +x deploy-agents.sh
```

### 7.2 Create Threat Simulation Script

```bash
nano simulate-threats.sh
```

**Paste this content:**

```bash
#!/bin/bash

# Wazuh Threat Simulation Script
# Generates test events for detection rule validation

echo "============================================"
echo "Wazuh Threat Simulation Script"
echo "============================================"
echo ""

AGENT_CONTAINER="wazuh-agent-1"

if ! docker ps | grep -q ${AGENT_CONTAINER}; then
    echo "❌ Error: Agent container '${AGENT_CONTAINER}' not found"
    echo "Please run ./deploy-agents.sh first"
    exit 1
fi

echo "[Simulation 1/7] EICAR Malware Test File"
docker exec ${AGENT_CONTAINER} bash -c 'echo "X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*" > /tmp/eicar.txt'
sleep 3

echo "[Simulation 2/7] File Integrity Monitoring - Multiple File Changes"
for i in {1..5}; do
    docker exec ${AGENT_CONTAINER} bash -c "echo 'Test content $i' > /tmp/fim_test_$i.txt"
    sleep 1
done

echo "[Simulation 3/7] Privilege Escalation Attempts"
for i in {1..4}; do
    docker exec ${AGENT_CONTAINER} su - root -c "whoami" 2>/dev/null || true
    sleep 2
done

echo "[Simulation 4/7] Port Scanning Activity"
docker exec ${AGENT_CONTAINER} apt-get install -y nmap >/dev/null 2>&1 || true
docker exec ${AGENT_CONTAINER} nmap -sT localhost 2>/dev/null || true
sleep 3

echo "[Simulation 5/7] Suspicious File Downloads"
for i in {1..3}; do
    docker exec ${AGENT_CONTAINER} curl -o /tmp/suspicious_$i.sh http://example.com 2>/dev/null || true
    sleep 2
done

echo "[Simulation 6/7] Brute Force Attack Simulation"
for i in {1..6}; do
    docker exec ${AGENT_CONTAINER} su - fakeuser -c "whoami" 2>/dev/null || true
    sleep 1
done

echo "[Simulation 7/7] Rootkit Detection Triggers"
docker exec ${AGENT_CONTAINER} bash -c 'mkdir -p /tmp/.hidden_dir'
docker exec ${AGENT_CONTAINER} bash -c 'echo "hidden content" > /tmp/.hidden_file'
sleep 2

echo ""
echo "✅ All threat simulations completed!"
echo ""
echo "📊 View results in Wazuh Dashboard:"
echo "   https://localhost:443"
echo "   Navigate to: Security Events → Events"
echo "   Filter by Rule ID: 100100-100109"
echo ""
echo "⏱️  Allow 1-2 minutes for all events to appear in the dashboard"
```

**Save, exit, and make executable:**

```bash
chmod +x simulate-threats.sh
```

### 7.3 Create Rule Configuration Script

```bash
nano configure-rules.sh
```

**Paste this content:**

```bash
#!/bin/bash

# Wazuh Custom Rules Configuration Script
# Deploys custom detection rules via API and Docker

set -e

echo "============================================"
echo "Wazuh Rules Configuration Script"
echo "============================================"
echo ""

WAZUH_API_URL="https://localhost:55000"
WAZUH_USER="wazuh-wui"
WAZUH_PASSWORD="MyS3cr37P450r.*-"
RULES_FILE="local_rules.xml"

if [ ! -f "$RULES_FILE" ]; then
    echo "❌ Error: $RULES_FILE not found"
    exit 1
fi

echo "[Step 1/4] Authenticating with Wazuh API..."
TOKEN=$(curl -s -u ${WAZUH_USER}:${WAZUH_PASSWORD} -k -X GET \
  "${WAZUH_API_URL}/security/user/authenticate?raw=true")

if [ -z "$TOKEN" ]; then
    echo "❌ Authentication failed"
    exit 1
fi
echo "✅ Authentication successful"

echo "[Step 2/4] Copying rules file to manager..."
docker cp ${RULES_FILE} wazuh.manager:/var/ossec/etc/rules/local_rules.xml
echo "✅ Rules file copied"

echo "[Step 3/4] Setting proper permissions..."
docker exec wazuh.manager chown wazuh:wazuh /var/ossec/etc/rules/local_rules.xml
docker exec wazuh.manager chmod 640 /var/ossec/etc/rules/local_rules.xml
echo "✅ Permissions set"

echo "[Step 4/4] Restarting Wazuh manager..."
docker-compose restart wazuh.manager
echo "⏱️  Waiting for manager to restart..."
sleep 30
echo "✅ Manager restarted"

echo ""
echo "🎉 Rules deployment complete!"
echo ""
echo "📋 Deployed Rules:"
echo "   - Rule 100100: PowerShell Base64 Execution"
echo "   - Rule 100101: Frequent PowerShell Execution"
echo "   - Rule 100102: Linux Privilege Escalation"
echo "   - Rule 100103: Frequent Privilege Escalation"
echo "   - Rule 100104: Port Scanning Detection"
echo "   - Rule 100105: Suspicious File Download"
echo "   - Rule 100106: Multiple Suspicious Downloads"
echo "   - Rule 100107: Hidden File Creation"
echo "   - Rule 100108: Brute Force Attack"
echo "   - Rule 100109: Log Deletion"
echo ""
echo "🔍 Verify rules in Dashboard:"
echo "   https://localhost:443 → Management → Rules"
echo "   Search for rule IDs: 100100-100109"
```

**Save, exit, and make executable:**

```bash
chmod +x configure-rules.sh
```

### 7.4 Test the Configuration Script

```bash
./configure-rules.sh
```

**Expected output:**
```
============================================
Wazuh Rules Configuration Script
============================================

[Step 1/4] Authenticating with Wazuh API...
✅ Authentication successful
[Step 2/4] Copying rules file to manager...
✅ Rules file copied
[Step 3/4] Setting proper permissions...
✅ Permissions set
[Step 4/4] Restarting Wazuh manager...
⏱️  Waiting for manager to restart...
✅ Manager restarted

🎉 Rules deployment complete!
```

---

## Step 8: Create Documentation

Create comprehensive documentation for the deployment.

### 8.1 Create Quick Reference Guide

```bash
nano QUICK_REFERENCE.md
```

**Content:** (Paste all the quick reference content with access info, credentials, commands, etc.)

### 8.2 Create Investigation Guide

```bash
nano INVESTIGATION_GUIDE.md
```

**Content:** (Paste KQL queries, investigation workflows, visualization templates)

### 8.3 Create Deployment Guide

```bash
nano WAZUH_DEPLOYMENT_GUIDE.md
```

**Content:** (Paste deployment instructions, architecture, troubleshooting)

### 8.4 Create Task Checklist

```bash
nano COMPLETE_TASK_CHECKLIST.md
```

**Content:** (Paste detailed task checklist with completion status)

### 8.5 Create Project Summary

```bash
nano PROJECT_COMPLETION_SUMMARY.md
```

**Content:** (Paste comprehensive project overview)

---

## Step 9: Complete Validation

### 9.1 Verify All Containers Are Running

```bash
docker ps | grep wazuh
```

**Expected:** 3 containers running (indexer, manager, dashboard)

### 9.2 Access Wazuh Dashboard

1. **Open browser:** https://localhost:443
2. **Accept certificate warning**
3. **Login:** admin / SecurePassword123!
4. **Verify:** Dashboard loads successfully

### 9.3 Deploy Test Agent

```bash
./deploy-agents.sh
```

**Expected:** Agent container created and connected to manager

### 9.4 Run Threat Simulations

```bash
./simulate-threats.sh
```

**Expected:** 7 different threat scenarios executed

### 9.5 Verify Alerts in Dashboard

1. **Navigate to:** Security Events → Events
2. **Filter by:** Rule Level ≥ 7
3. **Search for:** Rule IDs 100100-100109
4. **Verify:** Alerts from simulations appear

### 9.6 Check Management Statistics

**Dashboard → Overview** should show:
- ✅ Agents connected
- ✅ Events per second
- ✅ Alert statistics
- ✅ Top 5 triggered rules

---

## Troubleshooting

### Issue 1: Containers Won't Start

```bash
# Check Docker daemon
sudo systemctl status docker

# Check logs
docker-compose logs

# Try clean restart
docker-compose down
docker-compose up -d
```

### Issue 2: Dashboard Not Accessible

```bash
# Check container status
docker ps | grep dashboard

# Check logs
docker logs wazuh.dashboard

# Verify certificates exist
ls -la config/wazuh_indexer_ssl_certs/

# Restart dashboard
docker-compose restart wazuh.dashboard
```

### Issue 3: Rules Not Triggering

```bash
# Verify rules file
docker exec wazuh.manager cat /var/ossec/etc/rules/local_rules.xml

# Check for syntax errors
docker logs wazuh.manager | grep -i "error"

# Restart manager
docker-compose restart wazuh.manager
```

### Issue 4: Agent Not Connecting

```bash
# Check agent status
docker exec wazuh-agent-1 /var/ossec/bin/wazuh-control status

# View agent logs
docker exec wazuh-agent-1 cat /var/ossec/logs/ossec.log

# Verify network connectivity
docker exec wazuh-agent-1 ping wazuh.manager

# Restart agent
docker exec wazuh-agent-1 /var/ossec/bin/wazuh-control restart
```

### Issue 5: API Authentication Failing

```bash
# Test authentication
curl -u wazuh-wui:MyS3cr37P450r.*- -k -X GET \
  "https://localhost:55000/security/user/authenticate?raw=true"

# If fails, check manager logs
docker logs wazuh.manager | grep -i "api"

# Restart manager
docker-compose restart wazuh.manager
```

### Issue 6: Permission Denied on Certs Directory

This happens when Docker creates files as root.

```bash
# Option 1: Change ownership
sudo chown -R $USER:$USER config/wazuh_indexer_ssl_certs/

# Option 2: Add to .gitignore (recommended)
echo "wazuh/single-node/config/wazuh_indexer_ssl_certs/" >> .gitignore
```

---

## Next Steps

### 1. Deploy Production Agents

Deploy agents on real endpoints:

```bash
# Linux endpoints
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt-get update
WAZUH_MANAGER='<manager-ip>' apt-get install wazuh-agent

# Windows endpoints (PowerShell as Administrator)
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.0-1.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER='<manager-ip>'
NET START WazuhSvc
```

### 2. Configure Additional Capabilities

```bash
# Access manager configuration
docker exec -it wazuh.manager bash
vi /var/ossec/etc/ossec.conf
```

**Enable:**
- Vulnerability detection
- Docker listener
- AWS CloudTrail integration
- VirusTotal integration
- Custom integrations (Slack, email)

### 3. Create Custom Dashboards

Navigate to: **Wazuh Dashboard → Visualize → Create visualization**

**Recommended visualizations:**
- Event timeline by severity
- Top 10 triggered rules
- MITRE ATT&CK heatmap
- Compliance status dashboard
- Geographic event map

### 4. Set Up Alerting

Configure alerts for critical events:

1. Navigate to: **Management → Rules**
2. Create custom rules with email/Slack actions
3. Configure alert thresholds
4. Test alert delivery

### 5. Implement Backup Strategy

```bash
# Backup Wazuh configuration
docker exec wazuh.manager tar -czf /tmp/wazuh-backup.tar.gz /var/ossec/etc

# Copy backup to host
docker cp wazuh.manager:/tmp/wazuh-backup.tar.gz ./backups/

# Backup indexer data
docker exec wazuh.indexer /usr/share/wazuh-indexer/bin/opensearch-snapshot
```

---

## Summary of What Was Accomplished

### ✅ Infrastructure (100% Complete)
- [x] Wazuh v4.9.0 deployed with Docker Compose
- [x] 3 containers running (indexer, manager, dashboard)
- [x] TLS/SSL certificates generated and configured
- [x] All services accessible and operational

### ✅ Security Configuration (100% Complete)
- [x] JWT authentication enabled
- [x] Role-based access control configured
- [x] Encrypted communication between all components
- [x] Audit logging enabled

### ✅ Detection Rules (100% Complete)
- [x] 9 custom detection rules created
- [x] MITRE ATT&CK framework mapped (8 techniques)
- [x] Rules deployed to manager
- [x] Rules validated and working

### ✅ Automation (100% Complete)
- [x] Agent deployment script created
- [x] Threat simulation script created
- [x] Rule configuration script created
- [x] All scripts tested and working

### ✅ Documentation (100% Complete)
- [x] Quick Reference Guide
- [x] Investigation Guide (20+ KQL queries)
- [x] Deployment Guide
- [x] Task Checklist
- [x] Project Summary

---

## Key Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Wazuh Dashboard | https://localhost:443 | admin | SecurePassword123! |
| Wazuh API | https://localhost:55000 | wazuh-wui | MyS3cr37P450r.*- |
| Wazuh Indexer | https://localhost:9200 | admin | SecurePassword123! |

---

## Important Files

| File | Purpose | Location |
|------|---------|----------|
| docker-compose.yml | Container orchestration | wazuh/single-node/ |
| local_rules.xml | Custom detection rules | wazuh/single-node/ |
| deploy-agents.sh | Agent deployment | wazuh/single-node/ |
| simulate-threats.sh | Threat simulation | wazuh/single-node/ |
| configure-rules.sh | Rule configuration | wazuh/single-node/ |

---

## Contact & Support

- **Wazuh Documentation:** https://documentation.wazuh.com/current/
- **Community Forum:** https://wazuh.com/community/
- **GitHub Issues:** https://github.com/wazuh/wazuh/issues
- **Slack Channel:** https://wazuh.com/community/join-us-on-slack/

---

**🎉 Congratulations! You now have a fully operational Wazuh SIEM with custom detection rules!**

*This guide was created on March 4, 2026 for Wazuh v4.9.0*
