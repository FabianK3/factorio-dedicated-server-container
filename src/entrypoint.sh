#!/bin/sh
set -eu

for file in ./default-config/*.json; do
	if [ ! -e "./config/${file##*/}" ]; then
		cp "$file" ./config/
	fi
done

save="./saves/${name}.zip"
if [ ! -f "$save" ]; then
	./bin/x64/factorio --create "$save" \
		--map-gen-settings ./config/map-gen-settings.json \
		--map-settings ./config/map-settings.json
fi

if [ ! -f ./config/server-adminlist.json ]; then
	printf '[]\n' > ./config/server-adminlist.json
fi

set -- --start-server "$save" \
	--server-settings ./config/server-settings.json \
	--server-adminlist ./config/server-adminlist.json
if [ "$USE_WHITELIST" = "true" ]; then
	if [ ! -f ./config/server-whitelist.json ]; then
		printf '[]\n' > ./config/server-whitelist.json
	fi
	set -- "$@" --server-whitelist ./config/server-whitelist.json --use-server-whitelist=true
fi
if [ -n "${RCON_PW:-}" ]; then
	set -- "$@" --rcon-password "$RCON_PW"
fi

exec ./bin/x64/factorio "$@"