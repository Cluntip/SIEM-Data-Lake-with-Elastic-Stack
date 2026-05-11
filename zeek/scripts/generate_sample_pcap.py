from pathlib import Path

from scapy.all import Ether, IP, TCP, UDP, DNS, DNSQR, DNSRR, Raw, wrpcap


output_dir = Path("/output")
output_dir.mkdir(parents=True, exist_ok=True)
output_path = output_dir / "sample_traffic.pcap"

client = "10.10.10.10"
web_server = "10.10.10.20"
dns_server = "8.8.8.8"

packets = [
    Ether()/IP(src=client, dst=web_server)/TCP(sport=51514, dport=80, flags="S", seq=1000),
    Ether()/IP(src=web_server, dst=client)/TCP(sport=80, dport=51514, flags="SA", seq=2000, ack=1001),
    Ether()/IP(src=client, dst=web_server)/TCP(sport=51514, dport=80, flags="A", seq=1001, ack=2001),
    Ether()/IP(src=client, dst=web_server)/TCP(sport=51514, dport=80, flags="PA", seq=1001, ack=2001)/Raw(load=b"GET / HTTP/1.1\r\nHost: demo.local\r\n\r\n"),
    Ether()/IP(src=web_server, dst=client)/TCP(sport=80, dport=51514, flags="PA", seq=2001, ack=1038)/Raw(load=b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"),
    Ether()/IP(src=client, dst=web_server)/TCP(sport=51514, dport=80, flags="FA", seq=1038, ack=2041),
    Ether()/IP(src=web_server, dst=client)/TCP(sport=80, dport=51514, flags="FA", seq=2041, ack=1039),
    Ether()/IP(src=client, dst=web_server)/TCP(sport=51514, dport=80, flags="A", seq=1039, ack=2042),
    Ether()/IP(src=client, dst=dns_server)/UDP(sport=53000, dport=53)/DNS(rd=1, qd=DNSQR(qname="example.org")),
    Ether()/IP(src=dns_server, dst=client)/UDP(sport=53, dport=53000)/DNS(id=1, qr=1, aa=1, qd=DNSQR(qname="example.org"), an=DNSRR(rrname="example.org", ttl=60, rdata="93.184.216.34")),
]

wrpcap(str(output_path), packets)
print(f"Generated sample PCAP at {output_path}")