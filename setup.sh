#!/bin/bash
# Start SIEM & Data Lake - Complete Deployment

set -e

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges. Restarting with sudo..."
    sudo bash "$0" "$@"
    exit $?
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "🚀 SIEM & Data Lake Deployment"
echo "========================================="
echo ""

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi
source .env

# Function to wait for service
wait_for_service() {
    local service=$1
    local url=$2
    local auth=$3
    local max_retries=30
    local count=0
    
    echo "Waiting for $service..."
    until curl -s -k -f $auth "$url" > /dev/null 2>&1; do
        count=$((count+1))
        if [ $count -gt $max_retries ]; then
            echo "❌ $service failed to start"
            return 1
        fi
        echo -n "."
        sleep 10
    done
    echo " ✅"
}

# Step 1: Clean up
echo "🧹 Cleaning up existing containers..."
docker-compose down -v 2>/dev/null || true
docker rm -f es01 es02 es03 kibana logstash fleet-server customer-service 2>/dev/null || true

# Step 2: Certificates
echo ""
echo "🔐 Setting up TLS certificates..."
if [ ! -f certs/es01/es01.crt ]; then
    rm -rf certs && mkdir -p certs
    
    # Create instances.yml for certutil
    cat > certs/instances.yml <<EOF
instances:
  - name: es01
    dns:
      - es01
      - localhost
    ip:
      - 127.0.0.1
  - name: es02
    dns:
      - es02
      - localhost
    ip:
      - 127.0.0.1
  - name: es03
    dns:
      - es03
      - localhost
    ip:
      - 127.0.0.1
EOF
    
    # Generate certificates using instances.yml
    docker run --rm -u $(id -u):$(id -g) -v "$(pwd)/certs:/certs" -w /certs \
      docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION} \
      /bin/sh -c '
        # Generate CA
        elasticsearch-certutil ca --silent --pem --out /tmp/ca.zip
        unzip -q /tmp/ca.zip -d /certs
        
        # Generate node certificates
        elasticsearch-certutil cert --silent --pem \
          --in /certs/instances.yml \
          --out /tmp/certs.zip \
          --ca-cert /certs/ca/ca.crt \
          --ca-key /certs/ca/ca.key
        unzip -q /tmp/certs.zip -d /certs
      '
    
    # Fix permissions - elasticsearch containers run as uid 1000
    chmod -R 755 certs/
    chmod 644 certs/ca/ca.crt certs/es*/es*.crt
    chmod 644 certs/ca/ca.key certs/es*/es*.key
    
    echo "✅ Certificates generated"
else
    echo "✅ Certificates already exist"
fi

# Step 3: Start Elasticsearch cluster
echo ""
echo "📊 Starting Elasticsearch cluster (3 nodes)..."
docker-compose up -d es01 es02 es03
sleep 20
wait_for_service "Elasticsearch" "https://localhost:${ES_PORT}/_cluster/health" "-u elastic:${ELASTIC_PASSWORD}"

# Step 4: Configure passwords and ILM
echo ""
echo "⚙️  Configuring system..."
curl -k -s -X POST -u "elastic:${ELASTIC_PASSWORD}" \
  "https://localhost:${ES_PORT}/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}" > /dev/null 2>&1
echo "✅ Passwords configured"

# Create ILM policies
echo "⚙️  Setting up ILM policies..."
curl -k -s -X PUT -u "elastic:${ELASTIC_PASSWORD}" \
  "https://localhost:${ES_PORT}/_ilm/policy/logs-policy" \
  -H "Content-Type: application/json" \
  -d '{"policy":{"phases":{"hot":{"actions":{"rollover":{"max_primary_shard_size":"50gb","max_age":"1d"}}},"warm":{"min_age":"7d","actions":{"shrink":{"number_of_shards":1},"forcemerge":{"max_num_segments":1}}},"cold":{"min_age":"30d","actions":{"freeze":{}}},"delete":{"min_age":"90d","actions":{"delete":{}}}}}}' > /dev/null 2>&1

curl -k -s -X PUT -u "elastic:${ELASTIC_PASSWORD}" \
  "https://localhost:${ES_PORT}/_index_template/logs-template" \
  -H "Content-Type: application/json" \
  -d '{"index_patterns":["logs-*"],"template":{"settings":{"number_of_shards":3,"number_of_replicas":2,"index.lifecycle.name":"logs-policy"}}}' > /dev/null 2>&1
echo "✅ ILM policies created"

# Step 5: Start remaining services
echo ""
echo "🌐 Starting Kibana, Fleet, Logstash, and Customer Service..."
docker-compose up -d kibana fleet-server logstash customer-service

echo "Waiting for services to be ready (this may take 2-3 minutes)..."
sleep 60

echo ""
echo "========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "========================================="
echo ""
echo "📍 Access Points:"
echo "   Kibana:         http://localhost:${KB_PORT}"
echo "   Elasticsearch:  https://localhost:${ES_PORT}"
echo "   Customer API:   http://localhost:8081"
echo ""
echo "🔑 Credentials:"
echo "   Username: elastic"
echo "   Password: ${ELASTIC_PASSWORD}"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost:${KB_PORT} and login"
echo "   2. Generate test events: bash simulate-events.sh"
echo "   3. View cluster status: bash status.sh"
echo "   4. Stop all services: bash stop.sh"
echo ""
