#!/bin/sh
set -eu

while [ ! -s /zeek/logs/current/conn.log ]; do
  sleep 2
done

until nc -z host.docker.internal 5044; do
  sleep 2
done

cat /zeek/logs/current/conn.log | nc host.docker.internal 5044

echo "Zeek logs forwarded to Logstash on host.docker.internal:5044"
tail -f /dev/null