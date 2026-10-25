#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")/.."
mkdir -p build

if [[ -s build/factorio-headless_linux.tar.xz && -s build/version.txt ]]; then
	printf 'Factorio headless server version: %s (already downloaded)\n' "$(<build/version.txt)"
else
	printf 'Downloading Factorio headless server...\n'
	download_url=$(curl --silent --fail --location --output build/factorio-headless_linux.tar.xz.tmp --write-out '%{url_effective}' \
		https://factorio.com/get-download/stable/headless/linux64)

	# Extract version from the download URL
	version=${download_url##*/factorio-headless_linux_} # 1.2.3.tar.xz?secure=...
	version=${version%%.tar.xz*} # 1.2.3
	mv build/factorio-headless_linux.tar.xz.tmp build/factorio-headless_linux.tar.xz
	printf '%s\n' "$version" > build/version.txt
	printf 'Factorio headless server version: %s\n' "$version"
fi

for url in \
	https://raw.githubusercontent.com/wube/factorio-data/master/server-settings.example.json \
	https://raw.githubusercontent.com/wube/factorio-data/master/map-settings.example.json \
	https://raw.githubusercontent.com/wube/factorio-data/master/map-gen-settings.example.json
do
	filename=${url##*/} # Remove "example" from filename
	output="build/${filename%.example.json}.json"
	if [[ -s "$output" ]]; then
		printf '%s already downloaded\n' "${output##*/}"
		continue
	fi
	printf 'Downloading %s...\n' "$filename"
	curl --silent --fail --location --output "$output.tmp" "$url"
	mv "$output.tmp" "$output"
done
