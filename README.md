# Integrated SOC Laboratory: Elastic Stack + Wazuh + OpenVAS/GVM + Zeek

**Complete Security Operations Center (SOC) Laboratory Environment**

Production-grade Security Operations Center laboratory featuring **endpoint, network, and vulnerability monitoring across four integrated security platforms**:

- **Elastic Stack SIEM**: 3-node Elasticsearch cluster with Kibana, Fleet Server, and comprehensive data lake capabilities
- **Wazuh SIEM**: Enterprise-grade XDR and SIEM platform with custom detection rules, agent management, and threat hunting
- **OpenVAS/GVM**: Greenbone Community Edition containerized vulnerability management for authenticated and unauthenticated security assessments with SCAP data, vulnerability tests, and NVT feed synchronization
- **Zeek NSM**: Containerized network security monitoring module that generates `conn.log` telemetry and ships it into Elasticsearch for assignment evidence and correlation workflows

### Platform Highlights

| Feature | Elastic Stack | Wazuh | OpenVAS/GVM | Zeek |
|---------|---------------|-------|------------|------|
| **Purpose** | Infrastructure SIEM & Data Lake | Endpoint EDR & SIEM | Vulnerability Management | Network Security Monitoring |
| **Access** | Kibana on 5610 | Dashboard on 9443 | GSA on 8443 | Terminal + evidence files |
| **Credentials** | elastic/SecurePassword123! | admin/SecretPassword | admin/GvmLab@2026! | None |
| **Containers** | 7 (ES cluster + Kibana + Fleet + Logstash) | 3 (Indexer + Manager + Dashboard) | 18+ (GVM + PG + Redis + Feeds) | 3 (PCAP generator + sensor + forwarder) |
| **Detection Type** | Network & Infrastructure Events | Endpoint & Behavioral | Vulnerability Scanning | Connection Telemetry |
| **Key Feature** | ILM Data Lifecycle, Real-time Alerts | File Integrity, Active Response | CVSS Risk Scoring, Task Automation | `conn.log` generation + Elastic ingest proof |

---

## 🔐 Credentials Reference

Use this section as the single source of truth for current lab credentials.

| Platform | Service | URL | Username | Password |
|----------|---------|-----|----------|----------|
| **Elastic Stack** | Kibana | http://localhost:5610 | `elastic` | `SecurePassword123!` |
| **Elastic Stack** | Elasticsearch API | https://localhost:9210 | `elastic` | `SecurePassword123!` |
| **Wazuh** | Dashboard | https://localhost:9443 | `admin` | `SecretPassword` |
| **Wazuh** | API | https://localhost:55000 | `wazuh-wui` | `MyS3cr37P450r.*-` |
| **Wazuh** | Indexer | https://localhost:9220 | `admin` | `SecretPassword` |
| **OpenVAS/GVM** | GSA Web UI | https://127.0.0.1:8443 | `admin` | `GvmLab@2026!` |
| **DVWA** | Lab Target | http://127.0.0.1:8085 | `admin` | `password` |
| **Zeek** | Sensor / Evidence Module | No web UI | `N/A` | `N/A` |

If you change the GVM password later, run `./reset-admin-password.sh` and keep this table updated.

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

**Access Kibana**: http://localhost:5610 (`elastic` / `SecurePassword123!`)

### Wazuh SIEM

```bash
# Navigate to Wazuh directory
cd wazuh/single-node

# Start Wazuh Stack
sudo docker-compose up -d
```
**Takes 3-5 minutes. Deploys 3 containers (indexer, manager, dashboard).**

**Access Dashboard**: https://localhost:9443 (`admin` / `SecretPassword`)

### OpenVAS (GVM) - Vulnerability Management

```bash
# Navigate to GVM module
cd gvm

# Step 1: Start Greenbone Community Edition (18+ containers)
./setup-gvm.sh
```
**Takes 10-30 minutes on first run (official Greenbone images + SCAP/CVE feed sync).**

```bash
# Step 2: (FIRST RUN ONLY) Set admin password for GSA
./reset-admin-password.sh
# Follow prompts for strong password (e.g., GvmLab@2026!)

# Step 3: Deploy DVWA vulnerable target for scanning
./deploy-targets.sh
# Deploys web-dvwa at http://127.0.0.1:8085 (internal IP: 172.21.0.18)

# Step 4: Check status and verify feed synchronization
./status-gvm.sh
./sync-feeds.sh
```

**Access GSA Web Interface**: https://127.0.0.1:8443

**Credentials**: 
- **Username**: `admin`
- **Password**: `GvmLab@2026!`

If you change it later, run `./reset-admin-password.sh` and update the credentials reference section above.

**Default Scan Configs Available** (after feed sync):
- Full and fast
- Base
- Discovery
- Host Discovery
- System Discovery
- Empty profile

**Target for Scanning**: `172.21.0.18` (DVWA container on internal Docker network)

### Zeek - Network Security Monitoring

```bash
# Navigate to Zeek module
cd zeek

# Make helper scripts executable
chmod +x setup-zeek.sh status-zeek.sh stop-zeek.sh collect-evidence.sh

# Start Zeek evidence module
./setup-zeek.sh

# Verify status and generated conn.log
./status-zeek.sh

# Collect Phase 1 evidence files
./collect-evidence.sh
```

**Takes 1-3 minutes. Builds sample traffic, processes it with Zeek, and stores evidence under `zeek/evidence/`.**

**Zeek outputs:**
- `zeek/logs/current/conn.log`
- `zeek/evidence/zeek-status.txt`
- `zeek/evidence/conn-sample.json`
- `zeek/evidence/elasticsearch-proof.json`

**Important:** Zeek ingestion proof requires the main Elastic stack to already be running with `bash setup.sh`.

### Validation & Testing

```bash
# See comprehensive validation procedures for Elastic and Wazuh
cat VALIDATION_GUIDE.md

# Zeek-specific evidence workflow:
cat zeek/README.md
```

---

## �️ System Requirements & Prerequisites

### Hardware Requirements

#### Minimum Configuration
- **CPU**: 4 cores (8 recommended)
- **RAM**: 12GB minimum (16GB recommended for all four platforms)
  - Elastic Stack: 4GB (3 x 1.5GB + Kibana)
  - Wazuh: 2GB (indexer + manager + dashboard)
  - GVM/OpenVAS: 4GB (gvmd + scanner + feeds + database)
  - Zeek: 1GB (sensor + forwarder + sample traffic processing)
  - OS & Other services: 2GB
- **Disk Space**: 20GB minimum
  - Elasticsearch data: 10GB minimum
  - Wazuh logs: 2GB
  - GVM feeds & scans: 5GB
  - OS & Docker images: 3GB

#### Recommended Production Configuration
- **CPU**: 8+ cores (or 4 vCPU with high clock speed)
- **RAM**: 32GB+
- **Disk**: SSD with 100GB+ capacity
- **Network**: 1Gbps connection for multi-agent environments

### Software Requirements

#### Operating System Support
- ✅ **Linux** (Primary - Ubuntu 20.04+, Kali 2024+, Debian 11+, CentOS 8+, RHEL 9+)
- ✅ **macOS** (12+ with Docker Desktop, may require additional memory)
- ✅ **Windows 10/11** (WSL2 with Docker Desktop)

#### Required Software

| Software | Version | Purpose | Documentation |
|----------|---------|---------|---|
| **Docker** | 20.10+ | Container runtime | https://docs.docker.com/install/ |
| **Docker Compose** | 2.0+ | Multi-container orchestration | https://docs.docker.com/compose/install/ |
| **Bash/ZSH** | Any | Shell scripting | Built-in on Linux/macOS |
| **curl** | Any | API testing & downloads | `apt-get install curl` |
| **jq** | 1.6+ | JSON parsing (optional) | `apt-get install jq` |
| **git** | 2.0+ | Version control (optional) | `apt-get install git` |

### Network Requirements

#### Port Allocation

| Service | Internal Port | External Port | Protocol | Purpose |
|---------|---------------|---------------|----------|---------|
| **Elasticsearch** | 9200 | 9200 | HTTPS | Cluster & API |
| **Elasticsearch Node Comm** | 9300 | 9300 | TCP | Inter-node clustering |
| **Kibana** | 5601 | 5601 | HTTP | Web UI |
| **Fleet Server** | 8220 | 8220 | HTTPS | Agent enrollment |
| **Logstash** | 5044 | 5044 | TCP | Log ingestion |
| **Customer API** | 8081 | 8081 | HTTP | Test app |
| **Wazuh Dashboard** | 443 | 443 | HTTPS | Web UI |
| **Wazuh Manager** | 1514 | 1514 | TCP/UDP | Agent communication |
| **Wazuh API** | 55000 | 55000 | HTTPS | REST API |
| **Wazuh Indexer** | 9200* | 9200* | HTTPS | Search backend |
| **GVM/OpenVAS GSA** | 443→8443 | 8443 | HTTPS | Web UI (remapped) |
| **GVM Scanner** | 9392 | 9392 | TCP | Scanner orchestration |
| **DVWA Target** | 80 | 8085 | HTTP | Lab vulnerability app |

**\* Note: Wazuh Indexer uses port 9200 (same as Elasticsearch) - cannot run both simultaneously without port reconfiguration*

#### Network Architecture

```
┌─────────────────────────────────────────────────┐
│  Host Machine                                   │
│  ┌───────────────────────────────────────────┐ │
│  │  Docker Network: siem-network/gvm-network │ │
│  │                                           │ │
│  │  ┌──────────────────────────────────────┐│ │
│  │  │ Elastic Stack SIEM                   ││ │
│  │  │ - es01, es02, es03 (9200, 9300)     ││ │
│  │  │ - kibana (5601)                      ││ │
│  │  │ - fleet-server (8220)                ││ │
│  │  │ - logstash (5044)                    ││ │
│  │  │ - customer-api (8081)                ││ │
│  │  └──────────────────────────────────────┘│ │
│  │                                           │ │
│  │  ┌──────────────────────────────────────┐│ │
│  │  │ Wazuh SIEM (separate instance)      ││ │
│  │  │ - wazuh.indexer (9200)              ││ │
│  │  │ - wazuh.manager (1514, 55000)       ││ │
│  │  │ - wazuh.dashboard (443)             ││ │
│  │  └──────────────────────────────────────┘│ │
│  │                                           │ │
│  │  ┌──────────────────────────────────────┐│ │
│  │  │ GVM/OpenVAS (gvm-network)            ││ │
│  │  │ - gvmd, gsad, nginx (8443)          ││ │
│  │  │ - ospd-openvas, openvas              ││ │
│  │  │ - pg-gvm (PostgreSQL)               ││ │
│  │  │ - pg-gvmd-data-sync                 ││ │
│  │  │ - redis, vulnerability-tests, etc.  ││ │
│  │  │ - web-dvwa (172.21.0.18)            ││ │
│  │  └──────────────────────────────────────┘│ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  localhost:5601  ← Kibana                     │
│  localhost:443   ← Wazuh (WSL/VM only)        │
│  localhost:8443  ← GVM/OpenVAS                │
└─────────────────────────────────────────────────┘
```

### Firewall & Security Considerations

If running on a remote host or with firewall enabled:

```bash
# Example: Open ports for incoming access
sudo ufw allow 5601/tcp        # Kibana
sudo ufw allow 443/tcp         # Wazuh Dashboard
sudo ufw allow 8443/tcp        # GVM/OpenVAS
sudo ufw allow 9200/tcp        # Elasticsearch (if remote)
sudo ufw allow 55000/tcp       # Wazuh API (if remote)
```

### Docker Group Configuration (Required)

Avoid using `sudo docker` by adding your user to the docker group:

```bash
# Create docker group (usually exists)
sudo groupadd docker

# Add current user to docker group
sudo usermod -aG docker $USER

# Activate group changes
newgrp docker

# Verify (should NOT require sudo)
docker ps

# Note: May need to restart shell or logout/login
```

If unable to configure docker group, all scripts include automatic fallback to `sudo docker`.

---

## 📥 Installation & Setup Guide

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

### OpenVAS/GVM (Greenbone Community Edition)

**Complete Vulnerability Management Suite - Version 26.19.0**

**Infrastructure (18+ Containers)**
- ✅ **gvmd** (Greenbone Vulnerability Manager daemon) - Task and config management
- ✅ **gsad** (Greenbone Security Assistant daemon) - Backend API server
- ✅ **nginx** - Reverse proxy and HTTPS gateway (port 8443)
- ✅ **ospd-openvas** - OpenVAS scanner protocol daemon
- ✅ **openvas** - Actual vulnerability scanner engine
- ✅ **pg-gvm** - PostgreSQL database (10GB+ for vulnerability feeds)
- ✅ **pg-gvmd-data-sync** - Postgres sync helper
- ✅ **redis** - Caching and session management
- ✅ **10+ vulnerability feed containers:**
  - `vulnerability-tests` (NVTs - 1000+ vulnerability tests)
  - `scap-data` (CPE, CVE official data from NIST)
  - `notus-data` (Greenbone advisory data)
  - `cert-bund-data` (German CERT advisories)
  - `dfn-cert-data` (DFN advisories)

**Vulnerability Detection Capabilities**
- ✅ **18,000+ vulnerability tests (NVTs)** from Greenbone
- ✅ **CVSS scoring** (v2.0, v3.0, v3.1) with risk visualization
- ✅ **SCAP integration** - Official CVE/CPE feed from NIST
- ✅ **Notus feed** - Greenbone-curated vulnerability data
- ✅ **Cert-Bund data** - German security advisories
- ✅ **DFN-CERT data** - German research institution advisories
- ✅ **Authenticated scanning** - Credential-based deep checks
- ✅ **Unauthenticated scanning** - Network-level discovery
- ✅ **API-driven scanning** via openvas/ospd

**Scanning & Task Management**
- ✅ **14 built-in scan configs** (Full and fast, Base, Discovery, Host Discovery, etc.)
- ✅ **Multiple scan types:**
  - Full and fast scan
  - Base scan
  - Network discovery
  - Host discovery
  - System discovery
  - Custom profiles
- ✅ **Target management** - Single hosts, ranges, subnets, groups
- ✅ **Port lists** - 5 predefined (All IANA TCP, All IANA UDP, OpenVAS Default, etc.)
- ✅ **Credential types** - SSH, SMB, SNMP, vCenter, Postgres, Mongo, etc.
- ✅ **Schedule scanning** - One-time or recurring tasks
- ✅ **Task automation** - Parallel scanning, alerts on completion
- ✅ **Report generation** - PDF, XML, CSV, TXT formats with customizable templates

**Lab Capabilities**
- ✅ **DVWA deployment script** (`deploy-targets.sh`) - Intentionally vulnerable web app
- ✅ **Target IP:** `172.21.0.18` (internal Docker network)
- ✅ **Web interface:** `http://127.0.0.1:8085`
- ✅ **Multiple vulnerabilities:** SQL injection, XSS, CSRF, file inclusion, etc.
- ✅ **Perfect for demonstration:** Create scan task → Run → Analyze results

**Documentation**
- ✅ [GVM OpenVAS Lab Guide](gvm/GVM_OPENVAS_LAB_GUIDE.md) - 5-phase operational guide with task checklist
- ✅ Helper scripts: `setup-gvm.sh`, `reset-admin-password.sh`, `deploy-targets.sh`, `sync-feeds.sh`, `status-gvm.sh`, `stop-gvm.sh`, `cleanup-gvm.sh`

---

## � Installation & Full Setup Guide

### Pre-Installation Checklist

- [ ] System meets minimum requirements (12GB RAM, 20GB disk, 4 cores)
- [ ] Docker and Docker Compose installed and working
- [ ] User has docker group permissions or can use sudo
- [ ] At least 30 minutes available for first deployment
- [ ] Ports 5601, 443, 8443, 9200, 1514, 55000 are available
- [ ] Project directory cloned or ready

### Step 1: Verify Prerequisites ✅

```bash
# Check Docker installation
docker --version
# Expected: Docker version 20.10+

# Check Docker Compose
docker compose --version
# Expected: Docker Compose version 2.0+

# Check available disk space (need 20GB+)
df -h /
# Look for Available column

# Check RAM (need 12GB+)
free -h
# Look for Mem: line
```

### Step 2: Navigate to Project Directory

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack"
```

### Step 3: Make Scripts Executable

```bash
# Elastic Stack scripts
chmod +x setup.sh stop.sh status.sh simulate-events.sh

# Wazuh scripts
chmod +x wazuh/single-node/deploy-agents.sh
chmod +x wazuh/single-node/simulate-threats.sh
chmod +x wazuh/single-node/configure-rules.sh

# GVM scripts
chmod +x gvm/*.sh
```

### Step 4: Deploy Elastic Stack SIEM (First Option)

**Complete deployment takes 5-10 minutes:**

```bash
# Start all Elastic Stack services
bash setup.sh

# Monitor progress in another terminal
bash status.sh

# Wait for: "Cluster Status: green" and "✅ DEPLOYMENT COMPLETE!"
```

**After Elastic deployment:**
- Open browser: http://localhost:5601
- Login: elastic / SecurePassword123!
- Verify Kibana SIEM is accessible
- Generate test events: `bash simulate-events.sh`

### Step 5: Deploy Wazuh SIEM (Second Option or Parallel)

**Complete deployment takes 3-5 minutes:**

```bash
# Navigate to Wazuh directory
cd wazuh/single-node

# Start Wazuh
sudo docker-compose up -d

# Monitor
docker-compose ps

# Wait for all 3 containers "Up" status
```

**After Wazuh deployment:**
- Open browser: https://localhost:443
- Accept self-signed certificate warning
- Login: admin / SecretPassword
- Wait 10-15 seconds for dashboard to fully load

**⚠️ Port Conflict Note:**
Elastic (port 9200) and Wazuh Indexer (port 9200) cannot run simultaneously.
- **Solution 1 (Recommended):** Stop one before starting the other
- **Solution 2:** Configure Wazuh to use different ports (9201, 9202)

### Step 6: Deploy OpenVAS/GVM (Third Option)

**Complete deployment takes 10-30 minutes (first run includes feed download):**

```bash
# Navigate to GVM directory
cd gvm

# Download Greenbone compose file and start services
./setup-gvm.sh

# This will:
# 1. Download official Greenbone docker-compose.yaml
# 2. Override ports (8443 instead of 443 to avoid Wazuh conflict)
# 3. Pull all images (~4-5GB)
# 4. Start 18+ containers
# 5. Initiate vulnerability feed downloads

# Monitor initialization progress
./status-gvm.sh

# Watch feed synchronization (takes 15-20 minutes)
# Watch logs for imports of SCAP, NVT, CERT data
sudo docker compose -f compose.yaml logs -f gvmd | grep -i "feed\|sync"
```

**After containers are running (feed sync continues in background):**

```bash
# Set admin password (FIRST RUN ONLY)
./reset-admin-password.sh
# Follow prompts, set strong password (e.g., GvmLab@2026!)

# Deploy DVWA vulnerable target for scanning lab
./deploy-targets.sh
# Creates vulnerable web app at http://127.0.0.1:8085

# Verify GVM is ready
./status-gvm.sh
```

**After feed sync completes (monitor with `./sync-feeds.sh`):**
- Open browser: https://127.0.0.1:8443
- Accept self-signed certificate warning
- Login: admin / (password from ./reset-admin-password.sh)
- Verify GSA displays available scan configs
- Ready to create vulnerability scan tasks

### Step 7: Deploy Zeek Evidence Module (Fourth Option)

```bash
# Navigate to Zeek directory
cd zeek

# Make scripts executable once
chmod +x setup-zeek.sh status-zeek.sh stop-zeek.sh collect-evidence.sh

# Start Zeek module
./setup-zeek.sh

# Verify service status and log generation
./status-zeek.sh

# Generate evidence package files
./collect-evidence.sh
```

**After Zeek deployment:**
- No browser login is required
- Verify `zeek/logs/current/conn.log` contains JSON records
- Verify `zeek/evidence/elasticsearch-proof.json` shows hits in `zeek-*`
- Use these files directly for Phase 1 evidence screenshots

### Step 8 (Optional): Deploy Wazuh Agents for Lab Testing

```bash
# Navigate to Wazuh directory
cd wazuh/single-node

# Deploy Ubuntu container with Wazuh agent
./deploy-agents.sh

# Monitors agent enrollment and connectivity
# Agent will appear in Wazuh Dashboard → Security Events
```

### Step 9 (Optional): Simulate Security Threats

```bash
# From Wazuh directory
cd wazuh/single-node

# Run threat simulations against deployed agents
./simulate-threats.sh

# Simulates:
# - EICAR malware test file
# - File integrity monitoring events
# - Privilege escalation attempts
# - Port scanning activity
# - Suspicious file downloads
# - Brute force attacks
# - Log deletion attempts
# - Rootkit signatures

# Monitor detections in Wazuh Dashboard → Security Events
# Filter by Rule IDs 100100-100109
```

### Step 10: Comprehensive System Validation ✅

```bash
# Review validation guide for Elastic and Wazuh
cat VALIDATION_GUIDE.md

# Review Zeek evidence workflow
cat zeek/README.md

# Expected validations:
# ✅ Elastic Stack: 6 validation steps
# ✅ Wazuh SIEM: 9 validation steps
# ✅ GVM/OpenVAS: 5 validation steps
# ✅ Zeek NSM: evidence workflow in zeek/README.md
# ✅ Integration: Cross-platform data flow
```

### Troubleshooting Installation Issues

#### Docker Daemon Not Running
```bash
# Start Docker (Linux)
sudo systemctl start docker

# Start Docker Desktop (macOS/Windows)
# Open Applications/Docker.app
```

#### Permission Denied on docker.sock
```bash
# Add user to docker group (and restart/relogin)
sudo usermod -aG docker $USER
newgrp docker
```

#### Port Already in Use
```bash
# Check port usage
sudo lsof -i :5601   # Kibana
sudo lsof -i :443    # Wazuh
sudo lsof -i :8443   # GVM

# Kill process or modify .env ports
# Edit docker-compose.yml and change ports
```

#### Insufficient Memory
```bash
# Check memory in Docker
docker system info | grep -i memory

# Reduce heap in .env:
ES_JAVA_OPTS=-Xms512m -Xmx512m
LS_JAVA_OPTS=-Xms256m -Xmx256m
```

#### Feed Sync Timeout (GVM)
```bash
# This is normal for feeds - can take 20-30 minutes first run
# Monitor progress
cd gvm
./sync-feeds.sh

# If needed, can force rebuild of configs after sync completes:
sudo docker compose -f compose.yaml exec -T -u gvmd gvmd \
  gvmd --feed-lock-timeout=7200 --rebuild-gvmd-data=all
```

---

## 🖥️ Complete Command Reference

| Service | URL | Credentials |
|---------|-----|-------------|
| **Kibana** | http://localhost:5610 | elastic / SecurePassword123! |
| **Elasticsearch** | https://localhost:9210 | elastic / SecurePassword123! |
| **Customer API** | http://localhost:8081 | None |

### Wazuh SIEM

| Service | URL | Credentials |
|---------|-----|-------------|
| **Wazuh Dashboard** | https://localhost:9443 | admin / SecretPassword |
| **Wazuh API** | https://localhost:55000 | wazuh-wui / MyS3cr37P450r.*- |
| **Wazuh Indexer** | https://localhost:9220 | admin / SecretPassword |

### OpenVAS (GVM)

| Service | URL | Credentials |
|---------|-----|-------------|
| **Greenbone Security Assistant (GSA)** | https://127.0.0.1:8443 | admin / GvmLab@2026! |
| **DVWA Lab Target** | http://127.0.0.1:8085 | admin / password |

### Zeek

| Service | URL | Credentials |
|---------|-----|-------------|
| **Zeek Evidence Module** | No web UI (`zeek/logs/current/conn.log`) | None |
| **Zeek Ingestion Proof** | `zeek/evidence/elasticsearch-proof.json` | Uses Elastic auth internally |

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
├── 📄 VALIDATION_GUIDE.md        # ⭐ COMPREHENSIVE VALIDATION FOR PRIMARY STACKS
│
├── 📂 zeek/
│   ├── docker-compose.yml        # Zeek evidence module orchestration
│   ├── setup-zeek.sh             # Start Zeek evidence workflow
│   ├── status-zeek.sh            # Show Zeek status + conn.log sample
│   ├── stop-zeek.sh              # Stop Zeek module
│   ├── collect-evidence.sh       # Save Zeek evidence artifacts
│   ├── README.md                 # Zeek module guide
│   ├── logs/current/conn.log     # Zeek connection telemetry
│   └── evidence/                 # Saved Zeek evidence files
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
- **Password:** SecretPassword

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

### Part 3: OpenVAS/GVM

#### 1. Start GVM Stack

```bash
cd gvm
./setup-gvm.sh
./status-gvm.sh
```

#### 2. Access GSA

Open browser: **https://127.0.0.1:8443**

Login:
- **Username:** admin
- **Password:** GvmLab@2026!

#### 3. Run a Demonstration Scan

1. Add target `172.21.0.18`
2. Create task with **Full and fast**
3. Start scan and wait for **Done**
4. Review findings in **Reports**

### Part 4: Zeek Network Security Monitoring

#### 1. Start Zeek Module

```bash
cd zeek
./setup-zeek.sh
```

#### 2. Verify Zeek Output

```bash
./status-zeek.sh
cat logs/current/conn.log
```

Expected output:
- Zeek containers are running
- `conn.log` contains JSON records for DNS and HTTP traffic

#### 3. Collect Elastic Ingestion Proof

```bash
./collect-evidence.sh
cat evidence/elasticsearch-proof.json
```

Expected output:
- `zeek/evidence/elasticsearch-proof.json` shows hits in `zeek-*`
- Evidence file is ready for the Phase 1 submission package

### Combined Operations

#### Check Status of Core Platforms

```bash
# Elastic Stack
bash status.sh

# Wazuh
cd wazuh/single-node && docker-compose ps

# GVM
cd gvm && ./status-gvm.sh

# Zeek
cd zeek && ./status-zeek.sh
```

#### Stop Platform Stacks

```bash
# Stop Elastic Stack
bash stop.sh

# Stop Wazuh
cd wazuh/single-node && sudo docker-compose down

# Stop GVM
cd gvm && ./stop-gvm.sh

# Stop Zeek
cd zeek && ./stop-zeek.sh
```

#### Comprehensive Validation

```bash
# See VALIDATION_GUIDE.md for complete validation procedures
cat VALIDATION_GUIDE.md
```

The validation guide includes:
- ✅ Elastic Stack validation (6 steps)
- ✅ Wazuh validation (9 steps)  
- ✅ Zeek evidence workflow via `zeek/README.md`
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
curl -k -u admin:SecretPassword \
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

#### Integrate All Platforms
- Forward Wazuh alerts to Elasticsearch
- Ingest Zeek connection telemetry through Logstash
- Use OpenVAS findings for asset risk context
- Create unified dashboards in Kibana
- Correlate events across endpoint, network, and vulnerability telemetry
- Centralized alert management

#### Security Operations Workflow
1. **Elastic Stack**: Analytics, dashboards, correlation, and data lake
2. **Wazuh**: Endpoint detection and response (EDR)
3. **OpenVAS/GVM**: Vulnerability visibility and remediation prioritization
4. **Zeek**: Network-level connection telemetry and anomaly context

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
- **[VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)** - Comprehensive validation procedures for Elastic and Wazuh
- **[zeek/README.md](zeek/README.md)** - Zeek evidence workflow and screenshot checklist

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

### Multi-Platform SOC Deployment
- **Port Conflict:** Both use port 9200 (Elasticsearch & Wazuh Indexer)
  - **Solution:** Run one SIEM at a time, OR modify Wazuh ports in docker-compose.yml
- **Combined Resources:** 16GB RAM recommended for running Elastic, GVM, Wazuh, and Zeek together
- **Use Case:** Correlate endpoint, network, and vulnerability telemetry in one SOC lab

### Security Considerations
⚠️ **Warning:** These deployments use test credentials for lab/learning purposes:
- `elastic:SecurePassword123!`
- `admin:SecretPassword`
- `wazuh-wui:MyS3cr37P450r.*-`
- `admin:GvmLab@2026!`

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

Deploy a comprehensive multi-platform SOC laboratory environment capable of:

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

### OpenVAS/GVM
- Vulnerability assessment and exposure management
- CVE/CVSS-based remediation prioritization
- Scan task scheduling and reporting
- Lab-target validation against DVWA

### Zeek Network Monitoring
- Network connection visibility through `conn.log`
- HTTP and DNS flow visibility for SOC evidence
- Log shipping into Elasticsearch for correlation
- Assignment-ready status and ingestion proof generation

### Combined Capabilities
- Multi-layered threat detection
- Comprehensive security monitoring
- Integrated incident response workflow
- Unified security operations center (SOC) experience
- Cross-correlation between endpoint, network, and vulnerability data

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

### Zeek Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Sample PCAP      │────►│ Zeek Sensor      │────►│ Logstash / ES    │
│ Generator        │     │ conn.log output  │     │ zeek-* index     │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                             │
                                                   ┌─────────▼─────────┐
                                                   │ Kibana / Evidence │
                                                   │ search + JSON     │
                                                   └───────────────────┘
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

### OpenVAS/GVM ✅ (Operational)

- [x] **Infrastructure**: 18+ containers deployed and healthy
- [x] **Feeds**: Scan configs and vulnerability feeds synchronized
- [x] **Dashboard Access**: https://127.0.0.1:8443 accessible
- [x] **Lab Target**: DVWA deployed at 172.21.0.18 / 127.0.0.1:8085

### Zeek ✅ (Evidence Workflow Operational)

- [x] **Infrastructure**: Zeek module containers created and runnable
- [x] **Telemetry**: `zeek/logs/current/conn.log` populated with sample traffic
- [x] **Elastic Ingestion**: `zeek-*` index created with searchable documents
- [x] **Evidence Files**: Saved in `zeek/evidence/` for Phase 1 submission

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

---

## 🔍 OpenVAS/GVM Detailed Operations

### GVM Service Management

```bash
# Navigate to GVM directory
cd gvm

# Start GVM (includes all containers and feed initialization)
./setup-gvm.sh

# Check status of all containers
./status-gvm.sh

# View service logs
sudo docker compose -f compose.yaml logs -f [service-name]
# Examples: gvmd, gsad, nginx, ospd-openvas, openvas, pg-gvm

# Monitor feed synchronization
./sync-feeds.sh

# Gracefully stop all GVM services
./stop-gvm.sh

# Complete teardown (removes containers and volumes)
./cleanup-gvm.sh
```

### GVM Database Management

```bash
# Access PostgreSQL directly for advanced queries
sudo docker compose -f compose.yaml exec -T pg-gvm psql -U gvmd -d gvmd

# Inside psql:
# List all scan configurations
SELECT name, id FROM configs ORDER BY name;

# List all targets
SELECT name, hosts FROM targets;

# List all tasks
SELECT name, target, config FROM tasks;

# Check scan config count (should be 14+ after feed sync)
SELECT count(*) AS config_count FROM configs;

# Exit psql
\quit
```

### GVM User Management

```bash
# Change admin password
cd gvm
./reset-admin-password.sh

# Or directly:
sudo docker compose -f compose.yaml exec -T -u gvmd gvmd gvmd \
  --user=admin --new-password='YourNewPassword123!'
```

### GVM Vulnerability Scan Workflow

**1. Create Scan Target**
```bash
# Via API (example - manual creation preferred in UI)
# GSA → Intelligence → Targets → New Target
# Fill: Name, Host(s), Port List
```

**2. Create Scan Task**
```bash
# GSA → Vulnerability Management → Tasks → New Task
# Select: Name, Scan Config (e.g., "Full and fast"), Target
```

**3. Run Scan**
```bash
# GSA → Click "Start" on task
# Monitor Status column for: "Requested" → "Running" → "Done"
# Typical scan time: 5-30 minutes depending on scan config
```

**4. View Results**
```bash
# GSA → Click task name → Reports tab
# Filter by Severity (High, Critical recommended)
# Export as PDF/XML/CSV
```

### GVM API Access (Advanced)

```bash
# Get GSA API documentation
curl -k -I https://127.0.0.1:8443/api

# List available scans (requires authentication)
# Use GSA credentials in API calls
```

---

## 🛡️ Security Hardening Guide

### Elastic Stack Security Hardening

#### 1. Strong Password Policy

```bash
# Generate strong passwords (16+ chars, mixed case, numbers, symbols)
# Current passwords are test passwords - replace in production

# Update passwords via Kibana → Stack Management → Security
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_security/user/[username]/_password \
  -H 'Content-Type: application/json' \
  -d '{"password":"NewStrongPassword123!#$%"}'
```

#### 2. Enable Additional Authentication

```bash
# Edit docker-compose.yml and enable:
xpack.security.enabled: true              # Already enabled
xpack.security.enrollment.enabled: true
```

#### 3. Network Segmentation

```yaml
# docker-compose.yml - Restrict network access
services:
  es01:
    networks:
      siem-network:
        ipv4_address: 172.20.0.2
    
  # Only expose Kibana, not Elasticsearch directly
  # Access ES through Kibana proxy
```

#### 4. Role-Based Access Control (RBAC)

```bash
# Create read-only analyst role
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_security/role/analyst \
  -H 'Content-Type: application/json' \
  -d '{
    "indices": [
      {"names": ["logs-*", "security-*"], "privileges": ["read", "view_index_metadata"]}
    ],
    "applications": [
      {"application": "kibana-.kibana", "privileges": ["read"], "resources": ["*"]}
    ]
  }'
```

#### 5. Enable Audit Logging

```bash
# Edit elasticsearch.yml to log all access
xpack.security.audit.enabled: true
xpack.security.audit.logfile.enabled: true
xpack.security.audit.outputs: [logfile]
```

#### 6. Data Encryption at Rest

```bash
# Enable Elasticsearch native encryption
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true
```

### Wazuh Security Hardening

#### 1. Change Default Credentials

```bash
# Admin password (during docker-compose setup)
# API credentials (pre-configured with strong password)

# Change via API
TOKEN=$(curl -u wazuh-wui:MyS3cr37P450r.*- -k -X GET \
  "https://localhost:55000/security/user/authenticate?raw=true")

curl -k -X PUT "https://localhost:55000/security/users/admin" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"password":"NewStrongPassword123!#$%"}'
```

#### 2. Enable LDAP Integration (Advanced)

```bash
# Edit /var/ossec/etc/ossec.conf inside wazuh.manager
docker exec wazuh.manager vi /var/ossec/etc/ossec.conf

# Add LDAP configuration for enterprise auth
# Then restart manager
docker-compose restart wazuh.manager
```

#### 3. Configure TLS Certificate Validation

Already enabled with self-signed certificates. For production:
```bash
# Replace certificates in config/wazuh_indexer_ssl_certs/
# Use publicly signed certificates from trusted CA
```

#### 4. Enable Syslog Output for Compliance

```bash
# Edit /var/ossec/etc/ossec.conf
# Add syslog output for external SIEM or log aggregator
docker exec wazuh.manager vi /var/ossec/etc/ossec.conf

# Restart manager
docker-compose restart wazuh.manager
```

### OpenVAS/GVM Security Hardening

#### 1. Strong Admin Password

```bash
# Set during initial setup (./reset-admin-password.sh)
# Must be 16+ characters with mixed case, numbers, symbols

# Update existing password
cd gvm
./reset-admin-password.sh
```

#### 2. Restrict Network Access

```bash
# GVM listens on 8443 - restrict to trusted networks
# Edit docker-compose.yml and limit port exposure:

  nginx:
    ports:
      - "127.0.0.1:8443:443"  # Only localhost
      # Instead of: "8443:443"  which exposes to all interfaces
```

#### 3. Enable Scanner Authentication

```bash
# All scanners already require gvmd authentication
# Additional credentials for SSH/SMB scanning targets:
# GSA → Intelligence → Credentials
# Add credentials for scanning remote systems
```

#### 4. Isolate Vulnerable Targets

```bash
# DVWA and other targets should be isolated network
# Already configured on gvm-network:
# Targets cannot reach production systems

# When adding real targets:
# 1. Use VPN or dedicated network
# 2. Enable firewall rules
# 3. Log all scan activity
```

#### 5. Scan Activity Logging

```bash
# Monitor scan logs
sudo docker compose -f compose.yaml logs -f gvmd | grep -i scan

# Archive older scan results
# GSA → Vulnerability Management → Tasks → Archive old results
```

---

## 📚 Lab Exercises & Scenarios

### Lab Exercise 1: Detect SSH Brute Force Attack

**Objective:** Deploy Wazuh, simulate brute force, detect with Elastic + Wazuh

**Steps:**
1. Start Elastic Stack: `bash setup.sh`
2. Start Wazuh: `cd wazuh/single-node && sudo docker-compose up -d`
3. Deploy Wazuh agent: `./deploy-agents.sh`
4. Simulate brute force: `./simulate-threats.sh`
5. Verify detection:
   - **Wazuh Dashboard:** Security Events → Filter Rule ID: 100108 (Brute Force)
   - **Kibana:** Security → Alerts → Look for high-severity alerts
6. Examine the attack: Timestamp, source IP, failed attempts count, target

**Expected:** Elastic and Wazuh both detect and surface the simulated brute force activity

### Lab Exercise 2: Vulnerability Assessment with GVM

**Objective:** Scan DVWA for vulnerabilities, analyze CVSS scores, categorize findings

**Steps:**
1. Start GVM: `cd gvm && ./setup-gvm.sh`
2. Deploy DVWA: `./deploy-targets.sh`
3. Create scan task in GSA:
   - Target: Add target with IP `172.21.0.18`
   - Task: Configure with "Full and fast" scan config
4. Run scan: Monitor progress until "Done"
5. Analyze results:
   - List vulnerabilities by severity
   - Examine CVSS scores
   - Review remediation suggestions
6. Export report: PDF/XML for documentation

**Expected:** 20-50+ vulnerabilities found in DVWA, properly categorized

### Lab Exercise 3: Integrated Response Workflow

**Objective:** Combine detection (Elastic/Wazuh) with vulnerability assessment (GVM)

**Steps:**
1. Deploy all three systems running
2. Generate event: `bash simulate-events.sh` (Elastic)
3. Monitor in Wazuh for file integrity violations
4. Identify affected host
5. Launch GVM scan on that host to find exploitable vulns
6. Correlation: Link detection alert → Vulnerable component → CVSS score

**Result:** Complete attack chain from detection to vulnerability analysis

### Lab Exercise 4: Custom Rule Creation

**Objective:** Create new detection rule in Wazuh based on specific pattern

**Objective:** Create new detection rule in Wazuh based on specific log pattern

**Steps:**
1. Open `wazuh/single-node/local_rules.xml`
2. Add new rule (ID 100110+):
   ```xml
   <rule id="100110" level="5">
       <if_sid>1001</if_sid>
       <regex>^Custom DetectionPattern</regex>
       <description>Custom Rule - Lab Exercise</description>
       <group>custom_detection,</group>
   </rule>
   ```
3. Restart Wazuh manager: `docker-compose restart wazuh.manager`
4. Simulate pattern: Generate log matching rule
5. Verify detection in Dashboard

**Expected:** New rule triggers for matching events

### Lab Exercise 5: Incident Response Simulation

**Objective:** Complete incident response workflow across all platforms

**Scenario:** Unauthorized SSH access detected

**Steps:**
1. **Detection Stage:** Wazuh/Elastic alert on failed SSH attempts
2. **Investigation Stage:**
   - Wazuh: View agent logs, check failed login history
   - Kibana: Correlate network traffic with SSH events
   - Extract: Source IP, timestamp, attempts count
3. **Vulnerability Assessment:**
   - Run GVM scan on target system
   - Identify exploitable services
   - Document CVSS scores for exposed services
4. **Response Stage:**
   - Check Wazuh active response rules
   - Review firewall rules that would block attacker
   - Document remediation steps
5. **Reporting:**
   - Generate Wazuh report
   - Export Elasticsearch findings
   - Create summary document

**Deliverable:** Incident response report with timeline, findings, and recommendations

### Lab Exercise 6: Compliance Monitoring

**Objective:** Track compliance status across SIEM platforms

**Steps:**
1. **Wazuh Compliance:**
   - Dashboard → Compliance
   - View PCI-DSS, GDPR, HIPAA status
   - Identify non-compliant controls
   - Generate compliance report

2. **Elastic Compliance:**
   - Kibana → Security → Compliance
   - Review audit logs
   - Verify authentication controls
   - Check encryption status

3. **GVM Compliance:**
   - Scan for missing patches
   - Document vulnerable software
   - Link vulnerabilities to compliance requirements

**Deliverable:** Compliance assessment covering Elastic, Wazuh, OpenVAS/GVM, and Zeek

---

## 🚀 Advanced Configuration & Integration

### Integrate Wazuh Alerts to Elasticsearch

Forward Wazuh alerts to Elasticsearch for centralized analysis:

```bash
# In Wazuh manager config (wazuh.manager container)
# Edit: /var/ossec/etc/ossec.conf

# Add output section:
<integration>
    <name>custom-integration</name>
    <hook_url>https://elasticsearch:9200</hook_url>
    <alert_format>json</alert_format>
</integration>

# Restart manager
docker-compose restart wazuh.manager
```

### Setup GVM Feed Auto-Sync

Configure automatic feed updates (instead of manual):

```bash
# Create cron schedule inside gvmd container
sudo docker compose -f gvm/compose.yaml exec gvmd bash -c \
  'echo "0 2 * * * /usr/local/sbin/greenbone-feed-sync" | crontab -'

# Verify cron is set
sudo docker compose -f gvm/compose.yaml exec gvmd crontab -l
```

### Create Unified Dashboard

Combine data from all four platforms in a single Kibana dashboard:

```bash
# In Kibana, create new dashboard with:
# - Elastic Stack alerts (tiles)
# - Wazuh events (embedded via iframe or API)
# - GVM vulnerability counts (metrics)
# - Overall risk scoring
```

### Setup Email Alerts

Configure email notifications for critical events:

**Elastic Stack:**
```bash
# Kibana → Stack Management → Alerts and Actions
# Create action: Email
# Define recipients and triggers
```

**Wazuh:**
```bash
# Edit /var/ossec/etc/ossec.conf
# Add email notification configuration
docker exec wazuh.manager vi /var/ossec/etc/ossec.conf
docker-compose restart wazuh.manager
```

---

## 💾 Backup & Disaster Recovery

### Backup Elasticsearch Data

```bash
# Create snapshot repository
curl -k -X PUT -u elastic:SecurePassword123! \
  https://localhost:9200/_snapshot/backup \
  -H 'Content-Type: application/json' \
  -d '{
    "type": "fs",
    "settings": {"location": "/mnt/backups/elasticsearch"}
  }'

# Create snapshot
curl -k -X PUT -u elastic:SecurePassword123! \
  https://localhost:9200/_snapshot/backup/snapshot-$(date +%Y%m%d) \
  -H 'Content-Type: application/json' \
  -d '{"indices": "*"}'

# List snapshots
curl -k -u elastic:SecurePassword123! \
  https://localhost:9200/_snapshot/backup/_all?pretty
```

### Backup Wazuh Configuration

```bash
# Backup Wazuh configurations
tar -czf wazuh-backup-$(date +%Y%m%d).tar.gz \
  wazuh/single-node/config/ \
  wazuh/single-node/local_rules.xml

# Backup to external drive
cp wazuh-backup-*.tar.gz /mnt/backup/
```

### Backup GVM Database

```bash
# Export GVM database
cd gvm
sudo docker compose -f compose.yaml exec -T pg-gvm pg_dump \
  -U gvmd gvmd > gvm-backup-$(date +%Y%m%d).sql

# Backup to external drive
cp gvm-backup-*.sql /mnt/backup/
```

### Restore Procedures

```bash
# Restore Elasticsearch from snapshot
curl -k -X POST -u elastic:SecurePassword123! \
  https://localhost:9200/_snapshot/backup/snapshot-20260317/_restore

# Restore GVM database
cd gvm
sudo docker compose -f compose.yaml exec -T pg-gvm psql \
  -U gvmd gvmd < gvm-backup-20260317.sql

# Restore Wazuh config
tar -xzf wazuh-backup-20260317.tar.gz -C wazuh/single-node/
docker-compose restart wazuh.manager
```

---

## 📊 Performance Tuning

### Elasticsearch Performance

```bash
# Increase heap size for larger datasets
# Edit .env:
ES_JAVA_OPTS=-Xms2g -Xmx2g  # Increase from default

# Increase thread pool
# Edit config/elasticsearch/es01.yml:
thread_pool:
  search:
    queue_size: 1000
```

### Wazuh Performance

```bash
# Increase manager worker threads
# Inside wazuh.manager container:
docker exec wazuh.manager sed -i \
  's/<workers>4/<workers>8/' /var/ossec/etc/ossec.conf
docker-compose restart wazuh.manager
```

### GVM Performance

```bash
# Increase scanner concurrency
# In GSA: Administration → Settings → OpenVAS Scanner
# Increase max concurrent tasks and NVTs

# Or via gvmd config:
sudo docker compose -f compose.yaml exec -T -u gvmd gvmd \
  gvmd --help | grep -i "concur\|worker"
```

---

## 📖 Comprehensive Glossary

| Term | Definition | Platform |
|------|-----------|----------|
| **SIEM** | Security Information and Event Management - Centralized security monitoring | Elastic, Wazuh |
| **EDR** | Endpoint Detection and Response - Endpoint threat detection | Wazuh |
| **ILM** | Index Lifecycle Management - Data retention and archival | Elastic |
| **NVT** | Network Vulnerability Test - Individual vulnerability scanner test | GVM |
| **SCAP** | Security Content Automation Protocol - Standard vulnerability data | GVM |
| **CVSS** | Common Vulnerability Scoring System - Severity rating (0-10) | GVM |
| **CVE** | Common Vulnerabilities and Exposures - Unique vulnerability identifier | GVM, Wazuh |
| **CPE** | Common Platform Enumeration - System identification standard | GVM |
| **GSA** | Greenbone Security Assistant - GVM web interface | GVM |
| **MITRE ATT&CK** | Threat actor tactics, techniques framework | Wazuh |
| **FIM** | File Integrity Monitoring - Track unauthorized file changes | Wazuh |
| **RBAC** | Role-Based Access Control - Permission management by role | Elastic, Wazuh, GVM |
| **TLS/SSL** | Encryption protocol for secure communications | All |
| **JWT** | JSON Web Token - API authentication mechanism | Wazuh |
| **Logstash** | Log processing pipeline | Elastic |
| **Fleet** | Agent management system | Elastic |
| **Kibana** | Elasticsearch visualization and analytics UI | Elastic |
| **Indexer** | Wazuh search backend (based on OpenSearch) | Wazuh |
| **gvmd** | Greenbone Vulnerability Manager daemon | GVM |
| **ospd-openvas** | OpenVAS Scanner Protocol daemon | GVM |
| **Zeek** | Network Security Monitoring platform for connection telemetry | Zeek |
| **conn.log** | Zeek connection log containing IPs, ports, services, and session metadata | Zeek |

---

## 🖥️ Complete Command Reference

### Elastic Stack Commands

```bash
# Basic Operations
bash setup.sh                     # Deploy all Elastic Stack services
bash stop.sh                      # Stop all services
bash status.sh                    # Check service status
bash simulate-events.sh           # Generate test security events

# Container Management
sudo docker-compose logs -f                 # View all logs
sudo docker-compose logs -f [service]       # View specific service logs
sudo docker-compose ps                      # List running containers
sudo docker-compose restart [service]       # Restart service
sudo docker-compose down                    # Stop and remove containers
sudo docker-compose down -v                 # Stop and remove all
```

### Wazuh Commands

```bash
cd wazuh/single-node

# Basic Operations
sudo docker-compose up -d                   # Start Wazuh
sudo docker-compose down                    # Stop Wazuh
sudo docker-compose ps                      # List containers

# Container Logs
docker logs wazuh.manager                   # View manager logs
docker logs wazuh.indexer                   # View indexer logs
docker logs wazuh.dashboard                 # View dashboard logs
```

### GVM/OpenVAS Commands

```bash
cd gvm

# Basic Operations
./setup-gvm.sh                              # Start GVM and initialize
./status-gvm.sh                             # Check container status
./stop-gvm.sh                               # Gracefully stop all
./cleanup-gvm.sh                            # Complete teardown
./reset-admin-password.sh                   # Set GSA admin password
./deploy-targets.sh                         # Deploy DVWA target
./sync-feeds.sh                             # Monitor feed sync
```

### Zeek Commands

```bash
cd zeek

# Basic Operations
./setup-zeek.sh                             # Start Zeek module and generate telemetry
./status-zeek.sh                            # Check containers and show conn.log sample
./collect-evidence.sh                       # Save Zeek evidence artifacts
./stop-zeek.sh                              # Stop Zeek module
```

### Quick Access
- **[VALIDATION_GUIDE.md](VALIDATION_GUIDE.md)** - ⭐ Step-by-step validation for Elastic and Wazuh
- **[zeek/README.md](zeek/README.md)** - Zeek setup, evidence collection, and screenshot checklist

### Elastic Stack
- **[README.md](README.md)** - This file (project overview)
- Setup scripts in root directory

### Zeek NSM
- **[zeek/README.md](zeek/README.md)** - Zeek evidence workflow
- `zeek/evidence/` - Saved Phase 1 proof files
- `zeek/logs/current/conn.log` - Generated Zeek connection telemetry

### Wazuh SIEM
- **[WAZUH_DEPLOYMENT_GUIDE.md](wazuh/single-node/WAZUH_DEPLOYMENT_GUIDE.md)** - Complete setup instructions
- **[INVESTIGATION_GUIDE.md](wazuh/single-node/INVESTIGATION_GUIDE.md)** - 20+ KQL queries and workflows
- **[QUICK_REFERENCE.md](wazuh/single-node/QUICK_REFERENCE.md)** - Commands cheat sheet
- **[COMPLETE_TASK_CHECKLIST.md](wazuh/single-node/COMPLETE_TASK_CHECKLIST.md)** - Detailed task tracking
- **[PROJECT_COMPLETION_SUMMARY.md](wazuh/single-node/PROJECT_COMPLETION_SUMMARY.md)** - Full project overview

---

**🎉 Your integrated SOC laboratory is ready!**

**Next steps:**
1. Start Elastic Stack: `bash setup.sh`
2. Start Wazuh: `cd wazuh/single-node && sudo docker-compose up -d`
3. Start GVM: `cd gvm && ./setup-gvm.sh`
4. Start Zeek: `cd zeek && ./setup-zeek.sh`
5. Follow validation procedures: See `VALIDATION_GUIDE.md` and `zeek/README.md`

**For deployment validation:** See [VALIDATION_GUIDE.md](VALIDATION_GUIDE.md) for Elastic and Wazuh, and see [zeek/README.md](zeek/README.md) for Zeek evidence collection.

---

*Lab Environment - Designed for security training, testing, and evaluation*

