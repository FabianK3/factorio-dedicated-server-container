FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends xz-utils && \
	rm -rf /var/lib/apt/lists/*

COPY build/factorio-headless_linux.tar.xz /tmp/factorio.tar.xz
RUN mkdir -p /opt && tar -xJf /tmp/factorio.tar.xz -C /opt && rm /tmp/factorio.tar.xz

COPY build/server-settings.json build/map-settings.json build/map-gen-settings.json /opt/factorio/default-config/
COPY src/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN useradd --uid 1000 --user-group --no-create-home factorio && \
	mkdir -p /opt/factorio/config /opt/factorio/mods /opt/factorio/saves && \
	chown -R factorio:factorio /opt/factorio

USER factorio
WORKDIR /opt/factorio

# Used in save game creation / load
ENV SAVEGAME_NAME=server
# Used for whitelist startup setting
ENV USE_WHITELIST=false
# Used for RCON password - RCON won't be set unless the env var is overwritten
ENV RCON_PW=""

# Game
EXPOSE 34197/udp
# RCON
EXPOSE 27015/tcp

VOLUME ["/opt/factorio/config", "/opt/factorio/mods", "/opt/factorio/saves"]
ENTRYPOINT ["/bin/sh", "/usr/local/bin/entrypoint.sh"]