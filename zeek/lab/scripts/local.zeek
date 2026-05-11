# Local Zeek scripts loader
# Load standard analyzers and custom detection scripts
@load base/protocols/http
@load base/protocols/dns
@load base/protocols/ssl

# Load custom detection scripts
@load /opt/zeek/scripts/detect-suspicious.zeek
@load /opt/zeek/scripts/detect-iocs.zeek
