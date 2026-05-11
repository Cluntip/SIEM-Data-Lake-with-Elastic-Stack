FROM zeek/zeek:latest

WORKDIR /zeek/work

COPY scripts/run-zeek.sh /usr/local/bin/run-zeek.sh
RUN chmod +x /usr/local/bin/run-zeek.sh

ENTRYPOINT ["/usr/local/bin/run-zeek.sh"]