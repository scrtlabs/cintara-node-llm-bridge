FROM ubuntu:22.04
RUN apt-get update && apt-get install -y wget ca-certificates curl jq bash git sudo && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash cintara && echo "cintara ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV CINTARA_HOME=/data/.tmp-cintarad
USER root
RUN wget -q https://github.com/Cintaraio/cintara-testnet-script/releases/download/ubuntu22.04/cintarad -O /usr/local/bin/cintarad \
 && chmod 0755 /usr/local/bin/cintarad
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown cintara:cintara /usr/local/bin/entrypoint.sh && mkdir -p /data && chown cintara:cintara /data
USER cintara
EXPOSE 26656 26657
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]