FROM zeek/zeek:latest

LABEL maintainer="amrhamada"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/ /opt/zeek/scripts/
RUN chmod +x /usr/local/bin/entrypoint.sh || true

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
