# Factorio dedicated server container

A Docker image for the [Factorio headless server](https://wiki.factorio.com/Multiplayer#Dedicated/Headless_server). The build downloads the latest stable server from Factorio and example settings from the [Factorio data repository](https://github.com/wube/factorio-data).

## Requirements

- Linux with Docker and the Docker Compose plugin
- `make`, Bash, and `curl` for downloading and building

## Build and run

```sh
make # Download, build, and export the image

# Start on same host
mkdir -p volumes/config volumes/mods volumes/saves
docker compose up -d

# Start on different host after transferring publish/factorio-dedicated-server-latest.tar
docker load -i publish/factorio-dedicated-server-latest.tar
mkdir -p volumes/config volumes/mods volumes/saves
docker compose up -d

# Optionally, to remove build artifacts and images
make clean
```

`make` runs `download`, `build`, and `publish` in order. The download step saves the server and example JSON settings files in `build/`.

The build step tags the image as `factorio-dedicated-server:<version>` and `factorio-dedicated-server:latest`.

The publish step writes `publish/factorio-dedicated-server-latest.tar`; it does not push to a registry or transfer the image.

The container runs as the non-root `factorio` user. **All three bind-mounted directories must be writable by that user.** Check the image's numeric UID/GID with:

```sh
docker run --rm --entrypoint id factorio-dedicated-server:latest
```

Set ownership or host filesystem permissions on `volumes/config`, `volumes/mods`, and `volumes/saves` accordingly before `docker compose up`. Docker-created bind directories may be owned by root. Compose uses the `latest` tag, so build it locally or load the exported archive first.

## Configuration

On startup, missing `server-settings.json`, `map-settings.json`, and `map-gen-settings.json` are copied from the image into `volumes/config`. A missing `mod-list.json` is copied into `volumes/mods`. Existing files are never overwritten. Factorio can generate this list itself, but the image supplies one so you can choose vanilla or Space Age before the first save is created. The host's `volumes/mods` is the container's `/opt/factorio/mods`.

The admin list is created as `server-adminlist.json` containing `[]` if absent. When whitelist enforcement is enabled, a missing `server-whitelist.json` is also created as `[]`.

Edit the files in `volumes/config` and restart the service to apply server settings.

The downloaded [server settings are examples](https://github.com/wube/factorio-data), not personalized settings.

`compose.yaml` provides these options:

| Setting | Default | Effect |
| --- | --- | --- |
| `name` | `server` | Uses `volumes/saves/<name>.zip`; creates it if missing, otherwise loads it. |
| `USE_WHITELIST` | `false` | When `true`, creates `server-whitelist.json` as `[]` if absent and enforces it. Add allowed Factorio usernames before players connect. |
| `RCON_PW` | empty | Enables RCON when non-empty. Uncomment and set this variable in `compose.yaml`; also uncomment the TCP 27015 port mapping if remote access is needed. |

New saves use `map-gen-settings.json` and `map-settings.json`; changing either file does not alter an existing save. To start a new map with different settings, stop the server, back up or rename the old save, edit the settings, and restart.

## Mods

Edit `volumes/mods/mod-list.json` to enable or disable mods. The default enables `base`, `elevated-rails`, `quality`, and `space-age`, so new saves use Space Age. For a new vanilla save, set `enabled` to `false` for `elevated-rails`, `quality`, and `space-age` **before the save is created**. Place additional compatible mod zip files in `volumes/mods` and add their names to the list with `enabled: true`. The server and all clients need matching game and mod versions.

The mod list affects save creation; changing it does not retroactively turn an existing vanilla save into a Space Age save. For an uploaded save with a different mod set, install its required mods in `volumes/mods` and optionally sync the list once before starting the server:

```sh
docker compose run --rm --entrypoint ./bin/x64/factorio factorio --mod-directory ./mods --sync-mods ./saves/server.zip
```

Replace `server.zip` with your save filename. Downloading missing mods during sync requires `service-username` and `service-token` in Factorio's `player-data.json`; otherwise install the mods yourself. Check `volumes/mods/mod-list.json` after syncing, then run `docker compose up -d`.

See the [dedicated server guide](https://wiki.factorio.com/Multiplayer#Dedicated/Headless_server), [command-line options](https://wiki.factorio.com/Command_line_parameters), and [Factorio staff guidance on Space Age and syncing saves](https://forums.factorio.com/viewtopic.php?p=621129#p621129).

To use an existing save, place its zip file in `volumes/saves` and set `name` in `compose.yaml` to its filename without `.zip`.

The whitelist and admin list use JSON arrays of usernames, for example `["PlayerName"]`.

## More

All rights for components used in this project go to their respective owner.

For information on how to administrate the Factorio server itself, see the official wiki.