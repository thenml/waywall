#!/usr/bin/env bash
set -euo pipefail


# # /tmp/saves helper script
# 1. tmp-saves.sh -i /path/to/saves
# 	sets up a symlink to /tmp/mcsr from specified directory.
#   run this once per instance
# 2. tmp-saves.sh -p /path/to/maps
#   links maps to /tmp/mcsr.
#   run this before launching an instance
# 3. tmp-saves.sh -w
#   deletes older worlds, keeps maps and 5 recent worlds
# 	run this while playing


usage() {
    echo "Usage: $0 [--init/-i <saves>] [--prepare/-p <maps>] [--watch/-w]"
    echo "  --init/-i <saves>   Initialize saves directory"
    echo "  --prepare/-p        Prepare saves directory"
    echo "  --watch/-w          Watch saves directory for cleanup"
    exit 1
}

if [[ "${1:-}" == "--init" || "${1:-}" == "-i" ]]; then
    saves="$2"
	if [ -z "$saves" ]; then
		usage
		exit 1
	fi
	# confirm to delete if saves is not empty
	if [[ -d $saves ]]; then
		echo "Warning: saves directory $saves is not empty"
		read -p "Are you sure you want to delete it? [y/N] " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			exit 1
		fi
	fi
	rm -rf "$saves"
	ln -s /tmp/mcsr "$saves"
    exit 0
fi

if [[ "${1:-}" == "--prepare" || "${1:-}" == "-p" ]]; then
    maps="$2"
	if [ -z "$maps" ]; then
		usage
		exit 1
	fi
	echo "Copying maps to /tmp/mcsr"

	# remove if exists
	rm -rf /tmp/mcsr

	mkdir /tmp/mcsr
	ls $maps | while read -r i; do
		ln -s "$maps/$i" "/tmp/mcsr/a$i"
	done
	chown $USER:$USER -R /tmp/mcsr
	exit 0
fi

if [[ "${1:-}" == "--watch" || "${1:-}" == "-w" ]]; then
    echo "Watching /tmp/mcsr for cleanup"
	set +e
    while true; do
        ls /tmp/mcsr -t1 --ignore=a* | tail -n +6 | while read -r save; do
            rm -r "/tmp/mcsr/$save"
        done
        sleep 300
    done
	exit 0
fi

usage
