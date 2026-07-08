#!/usr/bin/env bash

set -euo pipefail

if [ -z "$INST_MC_DIR" ]; then
    echo "\$INST_MC_DIR is unset"
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "jq is required" >&2
	exit 1
fi

if ! command -v inotifywait >/dev/null 2>&1; then
	echo "inotifywait (inotify-tools) is required" >&2
	exit 1
fi

# create fake mod to hijack
# https://github.com/tesselslate/waywall/blob/d53c2e42f5f28dd19b3b47c7d79a562e6c790e00/waywall/instance.c#L77
# tbf this was easier than making a pr .w.
root="dev/tildejustin/stateoutput"
mod="$INST_MC_DIR/mods/fakestateoutput.jar"

rm -rf dev
rm -f "$mod"
mkdir -p "$root"
zip -q -r "$mod" dev

FILE="$INST_MC_DIR/hermes/state.json"
OUT="$INST_MC_DIR/wpstateout.txt"

rm -r dev

write_state() {
	cls=$(jq -r '.screen.class // empty' "$FILE" 2>/dev/null)
	pause=$(jq -r '.screen.is_pause // false' "$FILE" 2>/dev/null)
	world=$(jq -r '.world // empty' "$FILE" 2>/dev/null)

	local out=""

	if [[ "$cls" == "net.minecraft.client.gui.screens.TitleScreen" ]]; then
		out="title"
	elif [[ "$cls" == "net.minecraft.client.gui.screens.LevelLoadingScreen" ]]; then
		# hermes doesn't expose the progress
		out="generating,0"
	elif [[ -n "$world" && "$pause" == "true" ]]; then
		out="inworld,paused"
	elif [[ -n "$world" && -z "$cls" ]]; then
		out="inworld,unpaused"
	elif [[ -n "$world" && -n "$cls" ]]; then
		out="inworld,gamescreenopen"
	else
		out="waiting"
	fi

	printf '%s' "$out" > "$OUT"
}

write_state

coproc WATCHER {
    exec inotifywait -m -q -e close_write,create,modify,move "$FILE"
}

while read -r _ <&"${WATCHER[0]}"; do
    write_state &
done &

reader=$!

"$@"
status=$?

kill "$reader" "${WATCHER_PID}" 2>/dev/null
wait "$reader" 2>/dev/null

rm -f "$mod"

exit "$status"