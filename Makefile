.PHONY: all download build publish clean

all: publish

download:
	bash src/download.sh

build: download
	docker build -f src/Dockerfile -t "factorio-dedicated-server:$$(cat build/version.txt)" -t factorio-dedicated-server:latest .

publish: build
	mkdir -p publish
	docker save -o publish/factorio-dedicated-server-latest.tar factorio-dedicated-server:latest

clean:
	rm -rf build publish
	docker image ls --filter 'reference=factorio-dedicated-server:*' --format '{{.Repository}}:{{.Tag}}' | xargs -r docker image rm
	docker builder prune -af