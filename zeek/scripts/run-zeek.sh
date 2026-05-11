#!/bin/sh
set -eu

mkdir -p /zeek/logs/current

while [ ! -s /zeek/pcap/sample_traffic.pcap ]; do
  sleep 2
done

rm -f /zeek/logs/current/conn.log /zeek/logs/current/dns.log /zeek/logs/current/http.log

cd /zeek/logs/current
zeek -C -r /zeek/pcap/sample_traffic.pcap LogAscii::use_json=T local

touch /zeek/logs/current/conn.log

echo "Zeek finished processing sample traffic. Keeping container alive for evidence collection."
tail -f /dev/null