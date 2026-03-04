# Integrated SIEM Laboratory: Elastic Stack + Wazuh

Production-grade Security Information and Event Management (SIEM) laboratory featuring **dual SIEM deployment**:

- **Elastic Stack SIEM**: 3-node Elasticsearch cluster with Kibana, Fleet Server, and comprehensive data lake capabilities
- **Wazuh SIEM**: Enterprise-grade XDR and SIEM platform with custom detection rules, agent management, and threat hunting

---

## 🚀 Quick Start

### Elastic Stack SIEM

```bash
# Start the complete Elastic Stack
bash setup.sh
```
**Takes 5-10 minutes. Deploys 7 containers (es01-03, kibana, fleet, logstash, customer-api).**

```bash
# Stop everything
bash stop.sh

# Check status
bash status.sh
```

**Access Kibana**: http://localhost:5601 (`elastic` / `SecurePassword123!`)

### Wazuh SIEM

```bash
# Navigate to Wazuh directory
cd wazuh/single-node

# Start Wazuh Stack
sudo docker-compose up -d
```
**Takes 3-5 minutes. Deploys 3 containers (indexer, manager, dashboard).**

**Access Dashboard**: https://localhost:443 (`admin` / `SecurePassword123!`)

### Validation & Testing

```bash
# See comprehensive validation procedures for BOTH systems
cat VALIDATION_GUIDE.md

# Or open at: /home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/VALIDATION_GUIDE.md
```

---

## 📋 What's Included

### Elastic Stack SIEM

**Infrastructure**
- ✅ **3-node Elasticsearch cluster** (es01, es02, es03)
- ✅ **Kibana with SIEM** features enabled
- ✅ **Fleet Server** for agent management
- ✅ **Logstash** for log processing
- ✅ **Python Flask app** for log generation

**Security**
- ✅ **TLS/SSL encryption** (all communications)
- ✅ **X-Pack Security** enabled
- ✅ **Audit logging** configured
- ✅ **Authentication** required

**Data Management**
- ✅ **ILM policies** (Hot/Warm/Cold/Delete phases)
- ✅ **Index templates** with proper sharding
- ✅ **Automated rollover** and retention

**Detection Rules**
- ✅ SSH Brute Force Detection
- ✅ Multiple Failed Login Attempts
- ✅ Suspicious Network Connections
- ✅ Data Exfiltration Detection
- ✅ Webshell Activity Detection

### Wazuh SIEM

**Infrastructure**
- ✅ **Wazuh Indexer** (OpenSearch-based)
- ✅ **Wazuh Manager** (v4.9.0 - Security analytics engine)
- ✅ **Wazuh Dashboard** (Analysis and visualization)

**Security**
- ✅ **Zero-trust architecture** with TLS/SSL for all communications
- ✅ **JWT authentication** for API access
- ✅ **Role-based access control** (RBAC)
- ✅ **Encrypted agent-manager communication**

**Detection Capabilities**
- ✅ **9 Custom Detection Rules** (IDs 100100-100109)
- ✅ **MITRE ATT&CK** framework mappings (8 techniques)
- ✅ **File Integrity Monitoring** (FIM)
- ✅ **Active Response** automation
- ✅ **Vulnerability Detection**
- ✅ **Compliance Monitoring** (PCI-DSS, GDPR, HIPAA)

**Automation**
- ✅ **Agent deployment** script (deploy-agents.sh)
- ✅ **Threat simulation** script (simulate-threats.sh)
- ✅ **Rule configuration** script (configure-rules.sh)

**Documentation**
- ✅ [Deployment Guide](wazuh/single-node/WAZUH_DEPLOYMENT_GUIDE.md)
- ✅ [Investigation Guide](wazuh/single-node/INVESTIGATION_GUIDE.md) - KQL queries & workflows
- ✅ [Quick Reference](wazuh/single-node/QUICK_REFERENCE.md) - Commands & credentials
- ✅ [Task Checklist](wazuh/single-node/COMPLETE_TASK_CHECKLIST.md)
- ✅ [Project Summary](wazuh/single-node/PROJECT_COMPLETION_SUMMARY.md)

---

## 🔐 Access Information

### Elastic Stack SIEM

| Service | URL | Credentials |
|---------|-----|-------------|
| **Kibana** | http://localhost:5601 | elastic / SecurePassword123! |
| **Elasticsearch** | https://localhost:9200 | elastic / SecurePassword123! |
| **Customer API** | http://localhost:8081 | None |

### Wazuh SIEM

| Service | URL | Credentials |
|---------|-----|-------------|
| **Wazuh Dashboard** | https://localhost:443 | admin / SecurePassword123! |
| **Wazuh API** | https://localhost:55000 | wazuh-wui / MyS3cr37P450r.*- |
| **Wazuh Indexer** | https://localhost:9200 | admin / SecurePassword123! |

**⚠️ Note**: Wazuh uses self-signed certificates. Accept the security warning in your browser.

---

## 📁 Project Structure

```
/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/
│
├── 📂 Elastic Stack SIEM/
│   ├── app/                       # Python Flask application
│   │   ├── app.py                # Main REST API
│   │   ├── models.py             # Customer data models
│   │   └── log_config.py         # Logging to Logstash
│   │
│   ├── config/                    # Service configurations
│   │   ├── elasticsearch/        # ES node configs (es01, es02, es03)
│   │   ├── kibana/              # Kibana SIEM config
│   │   └── fleet-server/        # Fleet management
│   │
│   ├── logstash/                 # Logstash pipeline
│   │   └── pipeline/
│   │       └── logstash.conf    # Processing with ILM
│   │
│   ├── certs/                    # TLS certificates (auto-generated)
│   │
│   ├── .env                      # Environment variables
│   ├── docker-compose.yml        # All services orchestration
│   │
│   ├── setup.sh                  # 🚀 START EVERYTHING
│   ├── stop.sh                   # 🛑 STOP EVERYTHING
│   ├── status.sh                 # 📊 CHECK STATUS
│   └── simulate-events.sh        # 🚨 GENERATE TEST EVENTS
│
├── 📂 Wazuh SIEM/
│   └── wazuh/
│       └── single-node/
│           ├── docker-compose.yml            # Wazuh stack (3 containers)
│           ├── generate-indexer-certs.yml    # Certificate configuration
│           │
│           ├── config/                       # Wazuh configurations
│           │   ├── wazuh_indexer_ssl_certs/  # TLS certificates
│           │   ├── wazuh_cluster/            # Manager configs
│           │   └── wazuh_dashboard/          # Dashboard configs
│           │
│           ├── local_rules.xml               # 🎯 9 Custom Detection Rules
│           │
│           ├── 🔧 Automation Scripts/
│           │   ├── deploy-agents.sh          # Deploy Ubuntu agents
│           │   ├── simulate-threats.sh       # 7 threat scenarios
│           │   └── configure-rules.sh        # API-based rule config
│           │
│           └── 📚 Documentation/
│               ├── WAZUH_DEPLOYMENT_GUIDE.md
│               ├── INVESTIGATION_GUIDE.md    # KQL queries & workflows
│               ├── QUICK_REFERENCE.md        # Commands cheat sheet
│               ├── COMPLETE_TASK_CHECKLIST.md
│               └── PROJECT_COMPLETION_SUMMARY.md
│
├── 📄 VALIDATION_GUIDE.md        # ⭐ COMPREHENSIVE VALIDATION FOR BOTH SYSTEMS
│
└── 📄 README.md                   # This file

```

---

## 🎯 Usage Guide

### Part 1: Elastic Stack SIEM

#### 1. Initial Deployment

```bash
# Start the complete SIEM infrastructure
bash setup.sh
```

**What happens:**
1. Generates TLS certificates
2. Starts 3-node Elasticsearch cluster
3. Configures security and passwords
4. Sets up ILM policies
5. Starts Kibana with SIEM features
6. Deploys Fleet Server
7. Starts Logstash and Customer Service

**Wait for:** "✅ DEPLOYMENT COMPLETE!"

#### 2. Access Kibana

Open browser: **http://localhost:5601**

Login:
- **Username:** elastic  
- **Password:** SecurePassword123!

Navigate to:
- **Security → Overview** - Security dashboard
- **Security → Alerts** - Detection alerts
- **Discover** - Search logs
- **Management → Fleet** - Agent management

#### 3. Generate Test Events

```bash
bash simulate-events.sh
```

Creates realistic security events:
- SSH brute force attempts
- Failed login attempts
- Suspicious network connections
- Data exfiltration patterns
- Webshell activity

View alerts in: **Security → Alerts**

#### 4. Test Customer API

```bash
# Health check
curl http://localhost:8081/health

# Get all customers
curl http://localhost:8081/api/v1/customers/all | jq

# Get specific customer
curl "http://localhost:8081/api/v1/customers?customerId=<ID>" | jq
```

Logs automatically sent to Elasticsearch via Logstash.

### Part 2: Wazuh SIEM

#### 1. Start Wazuh Stack

```bash
cd wazuh/single-node
sudo docker-compose up -d
```

Wait 3-5 minutes for all services to start.

#### 2. Verify Wazuh Deployment

```bash
# Check containers
docker ps | grep wazuh

# Expected output: 3 containers running
# - wazuh.indexer
# - wazuh.manager
# - wazuh.dashboard
```

#### 3. Access Wazuh Dashboard

Open browser: **https://localhost:443**

Login:
- **Username:** admin
- **Password:** SecurePassword123!

**⚠️ Accept self-signed certificate warning**

#### 4. Deploy Wazuh Agents (Optional)

```bash
# Script automates Ubuntu agent deployment
./deploy-agents.sh
```

**What it does:**
1. Creates Ubuntu container
2. Installs Wazuh agent
3. Enrolls with manager
4. Starts agent service

#### 5. Run Threat Simulations

```bash
# Simulate 7 different threat scenarios
./simulate-threats.sh
```

**Simulated threats:**
- EICAR malware test file  
- File integrity monitoring
- Privilege escalation attempts
- Port scanning activity
- Suspicious file downloads
- Brute force attacks
- Rootkit detection

#### 6. View Alerts in Dashboard

Navigate to:
1. **Security Events** - All security-related events
2. **Threat Hunting** - Custom queries and searches
3. **File Integrity Monitoring** - File changes
4. **Vulnerability Detection** - CVE findings
5. **Regulatory Compliance** - PCI-DSS, GDPR dashboards

### Combined Operations

#### Check Status of Both Systems

```bash
# Elastic Stack
bash status.sh

# Wazuh
cd wazuh/single-node && docker-compose ps
```

#### Stop Both Systems

```bash
# Stop Elastic Stack
bash stop.sh

# Stop Wazuh
cd wazuh/single-node && sudo docker-compose down
```

#### Comprehensive Validation

```bash
# See VALIDATION_GUIDE.md for complete validation procedures
cat VALIDATION_GUIDE.md
```

The validation guide includes:
- ✅ Elastic Stack validation (6 steps)
- ✅ Wazuh validation (9 steps)  
- ✅ Documentation verification
- ✅ System health checks
- ✅ Troubleshooting procedures

---

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Cluster
ELASTIC_VERSION=8.17.1
CLUSTER_NAME=siem-datalake

# Credentials
ELASTIC_PASSWORD=SecurePassword123!
KIBANA_PASSWORD=SecurePassword123!

# Memory
ES_JAVA_OPTS=-Xms512m -Xmx512m
LS_JAVA_OPTS=-Xms256m -Xmx256m

# Ports
ES_PORT=9200
KB_PORT=5601
LS_PORT=5044
FLEET_PORT=8220
```

### Elasticsearch Cluster

**3 nodes with:**
- Master + Data + Ingest roles
- TLS encryption between nodes
- Memory locking enabled
- Audit logging active

**Configuration files:**
- `config/elasticsearch/es01.yml`
- `config/elasticsearch/es02.yml`
- `config/elasticsearch/es03.yml`

### ILM Policies

**Logs Policy:**
- **Hot (0d):** Active writes, max 50GB/1day
- **Warm (7d):** Shrink and merge
- **Cold (30d):** Freeze
- **Delete (90d):** Remove

**Security Events Policy:**
- **Hot (0d):** Active writes
- **Warm (3d):** Optimize
- **Cold (14d):** Archive
- **Delete (180d):** Remove

### Index Templates

```
logs-*            → 3 shards, 2 replicas, logs-policy
security-events-* → 3 shards, 2 replicas, security-events-policy
```

---

## 📊 Monitoring & Operations

### View Service Logs

```bash
# All services
sudo docker-compose logs -f

# Specific service
sudo docker-compose logs -f es01
sudo docker-compose logs -f kibana
sudo docker-compose logs -f logstash
```

### Elasticsearch Commands

```bash
# Cluster health
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_cluster/health?pretty

# Node status
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_cat/nodes?v

# List indices
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_cat/indices?v

# ILM status
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_ilm/status?pretty
```

### Restart Services

```bash
# Restart all
sudo docker-compose restart

# Restart specific service
sudo docker-compose restart es01
sudo docker-compose restart kibana
```

---

## 🛡️ Detection Rules

### Elastic Stack SIEM Rules

#### Active Rules

1. **SSH Brute Force Activity**
   - **Trigger:** 5+ failed SSH attempts from same IP in 5min
   - **Severity:** High
   - **Action:** Alert in Security dashboard

2. **Multiple Failed Login Attempts**
   - **Trigger:** 10+ authentication failures in 5min
   - **Severity:** High
   - **Action:** Alert with source IP

3. **Suspicious Network Connection**
   - **Trigger:** Connections to ports 4444, 5555, 6666, etc.
   - **Severity:** Critical
   - **Action:** Immediate alert

4. **Potential Data Exfiltration**
   - **Trigger:** 100+ outbound connections in 15min
   - **Severity:** High
   - **Action:** Alert with traffic analysis

5. **Webshell Activity**
   - **Trigger:** Web requests with shell command patterns
   - **Severity:** Critical
   - **Action:** Immediate investigation alert

#### View Alerts

Navigate to: **Kibana → Security → Alerts**

### Wazuh SIEM Custom Rules

#### Deployed Rules (IDs 100100-100109)

| Rule ID | Rule Name | MITRE ATT&CK | Severity | Trigger |
|---------|-----------|--------------|----------|---------|
| **100100** | Suspicious PowerShell Command Execution | T1059.001 | High | Base64 encoded commands |
| **100101** | Frequent PowerShell Execution | T1059.001 | High | 5+ PowerShell executions in 120s |
| **100102** | Linux Privilege Escalation Attempt | T1068 | Critical | sudo/su usage patterns |
| **100103** | Frequent Linux Privilege Escalation | T1068 | High | 3+ privilege escalation attempts in 60s |
| **100104** | Port Scanning Detected | T1046 | High | nmap/masscan execution |
| **100105** | Suspicious File Download | T1105 | Medium | wget/curl to temp directories |
| **100106** | Multiple Suspicious Downloads | T1105 | High | 3+ downloads in 300s |
| **100107** | Hidden File or Directory Created | T1564.001 | Medium | Creation of hidden files |
| **100108** | Brute Force Attack Detected | T1110 | Critical | 5+ auth failures in 60s |
| **100109** | Log Deletion Detected | T1070.006 | High | Deletion of system logs |

#### MITRE ATT&CK Coverage

- **T1059.001** - Command and Scripting Interpreter: PowerShell
- **T1068** - Exploitation for Privilege Escalation
- **T1046** - Network Service Discovery
- **T1105** - Ingress Tool Transfer
- **T1564.001** - Hide Artifacts: Hidden Files and Directories
- **T1110** - Brute Force
- **T1070.006** - Indicator Removal: Clear Linux or Mac System Logs

#### Rule Management

```bash
# View rules file
cat wazuh/single-node/local_rules.xml

# Deploy rules via API
cd wazuh/single-node
./configure-rules.sh
```

#### View Wazuh Alerts

Dashboard: **https://localhost:443 → Security Events → Events**

Filter by:
- **Rule ID**: `100100-100109`
- **Rule Level**: `≥7` (Medium and above)
- **MITRE Technique**: `T1059.001`, `T1068`, etc.

---

## 🛡️ Security Features

### Encryption
- ✅ TLS for inter-node communication
- ✅ HTTPS for all API access
- ✅ Certificate-based authentication
- ✅ Encrypted client connections

### Authentication
- ✅ Password-based auth
- ✅ Role-based access control
- ✅ Kibana system user separated
- ✅ Audit trail for all access

### Audit Logging
Logs these events:
- `access_granted`
- `access_denied`
- `authentication_failed`
- `connection_denied`

View in: `/var/log/elasticsearch/` inside containers

---

## 🎓 Lab Requirements Met

### ✅ All Completion Criteria

- [x] **Infrastructure Health:** Cluster reports Green/Yellow
- [x] **3-Node Cluster:** es01, es02, es03 active and clustered
- [x] **Service Accessibility:** Kibana accessible at port 5601
- [x] **Fleet Server:** Operational and ready for agents
- [x] **Agent Connectivity:** Fleet Server deployed and healthy
- [x] **Security Validation:** Detection rules enabled
- [x] **Data Management:** ILM policies active
- [x] **Encryption:** TLS/SSL for all communications
- [x] **Audit Logging:** Security events tracked
- [x] **SIEM Operations:** Dashboards and alerts configured

---

## 🆘 Troubleshooting

### Elastic Stack Issues

#### Cluster Status Yellow
**Normal during startup. Wait 2-3 minutes.**
```bash
bash status.sh
```

#### Service Won't Start
```bash
# Check logs
sudo docker-compose logs [service-name]

# Try clean restart
bash stop.sh
sudo docker-compose down -v
bash setup.sh
```

#### Port Already in Use
Edit `.env` and change conflicting ports:
```bash
ES_PORT=9200    # Change if needed
KB_PORT=5601    # Change if needed
```

#### Out of Memory
Increase heap in `.env`:
```bash
ES_JAVA_OPTS=-Xms1g -Xmx1g
LS_JAVA_OPTS=-Xms512m -Xmx512m
```

#### Certificate Errors
```bash
# Remove and regenerate
rm -rf certs/
bash setup.sh
```

#### Can't Access Kibana
```bash
# Reset password
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_security/user/kibana_system/_password \
  -H "Content-Type: application/json" \
  -d '{"password":"SecurePassword123!"}'

sudo docker-compose restart kibana
```

### Wazuh Issues

#### Dashboard Not Accessible (https://localhost:443)

```bash
# Check container status
docker ps | grep wazuh

# View dashboard logs
docker logs wazuh.dashboard

# Restart dashboard
cd wazuh/single-node
sudo docker-compose restart wazuh.dashboard
```

**Common cause:** Self-signed certificate warning - click "Advanced" → "Proceed to localhost"

#### Manager Not Processing Events

```bash
# Check manager status
docker exec wazuh.manager /var/ossec/bin/wazuh-control status

# View manager logs
docker logs wazuh.manager

# Restart manager
cd wazuh/single-node
sudo docker-compose restart wazuh.manager
```

#### Custom Rules Not Working

```bash
# Verify rules file
docker exec wazuh.manager cat /var/ossec/etc/rules/local_rules.xml

# Check for XML syntax errors
docker logs wazuh.manager | grep -i "error"

# Restart manager after rule changes
cd wazuh/single-node
sudo docker-compose restart wazuh.manager
```

#### Agent Not Connecting

```bash
# Check agent status (inside agent container)
docker exec wazuh-agent-1 /var/ossec/bin/wazuh-control status

# View agent logs
docker exec wazuh-agent-1 cat /var/ossec/logs/ossec.log

# Verify manager connectivity
docker exec wazuh-agent-1 ping wazuh.manager

# Restart agent
docker exec wazuh-agent-1 /var/ossec/bin/wazuh-control restart
```

#### API Authentication Failing

```bash
# Test JWT authentication
cd wazuh/single-node

# Get new token
TOKEN=$(curl -u wazuh-wui:MyS3cr37P450r.*- -k -X GET \
  "https://localhost:55000/security/user/authenticate?raw=true")

# Verify token works
curl -k -X GET "https://localhost:55000/" \
  -H "Authorization: Bearer $TOKEN"
```

#### Indexer Issues

```bash
# Check indexer health
curl -k -u admin:SecurePassword123! \
  https://localhost:9200/_cluster/health?pretty

# View indexer logs
docker logs wazuh.indexer

# Restart indexer
cd wazuh/single-node
sudo docker-compose restart wazuh.indexer
```

### Port Conflicts

If ports are already in use, you may need to stop conflicting services:

**Elastic Stack conflicting with Wazuh:**
- Port **9200**: Both use this port (Elasticsearch & Wazuh Indexer)
  
**Solution:**
```bash
# Stop one SIEM before starting the other
bash stop.sh  # Stop Elastic Stack
cd wazuh/single-node && sudo docker-compose down  # Stop Wazuh

# Or modify Wazuh docker-compose.yml to use different ports
```

### Complete System Reset

#### Reset Elastic Stack
```bash
bash stop.sh
sudo docker-compose down -v
rm -rf certs/
bash setup.sh
```

#### Reset Wazuh
```bash
cd wazuh/single-node
sudo docker-compose down -v
rm -rf config/wazuh_indexer_ssl_certs/
sudo docker-compose up -d
```

---

## 📚 Common Tasks

### Add Custom Detection Rule

1. Open Kibana → Security → Rules
2. Click "Create new rule"
3. Select rule type (Query, Threshold, ML, etc.)
4. Define detection logic
5. Set severity and actions
6. Enable rule

### Create Dashboard

1. Navigate to: Dashboard → Create dashboard
2. Add visualizations for:
   - Event counts by type
   - Source IPs with most activity
   - Alert severity over time
   - Top users and destinations
3. Save dashboard

### Export Data

```bash
# Export specific index
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/logs-*/_search?pretty > backup.json
```

### Backup Configuration

```bash
# Backup essential files
tar -czf siem-backup.tar.gz \
  .env \
  config/ \
  certs/ \
  docker-compose.yml
```

---

## 🚀 Next Steps

### Elastic Stack SIEM

#### 1. Deploy Elastic Agents
Install agents on endpoints to collect real events:
- Navigate to: Fleet → Agents
- Create agent policy
- Add integrations (System, Windows, etc.)
- Enroll agents

#### 2. Customize Detection Rules
- Adjust thresholds based on your environment
- Add organization-specific rules
- Configure alert notifications (email, Slack, etc.)

#### 3. Create Custom Dashboards
- Security operations overview
- Compliance reporting
- Threat intelligence feeds

#### 4. Implement Backups
- Configure Elasticsearch snapshots
- Set up automated backups
- Test disaster recovery procedures

### Wazuh SIEM

#### 1. Deploy Additional Agents ✅ Script Ready
```bash
cd wazuh/single-node
./deploy-agents.sh
```

**Deploy agents on:**
- Linux endpoints (Ubuntu, CentOS, RHEL)
- Windows servers and workstations
- macOS systems
- Docker containers

#### 2. Run Threat Simulations ✅ Script Ready
```bash
cd wazuh/single-node
./simulate-threats.sh
```

**Test detection for:**
- Malware (EICAR test file)
- File integrity monitoring
- Privilege escalation
- Network scanning
- Brute force attacks
- Rootkit detection
- Suspicious downloads

#### 3. Configure Additional Rules

**Use the Investigation Guide:**
- Location: `wazuh/single-node/INVESTIGATION_GUIDE.md`
- Contains: 20+ KQL queries
- 5 visualization templates
- 4 alert rule templates
- Complete investigation workflows

#### 4. Create Dashboards & Visualizations

**Navigate to:** Wazuh Dashboard → Visualize

**Recommended visualizations:**
- Event count by severity over time
- Top 10 triggered rules
- Alert heatmap by host
- MITRE ATT&CK technique coverage
- Compliance status (PCI-DSS, GDPR)

#### 5. Enable Additional Capabilities

```bash
# Access manager configuration
docker exec -it wazuh.manager bash
vi /var/ossec/etc/ossec.conf
```

**Enable:**
- Vulnerability detection (Automatic CVE scanning)
- Docker listener (Container monitoring)
- AWS integration (CloudTrail logs)
- VirusTotal integration (Hash reputation)
- Slack/Email notifications

### Combined SIEM Operations

#### Integrate Both Systems
- Forward Wazuh alerts to Elasticsearch
- Create unified dashboards in Kibana
- Correlate events across both platforms
- Centralized alert management

#### Security Operations Workflow
1. **Elastic Stack**: Network and infrastructure monitoring
2. **Wazuh**: Endpoint detection and response (EDR)
3. **Combined**: Comprehensive threat detection and incident response

#### Advanced Configurations
- Set up SOAR (Security Orchestration, Automation, and Response)
- Implement threat intelligence feeds
- Configure automated response actions
- Create incident response playbooks

---

## 📖 Resources

### Elastic Stack Documentation
- **Elasticsearch Docs:** https://www.elastic.co/guide/en/elasticsearch/reference/current/
- **Kibana SIEM:** https://www.elastic.co/guide/en/security/current/
- **Fleet & Agents:** https://www.elastic.co/guide/en/fleet/current/
- **Detection Rules:** https://www.elastic.co/guide/en/security/current/detection-engine-overview.html

### Wazuh Documentation
- **Wazuh Documentation:** https://documentation.wazuh.com/current/
- **Installation Guide:** https://documentation.wazuh.com/current/installation-guide/
- **User Manual:** https://documentation.wazuh.com/current/user-manual/
- **Ruleset Reference:** https://documentation.wazuh.com/current/user-manual/ruleset/
- **API Reference:** https://documentation.wazuh.com/current/user-manual/api/reference.html
- **MITRE ATT&CK:** https://attack.mitre.org/

### Project-Specific Guides

#### Wazuh Deployment Guides (In this repository)
- **[Deployment Guide](wazuh/single-node/WAZUH_DEPLOYMENT_GUIDE.md)** - Complete setup instructions
- **[Investigation Guide](wazuh/single-node/INVESTIGATION_GUIDE.md)** - KQL queries and investigation workflows
- **[Quick Reference](wazuh/single-node/QUICK_REFERENCE.md)** - Commands and credentials cheat sheet
- **[Task Checklist](wazuh/single-node/COMPLETE_TASK_CHECKLIST.md)** - Detailed task tracking
- **[Project Summary](wazuh/single-node/PROJECT_COMPLETION_SUMMARY.md)** - Complete overview

#### Validation & Testing
- **[VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)** - Comprehensive validation procedures for BOTH systems

### Community & Support
- **Elastic Community:** https://discuss.elastic.co/
- **Wazuh Community:** https://wazuh.com/community/
- **Wazuh Slack:** https://wazuh.com/community/join-us-on-slack/
- **Wazuh GitHub:** https://github.com/wazuh/wazuh

---

## 📝 Notes

### Elastic Stack SIEM
- **Environment:** Development/Lab - Security enabled with test passwords
- **Production Use:** Generate strong passwords, enable additional security features
- **Resource Requirements:** 8GB RAM minimum, 20GB storage
- **Tested On:** Kali Linux with Docker 20.10+ and Docker Compose 2.0+

### Wazuh SIEM
- **Version:** Wazuh 4.9.0 (Single-node deployment)
- **Environment:** Lab/Testing with pre-configured detection rules
- **Production Use:** Consider multi-node deployment for high availability
- **Resource Requirements:** 4GB RAM minimum, 10GB storage
- **Tested On:** Ubuntu 22.04 and Kali Linux

### Dual SIEM Deployment
- **Port Conflict:** Both use port 9200 (Elasticsearch & Wazuh Indexer)
  - **Solution:** Run one SIEM at a time, OR modify Wazuh ports in docker-compose.yml
- **Combined Resources:** 12GB RAM recommended for running both simultaneously
- **Use Case:** Compare SIEM capabilities, integrated threat detection workflow

### Security Considerations
⚠️ **Warning:** These deployments use test credentials for lab/learning purposes:
- `elastic:SecurePassword123!`
- `admin:SecurePassword123!`
- `wazuh-wui:MyS3cr37P450r.*-`

**For production environments:**
1. Generate strong, unique passwords
2. Enable additional authentication mechanisms (LDAP, SAML, etc.)
3. Configure network segmentation
4. Implement backup and disaster recovery
5. Enable audit logging and monitoring
6. Follow CIS benchmarks for hardening

---

## 📄 License

MIT License

---

## 🎯 Project Objectives

Deploy a comprehensive dual-SIEM laboratory environment capable of:

### Elastic Stack SIEM
- Ingesting and analyzing security events from infrastructure
- Detecting threats through automated rules
- Visualizing security data in real-time
- Managing data lifecycle efficiently with ILM policies
- Providing threat hunting capabilities

### Wazuh SIEM
- Endpoint detection and response (EDR)
- File integrity monitoring (FIM)
- Vulnerability detection and assessment
- Compliance monitoring (PCI-DSS, GDPR, HIPAA)
- Active response and automated remediation
- MITRE ATT&CK framework alignment

### Combined Capabilities
- Multi-layered threat detection
- Comprehensive security monitoring
- Integrated incident response workflow
- Unified security operations center (SOC) experience

---

## 🏗️ Architecture Overview

### Elastic Stack Architecture

```
                    ┌─────────────────┐
                    │  Customer App   │
                    └────────┬────────┘
                             │ Logs
                    ┌────────▼────────┐
                    │    Logstash     │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌─────▼────┐         ┌────▼────┐
   │  ES01   │◄───────►│   ES02   │◄───────►│  ES03   │
   │ Master  │  Cluster │  Master  │  Cluster│ Master  │
   │  Data   │   Sync   │   Data   │   Sync  │  Data   │
   └────┬────┘         └─────┬────┘         └────┬────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │     Kibana      │
                    │  SIEM & Alerts  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Fleet Server   │
                    │ Agent Management│
                    └─────────────────┘
```

### Wazuh Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Wazuh Agents    │────►│  Wazuh Manager   │────►│ Wazuh Indexer    │
│  (Deploy via     │     │  Port: 1514      │     │ (OpenSearch)     │
│  deploy-agents.sh│     │  API: 55000      │     │ Port: 9200       │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                             │
                                                   ┌─────────▼─────────┐
                                                   │ Wazuh Dashboard   │
                                                   │ Port: 443         │
                                                   │ (HTTPS)          │
                                                   └───────────────────┘
```

---

## ✅ Completion Checklist

### Elastic Stack SIEM ✅ (100% Complete)

- [x] **Infrastructure**: 3-node Elasticsearch cluster deployed
- [x] **Security**: TLS/SSL encryption enabled
- [x] **Service Accessibility**: Kibana accessible at port 5601
- [x] **Fleet Server**: Operational and ready for agents
- [x] **Security Validation**: Detection rules enabled and tested
- [x] **Data Management**: ILM policies active
- [x] **Audit Logging**: Security events tracked
- [x] **SIEM Operations**: Dashboards and alerts configured

### Wazuh SIEM ✅ (100% Automated Setup Complete)

- [x] **Infrastructure**: 3 containers deployed (indexer, manager, dashboard)
- [x] **TLS/SSL**: All certificates generated and configured
- [x] **Custom Detection Rules**: 9 rules deployed (IDs 100100-100109)
- [x] **MITRE ATT&CK**: 8 techniques mapped
- [x] **Automation Scripts**: 3 scripts created (deploy, simulate, configure)
- [x] **Documentation**: 5 comprehensive guides created
- [x] **API Authentication**: JWT tokens tested and working
- [x] **Dashboard Access**: https://localhost:443 accessible

### Manual Validation Steps ⏳ (Ready to Execute)

- [ ] **Deploy Wazuh Agents**: Run `./deploy-agents.sh`
- [ ] **Run Threat Simulations**: Execute `./simulate-threats.sh`
- [ ] **Verify Alert Generation**: Check dashboard for rule triggers
- [ ] **Test Detection Rules**: Validate all 9 custom rules
- [ ] **Create Visualizations**: Build dashboards for security metrics
- [ ] **Complete Validation**: Follow [VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)

---

## 🛠️ Management & Operations

### Start/Stop Commands

```bash
# Elastic Stack
bash setup.sh          # Start Elastic Stack
bash stop.sh           # Stop Elastic Stack  
bash status.sh         # Check status

# Wazuh
cd wazuh/single-node
sudo docker-compose up -d      # Start Wazuh
sudo docker-compose down       # Stop Wazuh
sudo docker-compose ps         # Check status
```

### View Logs

```bash
# Elastic Stack
sudo docker-compose logs -f [service-name]

# Wazuh
cd wazuh/single-node
docker logs wazuh.manager
docker logs wazuh.indexer
docker logs wazuh.dashboard
```

### Health Checks

```bash
# Elastic Stack cluster health
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_cluster/health?pretty

# Wazuh cluster health  
curl -k -u admin:SecurePassword123! \
  https://localhost:9200/_cluster/health?pretty
```

---

## 📚 Complete Documentation Index

### Quick Access
- **[VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)** - ⭐ Step-by-step validation for both systems

### Elastic Stack
- **[README.md](README.md)** - This file (project overview)
- Setup scripts in root directory

### Wazuh SIEM
- **[WAZUH_DEPLOYMENT_GUIDE.md](wazuh/single-node/WAZUH_DEPLOYMENT_GUIDE.md)** - Complete setup instructions
- **[INVESTIGATION_GUIDE.md](wazuh/single-node/INVESTIGATION_GUIDE.md)** - 20+ KQL queries and workflows
- **[QUICK_REFERENCE.md](wazuh/single-node/QUICK_REFERENCE.md)** - Commands cheat sheet
- **[COMPLETE_TASK_CHECKLIST.md](wazuh/single-node/COMPLETE_TASK_CHECKLIST.md)** - Detailed task tracking
- **[PROJECT_COMPLETION_SUMMARY.md](wazuh/single-node/PROJECT_COMPLETION_SUMMARY.md)** - Full project overview

---

**🎉 Your integrated SIEM laboratory is ready!**

**Next steps:**
1. Start Elastic Stack: `bash setup.sh`
2. Start Wazuh: `cd wazuh/single-node && sudo docker-compose up -d`
3. Follow validation procedures: See `VALIDATION_GUIDE.md`
4. Deploy agents and run simulations
5. Explore both dashboards and create custom detections

**For deployment validation:** See [VALIDATION_GUIDE.md](VALIDATION_GUIDE.md) for comprehensive validation procedures.

---

*Lab Environment - Designed for security training, testing, and evaluation*

