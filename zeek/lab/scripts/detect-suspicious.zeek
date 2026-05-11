# detect-suspicious.zeek
# Simple detection: known malicious IPs and excessive connection threshold.

module Detect::Suspicious;

export {
    redef enum Notice::Type += { Suspicious_IP_Connection, Excessive_Connections };
}



@load base/frameworks/notice

global malicious_ips: set[addr] = { 1.2.3.4, 127.0.0.1, 192.168.1.200 }; # include test targets; replace with real IOCs in production
global conn_count: table[addr] of count = table() &default=0;
global conn_threshold = 100; # adjustable

event connection_established(c: connection)
{
    local src = c$id$orig_h;
    conn_count[src] += 1;
    if ( c$id$resp_h in malicious_ips || c$id$orig_h in malicious_ips ) {
        NOTICE([$note=Suspicious_IP_Connection, $msg="Connection to known malicious IP", $conn=c]);
    }
    if ( conn_count[src] > conn_threshold ) {
        NOTICE([$note=Excessive_Connections, $msg=fmt("Host %s exceeded connection threshold", src), $conn=c]);
    }
}
