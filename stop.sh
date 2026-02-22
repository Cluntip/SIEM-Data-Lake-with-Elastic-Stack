#!/bin/bash
# Stop all SIEM services

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges. Restarting with sudo..."
    sudo bash "$0" "$@"
    exit $?
fi

echo "🛑 Stopping SIEM & Data Lake..."

cd "$(dirname "${BASH_SOURCE[0]}")"

docker-compose down

echo ""
echo "✅ All services stopped"
echo ""
echo "To remove all data: bash stop.sh --clean"
echo "To restart: bash setup.sh"
echo ""

# Handle clean flag
if [ "$1" = "--clean" ]; then
    echo "Removing all data volumes..."
    docker-compose down -v
    echo "✅ All data removed"
fi
