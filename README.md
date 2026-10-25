# Factorio dedicated server container

A Docker image for the [Factorio headless server](https://wiki.factorio.com/Multiplayer#Dedicated/Headless_server). The build downloads the latest stable server from Factorio and example settings from the [Factorio data repository](https://github.com/wube/factorio-data).

## Requirements

- Linux with Docker and the Docker Compose plugin
- `make`, Bash, and `curl` for downloading and building

## Build and run

```sh
make # Download, build, and export the image

# Start on same host
mkdir -p volumes/config volumes/saves
docker compose up -d

# Start on different host after transferring publish/factorio-dedicated-server-latest.tar
docker load -i publish/factorio-dedicated-server-latest.tar
mkdir -p volumes/config volumes/saves
docker compose up -d

# Optionally, to remove build artifacts and images
make clean
```

`make` runs `download`, `build`, and `publish` in order. The download step saves the server and example JSON settings files in `build/`.

The build step tags the image as `factorio-dedicated-server:<version>` and `factorio-dedicated-server:latest`.

The publish step writes `publish/factorio-dedicated-server-latest.tar`; it does not push to a registry or transfer the image.

The container runs as the non-root `factorio` user. **Both bind-mounted directories must be writable by that user.** Check the image's numeric UID/GID with:

```sh
docker run --rm --entrypoint id factorio-dedicated-server:latest
```

Set ownership or host filesystem permissions on `volumes/config` and `volumes/saves` accordingly before `docker compose up`. Docker-created bind directories may be owned by root. Compose uses the `latest` tag, so build it locally or load the exported archive first.

## Configuration

On startup, missing `server-settings.json`, `map-settings.json`, and `map-gen-settings.json` are copied from the image into `volumes/config`. Existing files are never overwritten.

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

To use an existing save, place its zip file in `volumes/saves` and set `name` in `compose.yaml` to its filename without `.zip`.

The whitelist and admin list use JSON arrays of usernames, for example `["PlayerName"]`.
