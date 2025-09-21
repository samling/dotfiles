#!/bin/sh
# For each display, changes the wallpaper to a randomly chosen image in
# a given directory at a set interval.

# Create a PID file location in the user's cache directory
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/swww_randomize.pid"

# Check if the script is already running
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Script is already running with PID $PID"
        exit 1
    else
        # If process doesn't exist but PID file does, remove stale PID file
        rm "$PIDFILE"
    fi
fi

# Store current PID
echo $$ > "$PIDFILE"

# Cleanup PID file on exit
trap 'rm -f "$PIDFILE"; exit 0' INT TERM EXIT

DEFAULT_INTERVAL=300 # In seconds

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mDIRECTORY\e[0m [\e[4mINTERVAL\e[0m]\n" "$0"
	printf "\tChanges the wallpaper to a randomly chosen image in DIRECTORY every\n\tINTERVAL seconds (or every %d seconds if unspecified)." "$DEFAULT_INTERVAL"
	exit 1
fi

# See swww-img(1)
RESIZE_TYPE="crop"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

while true; do
	find "$1" -type f \
	| while read -r img; do
		echo "$(</dev/urandom tr -dc a-zA-Z0-9 | head -c 8):$img"
	done \
	| sort -n | cut -d':' -f2- \
	| while read -r img; do
		for d in $(swww query | cut -d: -f2 | tr -d ' '); do # see swww-query(1)
			# Get next random image for this display, or re-shuffle images
			# and pick again if no more unused images are remaining
			[ -z "$img" ] && if read -r img; then true; else break 2; fi
			swww img --resize "$RESIZE_TYPE" --outputs "$d" "$img"
			unset -v img # Each image should only be used once per loop
		done
		sleep "${2:-$DEFAULT_INTERVAL}"
	done
done
