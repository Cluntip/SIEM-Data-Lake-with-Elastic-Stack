#!/usr/bin/env python3
"""
Generate a synthetic Ethernet PCAP with HTTP traffic for Zeek analysis.
Includes localhost connections to trigger detection scripts.
"""

from scapy.all import *
import sys

# Create packets with Ethernet frames
packets = []

# DNS query/response so Zeek generates dns.log
eth_dns = Ether(dst="00:00:00:00:00:05", src="00:00:00:00:00:06")
dns_query = eth_dns / IP(src="192.168.1.100", dst="8.8.8.8") / UDP(sport=44444, dport=53) / DNS(rd=1, qd=DNSQR(qname="malware.example.com"))
dns_response = eth_dns / IP(src="8.8.8.8", dst="192.168.1.100") / UDP(sport=53, dport=44444) / DNS(id=dns_query[DNS].id, qr=1, aa=1, rd=1, ra=1, qd=DNSQR(qname="malware.example.com"), an=DNSRR(rrname="malware.example.com", type="A", rdata="93.184.216.34"))
packets.append(dns_query)
packets.append(dns_response)

# Synthetic HTTP traffic: local connection to 127.0.0.1:8080
# Ethernet frame
eth = Ether(dst="00:00:00:00:00:01", src="00:00:00:00:00:02")
ip_src = IP(src="192.168.1.100", dst="192.168.1.200")
ip_dst = IP(src="192.168.1.200", dst="192.168.1.100")

# TCP SYN from client
tcp_syn = TCP(sport=54321, dport=80, flags="S", seq=1000)
pkt1 = eth/ip_src/tcp_syn
packets.append(pkt1)

# TCP SYN-ACK from server
tcp_synack = TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001)
pkt2 = eth/ip_dst/tcp_synack
packets.append(pkt2)

# TCP ACK from client
tcp_ack = TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001)
pkt3 = eth/ip_src/tcp_ack
packets.append(pkt3)

# HTTP GET request
http_request = TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001) / Raw(load=b"GET /download/malware.exe HTTP/1.1\r\nHost: example.com\r\n\r\n")
pkt4 = eth/ip_src/http_request
packets.append(pkt4)

# TCP ACK from server
tcp_ack2 = TCP(sport=80, dport=54321, flags="A", seq=2001, ack=1078)
pkt5 = eth/ip_dst/tcp_ack2
packets.append(pkt5)

# HTTP Response with .exe file
http_response = TCP(sport=80, dport=54321, flags="A", seq=2001, ack=1078) / Raw(load=b"HTTP/1.1 200 OK\r\nContent-Length: 1024\r\nContent-Disposition: attachment; filename=malware.exe\r\n\r\n")
pkt6 = eth/ip_dst/http_response
packets.append(pkt6)

# FIN from client
tcp_fin = TCP(sport=54321, dport=80, flags="F", seq=1078, ack=2001)
pkt7 = eth/ip_src/tcp_fin
packets.append(pkt7)

# Create another connection with localhost (127.0.0.1) to trigger detection
eth2 = Ether(dst="00:00:00:00:00:03", src="00:00:00:00:00:04")
ip_local_src = IP(src="127.0.0.1", dst="127.0.0.1")
tcp_local = TCP(sport=55555, dport=443, flags="S", seq=3000)
pkt8 = eth2/ip_local_src/tcp_local
packets.append(pkt8)

# Write to PCAP
output_file = sys.argv[1] if len(sys.argv) > 1 else "synthetic.pcap"
wrpcap(output_file, packets)
print(f"PCAP written to {output_file}")
