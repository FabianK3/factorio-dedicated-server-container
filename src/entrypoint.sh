#!/bin/sh
set -eu

# Deploy default configs if missing
for file in ./default-config/*.json; do
	if [ ! -e "./config/${file##*/}" ]; then
		cp "$file" ./config/
	fi
done

save="./saves/${SAVEGAME_NAME}.zip"

# Create new save if none is found under specified name
if [ ! -f "$save" ]; then
	./bin/x64/factorio --create "$save" \
		--map-gen-settings ./config/map-gen-settings.json \
		--map-settings ./config/map-settings.json \
		--mod-directory ./mods
fi

# Create admin config file if missing
if [ ! -f ./config/server-adminlist.json ]; then
	printf '[]\n' > ./config/server-adminlist.json
fi
# Create whitelist config if missing
if [ ! -f ./config/server-whitelist.json ]; then
	printf '[]\n' > ./config/server-whitelist.json
fi

# Base args
set -- --start-server "$save" \
	--server-settings ./config/server-settings.json \
	--mod-directory ./mods \
	--server-adminlist ./config/server-adminlist.json

# Attach whitelist config file if enabled
if [ "$USE_WHITELIST" = "true" ]; then
	set -- "$@" --server-whitelist ./config/server-whitelist.json --use-server-whitelist=true
fi

# Set RCON password if given
if [ -n "${RCON_PW:-}" ]; then
	set -- "$@" --rcon-password "$RCON_PW"
fi

exec ./bin/x64/factorio "$@"