#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [--init/-i <saves>] [--prepare/-p] [--watch/-w]"
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
	echo "Copying saves to /tmp/mcsr"
	maps=/home/nml/Documents/Minecraft/mcsr/maps

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