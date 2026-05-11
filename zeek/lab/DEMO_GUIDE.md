# Zeek Lab Demo Guide

## What this lab proves

- Zeek runs in PCAP mode and LIVE mode.
- Zeek produces `conn.log`, `http.log`, `dns.log`, and `notice.log`.
- Custom detections trigger on suspicious IPs and suspicious downloads.

## Build

```bash
cd "/home/amrhamada/Documents/SIEM & Data Lake with Elastic Stack/zeek/lab"
sudo docker compose build
```

## Generate a fresh test PCAP

```bash
python3 generate-pcap.py pcaps/synthetic-http.pcap
```

This PCAP includes:
- DNS query and response for `malware.example.com`
- HTTP GET for `/download/malware.exe`
- A connection to `192.168.1.200` to trigger the malicious IP notice

## Run Zeek in PCAP mode

```bash
sudo docker compose run --rm zeek-lab pcap /pcap/synthetic-http.pcap
```

Expected output in `logs/`:
- `conn.log`
- `http.log`
- `dns.log`
- `notice.log`

## Verify the results

```bash
sed -n '1,80p' logs/conn.log
sed -n '1,80p' logs/http.log
sed -n '1,80p' logs/dns.log
sed -n '1,120p' logs/notice.log
```

Expected notices:
- `Detect::Suspicious::Suspicious_IP_Connection`
- `Detect::IOCs::Suspicious_Download`

## Run Zeek in LIVE mode

Pick the interface that carries real traffic on the host, then run:

```bash
sudo docker compose run --rm zeek-lab live eth0
```

If your host uses a different interface name, replace `eth0` with that interface.

## Collect evidence

```bash
./collect-evidence-zeek-lab.sh
```

## Stop the lab

```bash
./stop-zeek-lab.sh
```
