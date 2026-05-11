#!/usr/bin/env bash
set -euo pipefail

# Entrypoint: choose PCAP mode or LIVE capture mode
# Usage:
#  docker run --rm -v /path/to/pcaps:/pcap -v /path/to/logs:/zeek/logs zeek-lab pcap /pcap/sample.pcap
#  docker run --rm --net=host -v /path/to/logs:/zeek/logs zeek-lab live eth0

MODE=${1:-}

if [[ "$MODE" == "pcap" ]]; then
  PCAP=${2:-/pcap/sample.pcap}
  echo "Running Zeek in PCAP mode on $PCAP"
  mkdir -p /zeek/logs
  cd /zeek/logs
  zeek -C -r "$PCAP" /opt/zeek/scripts/local.zeek
  echo "PCAP analysis complete, logs in /zeek/logs"
  exit 0
fi

if [[ "$MODE" == "live" ]]; then
  IFACE=${2:-eth0}
  echo "Running Zeek in LIVE mode on interface $IFACE"
  mkdir -p /zeek/logs
  cd /zeek/logs
  zeek -i "$IFACE" /opt/zeek/scripts/local.zeek
  exit 0
fi

echo "Usage: $0 pcap /path/to/file.pcap  OR  $0 live <interface>"
exit 2
