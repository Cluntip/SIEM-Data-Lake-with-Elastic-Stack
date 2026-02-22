#!/bin/bash
# Check status of all services

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges. Restarting with sudo..."
    sudo bash "$0" "$@"
    exit $?
fi

cd "$(dirname "${BASH_SOURCE[0]}")"
source .env

echo "========================================="
echo "📊 SIEM Service Status"
echo "========================================="
echo ""

# Docker containers
echo "🐳 Docker Containers:"
docker-compose ps
echo ""

# Elasticsearch cluster
echo "🔍 Elasticsearch Cluster:"
CLUSTER_HEALTH=$(curl -s -k -u "elastic:${ELASTIC_PASSWORD}" "https://localhost:${ES_PORT}/_cluster/health" 2>/dev/null)
if [ $? -eq 0 ]; then
    STATUS=$(echo $CLUSTER_HEALTH | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    NODES=$(echo $CLUSTER_HEALTH | grep -o '"number_of_nodes":[0-9]*' | cut -d':' -f2)
    echo "   Status: $STATUS"
    echo "   Nodes: $NODES/3"
else
    echo "   ❌ Not accessible"
fi
echo ""

# Kibana
echo "🌐 Kibana:"
if curl -s "http://localhost:${KB_PORT}/api/status" > /dev/null 2>&1; then
    echo "   ✅ Accessible at http://localhost:${KB_PORT}"
else
    echo "   ❌ Not accessible"
fi
echo ""

# Customer Service
echo "🚀 Customer Service:"
if curl -s "http://localhost:8081/health" > /dev/null 2>&1; then
    echo "   ✅ Running at http://localhost:8081"
else
    echo "   ❌ Not accessible"
fi
echo ""

echo "Use 'sudo docker-compose logs [service]' to view logs"
echo ""
