#!/bin/sh
# Generates cached thumbnails for wallpaper images.
# Only regenerates when the source image is newer than the cached thumbnail.
#
# Usage: generate_thumbnails.sh WALLPAPER_DIR [CACHE_DIR] [SIZE]
#
# Outputs one line per image: full_path<TAB>thumbnail_path<TAB>mtime_epoch
# Requires: magick (ImageMagick 7)

WALLPAPER_DIR="$1"
CACHE_DIR="${2:-$HOME/.cache/wallpaper-thumbnails}"
SIZE="${3:-320x200}"

if [ -z "$WALLPAPER_DIR" ] || [ ! -d "$WALLPAPER_DIR" ]; then
	echo "Usage: $0 WALLPAPER_DIR [CACHE_DIR] [SIZE]" >&2
	exit 1
fi

mkdir -p "$CACHE_DIR"

VALID_THUMBS=$(mktemp)
trap '"rm" -f "$VALID_THUMBS"' EXIT

find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
	-iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
	-o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \
\) | sort | while IFS= read -r img; do
	basename=$(basename "$img")
	thumb="$CACHE_DIR/${basename%.*}.jpg"

	# Regenerate only if source is newer or thumbnail doesn't exist
	if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
		magick "$img" -thumbnail "$SIZE^" -gravity center -extent "$SIZE" -quality 80 "$thumb" 2>/dev/null
	fi

	echo "$thumb" >> "$VALID_THUMBS"
	mtime=$(stat -c '%Y' "$img" 2>/dev/null || stat -f '%m' "$img" 2>/dev/null || echo 0)
	printf '%s\t%s\t%s\n' "$img" "$thumb" "$mtime"
done

# Remove stale thumbnails that no longer correspond to a source image
find "$CACHE_DIR" -maxdepth 1 -name '*.jpg' -type f | while IFS= read -r cached; do
	if ! grep -qxF "$cached" "$VALID_THUMBS"; then
		"rm" -f "$cached"
	fi
done
