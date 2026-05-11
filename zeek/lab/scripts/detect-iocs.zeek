# detect-iocs.zeek
# IOC rules: detect suspicious SSL versions and suspicious HTTP downloads

module Detect::IOCs;

export {
    redef enum Notice::Type += { Suspicious_SSL_Version, Suspicious_Download };
}

@load base/frameworks/notice
@load base/protocols/ssl
@load base/protocols/http

# Simple IOC: flag older TLS versions as suspicious
event ssl_established(c: connection)
{
    if ( c?$ssl ) {
        local ssl_version = c$ssl$version;
        if ( ssl_version == "SSLv3" || ssl_version == "unknown" ) {
            NOTICE([$note=Suspicious_SSL_Version, $msg=fmt("Suspicious SSL version detected: %s", ssl_version), $conn=c]);
        }
    }
}

# Flag suspicious HTTP requests with executable/archive extensions
event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string)
{
    if ( /\.(exe|dll|zip|rar|scr|msi)$/ in original_URI || /malware|trojan|backdoor/i in original_URI ) {
        NOTICE([$note=Suspicious_Download, $msg=fmt("Suspicious download detected: %s", original_URI), $conn=c]);
    }
}
