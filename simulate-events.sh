#!/bin/bash
# Simulate security events for SIEM testing

cd "$(dirname "${BASH_SOURCE[0]}")"

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi
source .env

ES_URL="https://localhost:${ES_PORT}"
ES_USER="elastic"
ES_PASS="${ELASTIC_PASSWORD}"

echo "🚨 Simulating security events..."
echo ""

# Function to create event
create_event() {
    curl -k -s -X POST -u "${ES_USER}:${ES_PASS}" \
      "${ES_URL}/security-events/_doc" \
      -H "Content-Type: application/json" \
      -d "$1" > /dev/null 2>&1
}

# 1. SSH Brute Force (10 attempts)
echo -n "1. SSH brute force attempts (10)... "
for i in {1..10}; do
    create_event "{\"@timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"event\":{\"type\":\"authentication\",\"action\":\"ssh_login\",\"category\":\"authentication\",\"outcome\":\"failure\",\"severity\":3},\"user\":{\"name\":\"admin\"},\"source\":{\"ip\":\"192.168.1.100\",\"port\":$((50000+i))},\"destination\":{\"ip\":\"10.0.0.5\",\"port\":22},\"message\":\"Failed SSH login attempt\"}"
done
echo "✅"

# 2. Failed Logins (15 attempts)
echo -n "2. Failed login attempts (15)... "
for i in {1..15}; do
    create_event "{\"@timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"event\":{\"type\":\"authentication\",\"action\":\"user_login\",\"category\":\"authentication\",\"outcome\":\"failure\",\"severity\":2},\"user\":{\"name\":\"user$i\"},\"source\":{\"ip\":\"203.0.113.50\",\"port\":$((60000+i))},\"message\":\"Failed login attempt\"}"
done
echo "✅"

# 3. Suspicious Connections (3 connections)
echo -n "3. Suspicious network connections (3)... "
for port in 4444 5555 6666; do
    create_event "{\"@timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"event\":{\"type\":\"connection\",\"action\":\"suspicious_connection\",\"category\":\"network\",\"outcome\":\"success\",\"severity\":4},\"source\":{\"ip\":\"10.0.0.10\",\"port\":52341},\"destination\":{\"ip\":\"198.51.100.25\",\"port\":$port},\"message\":\"Suspicious outbound connection\"}"
done
echo "✅"

# 4. Data Exfiltration (50 events for threshold)
echo -n "4. Data exfiltration events (50)... "
for i in {1..50}; do
    create_event "{\"@timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"event\":{\"type\":\"connection\",\"action\":\"network_flow\",\"category\":\"network\",\"outcome\":\"success\",\"severity\":2},\"source\":{\"ip\":\"10.0.0.15\",\"port\":$((40000+i))},\"destination\":{\"ip\":\"203.0.113.100\",\"port\":443},\"network\":{\"direction\":\"outbound\",\"bytes\":$((1000000+RANDOM))},\"message\":\"Large outbound transfer\"}"
done
echo "✅"

# 5. Webshell Activity (3 events)
echo -n "5. Webshell activity (3)... "
for cmd in "cmd" "exec" "shell"; do
    create_event "{\"@timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",\"event\":{\"type\":\"access\",\"action\":\"web_request\",\"category\":\"web\",\"outcome\":\"success\",\"severity\":5},\"source\":{\"ip\":\"198.51.100.50\",\"port\":45123},\"destination\":{\"ip\":\"10.0.0.20\",\"port\":80},\"url\":{\"path\":\"/uploads/shell.php\",\"query\":\"${cmd}=whoami\"},\"message\":\"Potential webshell execution\"}"
done
echo "✅"

echo ""
echo "✅ Generated events:"
echo "   • 10 SSH brute force attempts"
echo "   • 15 failed login attempts"  
echo "   • 3 suspicious connections"
echo "   • 50 data exfiltration events"
echo "   • 3 webshell activities"
echo ""
echo "View in Kibana: http://localhost:${KB_PORT}/app/security/alerts"
echo ""
