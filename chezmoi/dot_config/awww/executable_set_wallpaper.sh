#!/bin/sh
# Sets the wallpaper for a given display (or all displays) and generates a
# color scheme from the image via wallust.
#
# Usage:
#   set_wallpaper.sh IMAGE [OUTPUT]
#
# IMAGE  — path to the image file
# OUTPUT — optional awww output name (see awww-query(1)); omit to set all
#
# Requires: awww, wallust

IMAGE="$1"
OUTPUT="$2"

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mIMAGE\e[0m [\e[4mOUTPUT\e[0m]\n" "$0"
	exit 1
fi

LOG=~/.local/state/quickshell/set_wallpaper.log
mkdir -p "$(dirname "$LOG")"
TARGET=~/.local/state/quickshell/generated/wallust.json

log() {
	printf '[%s] [%s] %s\n' "$(date '+%H:%M:%S.%3N')" "$$" "$1" >>"$LOG"
}

# Set wallpaper via awww
RESIZE_TYPE="crop"
export AWWW_TRANSITION_FPS="${AWWW_TRANSITION_FPS:-60}"
export AWWW_TRANSITION_STEP="${AWWW_TRANSITION_STEP:-2}"

log "START image=$IMAGE"

if [ -n "$OUTPUT" ]; then
	awww img --resize "$RESIZE_TYPE" --outputs "$OUTPUT" "$IMAGE"
else
	awww img --resize "$RESIZE_TYPE" "$IMAGE"
fi

# Generate raw image-extracted palette via wallust (kmeans / dark16).
# Writes $TARGET per ~/.config/wallust/wallust.toml.
#
# kmeans takes 5-10s on uncached images. SIGKILL any in-flight wallust from a
# prior invocation; SIGTERM may not be honored until the compute loop yields,
# allowing a stale run to overwrite the target after the new one finishes.
OTHERS=$(pgrep -x wallust | grep -v "^$$\$" | tr '\n' ' ')
if [ -n "$OTHERS" ]; then
	log "killing stale wallust pids: $OTHERS"
	pkill -9 -x wallust 2>/dev/null
fi

PRE_MTIME=$(stat -c '%y' "$TARGET" 2>/dev/null)
PRE_HASH=$(md5sum "$TARGET" 2>/dev/null | cut -d' ' -f1)
log "wallust starting  pre: mtime=$PRE_MTIME hash=$PRE_HASH"

# fastresize is ~40x faster than kmeans and tolerates low-diversity images
# (kmeans fails with "Not enough colors!" on near-monochromatic palettes).
wallust run --skip-sequences --no-hooks --quiet --backend fastresize "$IMAGE" 2>/tmp/wallust.err
RC=$?
if [ "$RC" -ne 0 ]; then
	log "wallust failed (rc=$RC): $(cat /tmp/wallust.err | tr '\n' ' ' | head -c 200)"
fi
"rm" -f /tmp/wallust.err

POST_MTIME=$(stat -c '%y' "$TARGET" 2>/dev/null)
POST_HASH=$(md5sum "$TARGET" 2>/dev/null | cut -d' ' -f1)
if [ "$PRE_HASH" = "$POST_HASH" ]; then
	CHANGED="NO"
else
	CHANGED="YES"
fi
log "wallust exit=$RC  post: mtime=$POST_MTIME hash=$POST_HASH changed=$CHANGED"

if [ "$RC" -eq 0 ]; then
	notify-send -a wallust -i "$IMAGE" "Wallust palette updated" "$(basename "$IMAGE")"
else
	notify-send -a wallust -u critical "Wallust failed (rc=$RC)" "$(basename "$IMAGE")"
fi

echo "Wallpaper set to: $IMAGE"
