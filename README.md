# SIEM & Data Lake with Elastic Stack

Production-grade Security Information and Event Management (SIEM) system with a 3-node Elasticsearch cluster, Kibana SIEM, Fleet Server, and comprehensive security monitoring.

---

## 🚀 Quick Start

### Start Everything
```bash
bash setup.sh
```
**Takes 5-10 minutes. Deploys entire SIEM infrastructure.**

### Stop Everything
```bash
bash stop.sh
```

### Check Status
```bash
bash status.sh
```

---

## 📋 What's Included

### Infrastructure
- ✅ **3-node Elasticsearch cluster** (es01, es02, es03)
- ✅ **Kibana with SIEM** features enabled
- ✅ **Fleet Server** for agent management
- ✅ **Logstash** for log processing
- ✅ **Python Flask app** for log generation

### Security
- ✅ **TLS/SSL encryption** (all communications)
- ✅ **X-Pack Security** enabled
- ✅ **Audit logging** configured
- ✅ **Authentication** required

### Data Management
- ✅ **ILM policies** (Hot/Warm/Cold/Delete phases)
- ✅ **Index templates** with proper sharding
- ✅ **Automated rollover** and retention

### Detection Rules
- ✅ SSH Brute Force Detection
- ✅ Multiple Failed Login Attempts
- ✅ Suspicious Network Connections
- ✅ Data Exfiltration Detection
- ✅ Webshell Activity Detection

---

## 🔐 Access Information

| Service | URL | Credentials |
|---------|-----|-------------|
| **Kibana** | http://localhost:5601 | elastic / SecurePassword123! |
| **Elasticsearch** | https://localhost:9200 | elastic / SecurePassword123! |
| **Customer API** | http://localhost:8081 | None |

---

## 📁 Project Structure

```
elk-setup-docker-compose/
├── app/                       # Python Flask application
│   ├── app.py                # Main REST API
│   ├── models.py             # Customer data models
│   └── log_config.py         # Logging to Logstash
│
├── config/                    # Service configurations
│   ├── elasticsearch/        # ES node configs (es01, es02, es03)
│   ├── kibana/              # Kibana SIEM config
│   └── fleet-server/        # Fleet management
│
├── logstash/                 # Logstash pipeline
│   └── pipeline/
│       └── logstash.conf    # Processing with ILM
│
├── certs/                    # TLS certificates (auto-generated)
│
├── .env                      # Environment variables
├── docker-compose.yml        # All services orchestration
│
├── setup.sh                  # 🚀 START EVERYTHING
├── stop.sh                   # 🛑 STOP EVERYTHING
├── status.sh                 # 📊 CHECK STATUS
├── simulate-events.sh        # 🚨 GENERATE TEST EVENTS
│
└── README.md                 # This file
```

---

## 🎯 Usage Guide

### 1. Initial Deployment

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

### 2. Access Kibana

Open browser: **http://localhost:5601**

Login:
- **Username:** elastic  
- **Password:** SecurePassword123!

Navigate to:
- **Security → Overview** - Security dashboard
- **Security → Alerts** - Detection alerts
- **Discover** - Search logs
- **Management → Fleet** - Agent management

### 3. Generate Test Events

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

### 4. Test Customer API

```bash
# Health check
curl http://localhost:8081/health

# Get all customers
curl http://localhost:8081/api/v1/customers/all | jq

# Get specific customer
curl "http://localhost:8081/api/v1/customers?customerId=<ID>" | jq
```

Logs automatically sent to Elasticsearch via Logstash.

### 5. Check System Status

```bash
bash status.sh
```

Shows:
- Docker containers status
- Elasticsearch cluster health
- Kibana accessibility
- Customer service status

### 6. Stop Everything

```bash
# Stop services (keep data)
bash stop.sh

# Stop and remove all data
sudo docker-compose down -v
```

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

##  Detection Rules

### Active Rules

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

### View Alerts

Navigate to: **Kibana → Security → Alerts**

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

### Cluster Status Yellow
**Normal during startup. Wait 2-3 minutes.**
```bash
bash status.sh
```

### Service Won't Start
```bash
# Check logs
sudo docker-compose logs [service-name]

# Try clean restart
bash stop.sh
sudo docker-compose down -v
bash setup.sh
```

### Port Already in Use
Edit `.env` and change conflicting ports:
```bash
ES_PORT=9200    # Change if needed
KB_PORT=5601    # Change if needed
```

### Out of Memory
Increase heap in `.env`:
```bash
ES_JAVA_OPTS=-Xms1g -Xmx1g
LS_JAVA_OPTS=-Xms512m -Xmx512m
```

### Certificate Errors
```bash
# Remove and regenerate
rm -rf certs/
bash setup.sh
```

### Can't Access Kibana
```bash
# Reset password
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_security/user/kibana_system/_password \
  -H "Content-Type: application/json" \
  -d '{"password":"SecurePassword123!"}'

sudo docker-compose restart kibana
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

### 1. Deploy Elastic Agents
Install agents on endpoints to collect real events:
- Navigate to: Fleet → Agents
- Create agent policy
- Add integrations (System, Windows, etc.)
- Enroll agents

### 2. Customize Detection Rules
- Adjust thresholds based on your environment
- Add organization-specific rules
- Configure alert notifications (email, Slack, etc.)

### 3. Create Custom Dashboards
- Security operations overview
- Compliance reporting
- Threat intelligence feeds

### 4. Implement Backups
- Configure Elasticsearch snapshots
- Set up automated backups
- Test disaster recovery procedures

---

## 📖 Resources

- **Elasticsearch Docs:** https://www.elastic.co/guide/en/elasticsearch/reference/current/
- **Kibana SIEM:** https://www.elastic.co/guide/en/security/current/
- **Fleet & Agents:** https://www.elastic.co/guide/en/fleet/current/
- **Detection Rules:** https://www.elastic.co/guide/en/security/current/detection-engine-overview.html

---

## 📝 Notes

- **Development Environment:** Security is enabled but with simple passwords
- **Production Use:** Generate strong passwords, enable additional security features
- **Resource Requirements:** 8GB RAM minimum, 20GB storage
- **Tested On:** Kali Linux with Docker 20.10+ and Docker Compose 2.0+

---

## 📄 License

MIT License

---

**🎉 Your SIEM is ready! Run `bash setup.sh` to get started.**

## 🎯 Objective

Deploy a complete SIEM infrastructure capable of:
- Ingesting and analyzing security events
- Detecting threats through automated rules
- Visualizing security data in real-time
- Managing data lifecycle efficiently
- Providing threat hunting capabilities

## 🏗️ Architecture

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

## ✅ Features Implemented

### Infrastructure (100% Complete)
- ✅ Three-node Elasticsearch cluster ("siem-datalake")
- ✅ Master/Data node roles defined
- ✅ Memory locking enabled
- ✅ Docker Compose orchestration
- ✅ Persistent storage volumes

### Security & Encryption (100% Complete)
- ✅ TLS/SSL certificates (CA + node certificates)
- ✅ Encrypted transport layer between nodes
- ✅ Encrypted HTTP layer
- ✅ X-Pack security enabled
- ✅ Audit logging configured
- ✅ Authentication required

### SIEM & Monitoring (100% Complete)
- ✅ Kibana with SIEM Solution enabled
- ✅ Security detection rules configured
- ✅ Alert management
- ✅ Fleet Server deployed
- ✅ Logstash pipeline with filtering

### Data Management (100% Complete)
- ✅ ILM policies (Hot/Warm/Cold/Delete phases)
- ✅ Index templates with proper sharding
- ✅ Automated rollover
- ✅ Data retention policies

### Detection Rules (100% Complete)
- ✅ SSH Brute Force Detection
- ✅ Multiple Failed Login Attempts
- ✅ Suspicious Network Connections
- ✅ Potential Data Exfiltration
- ✅ Webshell Activity Detection

## 📋 Prerequisites

- **Hardware**: 8GB RAM minimum, 20GB free storage
- **Software**: Docker 20.10+, Docker Compose 2.0+
- **OS**: Linux (tested on Kali Linux)
- **Tools**: curl, jq (for health checks)

## 🚀 Quick Start

### 1. Clone and Navigate
```bash
cd /home/amrhamada/Documents/elk-setup-docker-compose
```

### 2. Review Configuration
Check the `.env` file for passwords and ports:
```bash
cat .env
```

### 3. Run Complete Setup
```bash
sudo bash setup.sh
```

This automated script will:
1. Generate TLS certificates
2. Start 3-node Elasticsearch cluster
3. Configure Kibana with SIEM features
4. Deploy Fleet Server
5. Start Logstash
6. Enable security detection rules
7. Start customer service application

**⏱️ Setup takes approximately 5-10 minutes**

### 4. Verify Installation
```bash
sudo bash check-health.sh
```

### 5. Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Kibana** | http://localhost:5601 | elastic / SecurePassword123! |
| **Elasticsearch** | https://localhost:9200 | elastic / SecurePassword123! |
| **Customer Service** | http://localhost:8081 | No auth |

## 📁 Project Structure

```
.
├── app/                          # Python Flask application
│   ├── app.py                   # Main application
│   ├── models.py                # Customer data models
│   └── log_config.py            # Logging configuration
├── config/                       # Service configurations
│   ├── elasticsearch/           # ES node configs
│   │   ├── es01.yml
│   │   ├── es02.yml
│   │   └── es03.yml
│   ├── kibana/
│   │   └── kibana.yml           # Kibana SIEM config
│   └── fleet-server/            # Fleet configurations
├── logstash/
│   └── pipeline/
│       └── logstash.conf        # Pipeline with ILM
├── certs/                        # TLS/SSL certificates
│   ├── ca/
│   │   ├── ca.crt               # Certificate Authority
│   │   └── ca.key
│   ├── es01.crt/key             # Node 01 certificates
│   ├── es02.crt/key             # Node 02 certificates
│   └── es03.crt/key             # Node 03 certificates
├── docker-compose.yml            # Complete stack definition
├── .env                          # Environment variables
├── setup.sh                      # Master setup script
├── check-health.sh               # Health verification
├── setup-ilm.sh                  # ILM policy configuration
├── setup-detection-rules.sh      # Security rules setup
├── simulate-events.sh            # Security event simulator
├── generate-certs.sh             # Certificate generator
└── README.md                     # This file
```

## 🔒 Security Configuration

### TLS/SSL Certificates
Certificates are generated for:
- Certificate Authority (CA)
- Each Elasticsearch node (es01, es02, es03)
- All inter-node communication
- HTTP API communication

### Audit Logging
Events logged:
- `access_granted`
- `access_denied`
- `authentication_failed`
- `connection_denied`

### Node Roles
Each node has roles:
- **Master**: Cluster management
- **Data**: Storage and indexing
- **Ingest**: Data preprocessing

## 📊 Index Lifecycle Management (ILM)

### Logs Policy
- **Hot Phase (0d)**: Active indexing, max 50GB or 1 day
- **Warm Phase (7d)**: Shrink and forcemerge
- **Cold Phase (30d)**: Frozen for cost savings
- **Delete Phase (90d)**: Automatic deletion

### Security Events Policy
- **Hot Phase (0d)**: Active indexing
- **Warm Phase (3d)**: Optimized storage
- **Cold Phase (14d)**: Archival
- **Delete Phase (180d)**: Long-term retention

## 🎯 Detection Rules

### Enabled Rules
1. **SSH Brute Force**: 5+ failed attempts from same IP
2. **Multiple Failed Logins**: 10+ authentication failures
3. **Suspicious Network Connections**: Connections to common C2 ports
4. **Potential Data Exfiltration**: 100+ outbound connections
5. **Webshell Activity**: Known webshell patterns in web requests

### View Alerts
Navigate to: **Kibana → Security → Alerts**

## 🧪 Testing & Simulation

### Generate Test Security Events
```bash
sudo bash simulate-events.sh
```

This creates:
- 10 SSH brute force attempts
- 15 failed login attempts
- 3 suspicious network connections
- 120 data exfiltration events
- 3 webshell activities
- 5 successful authentications

### Test Customer Service API
```bash
# Health check
curl http://localhost:8081/health

# Get all customers
curl http://localhost:8081/api/v1/customers/all

# Get specific customer
curl "http://localhost:8081/api/v1/customers?customerId={ID}"
```

## 🔍 Monitoring & Operations

### Check Cluster Health
```bash
sudo bash check-health.sh
```

### View Cluster Status
```bash
curl -k -u elastic:SecurePassword123! https://localhost:9200/_cluster/health?pretty
```

### Check Node Status
```bash
curl -k -u elastic:SecurePassword123! https://localhost:9200/_cat/nodes?v
```

### View Indices
```bash
curl -k -u elastic:SecurePassword123! https://localhost:9200/_cat/indices?v
```

### Check ILM Status
```bash
curl -k -u elastic:SecurePassword123! https://localhost:9200/_ilm/status?pretty
```

### View Logs
```bash
# All services
sudo docker-compose logs -f

# Specific service
sudo docker-compose logs -f es01
sudo docker-compose logs -f kibana
sudo docker-compose logs -f logstash
sudo docker-compose logs -f fleet-server
```

## 🛠️ Management Commands

### Start All Services
```bash
sudo docker-compose up -d
```

### Stop All Services
```bash
sudo docker-compose down
```

### Restart Specific Service
```bash
sudo docker-compose restart es01
```

### View Running Containers
```bash
sudo docker-compose ps
```

### Remove Everything (Including Data)
```bash
sudo docker-compose down -v
```

## 📈 SIEM Operations

### Kibana Navigation

1. **Dashboard**: Overview of security posture
2. **Discover**: Search and filter logs
3. **Security → Alerts**: View triggered alerts
4. **Security → Timelines**: Investigate incidents
5. **Security → Cases**: Track investigations
6. **Management → Stack Management**: Configure settings

### Creating Custom Queries

Example: Find failed SSH attempts
```
event.action:"ssh_login" AND event.outcome:"failure"
```

Example: Suspicious IP activity
```
source.ip:"192.168.1.100" AND event.outcome:"failure"
```

### Threat Hunting

1. Navigate to **Discover**
2. Select index pattern: `security-events-*`
3. Use KQL queries to hunt for threats
4. Save interesting queries as alerts

## 🎓 Lab Completion Checklist

- [x] **Environment Preparation**: Directory structure and .env file
- [x] **3-Node Cluster**: es01, es02, es03 active and clustered
- [x] **TLS/SSL Encryption**: CA and node certificates deployed
- [x] **Security Hardening**: Audit logging, authentication enabled
- [x] **Kibana with SIEM**: Accessible with Security Solution
- [x] **Fleet Server**: Deployed and operational
- [x] **Docker Orchestration**: Complete stack in docker-compose
- [x] **ILM Policies**: Hot/Warm/Cold/Delete phases configured
- [x] **Index Templates**: Proper sharding and mappings
- [x] **Detection Rules**: 5+ security rules enabled
- [x] **Event Simulation**: Script to generate test events
- [x] **Health Monitoring**: Automated health check script

## 🆘 Troubleshooting

### Elasticsearch Won't Start
```bash
# Check logs
sudo docker-compose logs es01

# Common issues:
# - Insufficient memory: Increase ES_JAVA_OPTS in .env
# - Port conflict: Change ES_PORT in .env
# - Certificate issues: Regenerate with generate-certs.sh
```

### Kibana Can't Connect
```bash
# Verify Elasticsearch is healthy
sudo bash check-health.sh

# Reset Kibana password
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_security/user/kibana_system/_password \
  -H "Content-Type: application/json" \
  -d '{"password":"SecurePassword123!"}'
```

### Cluster Status Yellow
```bash
# Normal for 3-node cluster during startup
# Wait 2-3 minutes for cluster to stabilize
# Check: sudo bash check-health.sh
```

### Certificate Errors
```bash
# Regenerate certificates
rm -rf certs/
bash generate-certs.sh
sudo docker-compose restart
```

## 📚 Additional Resources

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana SIEM Guide](https://www.elastic.co/guide/en/security/current/index.html)
- [Fleet and Elastic Agent](https://www.elastic.co/guide/en/fleet/current/index.html)
- [Detection Rules](https://www.elastic.co/guide/en/security/current/detection-engine-overview.html)

## 📝 License

MIT License

---

**Note**: This is a lab environment. For production use, additional hardening, monitoring, and backup strategies should be implemented.
