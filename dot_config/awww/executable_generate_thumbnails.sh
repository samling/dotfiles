#!/bin/sh
# Lists wallpaper images and generates missing thumbnails in the background.
#
# Usage: generate_thumbnails.sh WALLPAPER_DIR [CACHE_DIR] [SIZE]
#
# Outputs one line per image: full_path<TAB>thumbnail_path<TAB>mtime_epoch
# Thumbnail generation happens after listing is complete (non-blocking for caller).
# Requires: magick (ImageMagick 7)

WALLPAPER_DIR="$1"
CACHE_DIR="${2:-$HOME/.cache/wallpaper-thumbnails}"
SIZE="${3:-320x200}"

if [ -z "$WALLPAPER_DIR" ] || [ ! -d "$WALLPAPER_DIR" ]; then
	echo "Usage: $0 WALLPAPER_DIR [CACHE_DIR] [SIZE]" >&2
	exit 1
fi

mkdir -p "$CACHE_DIR"

# Collect image list with stat in batch (much faster than per-file stat)
IMGLIST=$(mktemp)
trap '"rm" -f "$IMGLIST"' EXIT

find "$WALLPAPER_DIR" -not -path '*/.git/*' -type f \( \
	-iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
	-o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \
\) -printf '%p\t%T@\n' > "$IMGLIST"

# Output listing immediately (fast — no magick calls)
while IFS='	' read -r img mtime; do
	relpath="${img#"$WALLPAPER_DIR"/}"
	thumbname=$(echo "${relpath%.*}" | tr '/' '_')
	thumb="$CACHE_DIR/${thumbname}.jpg"
	printf '%s\t%s\t%s\n' "$img" "$thumb" "${mtime%.*}"
done < "$IMGLIST"

# Generate missing thumbnails in the background after listing is output
(
	while IFS='	' read -r img mtime; do
		relpath="${img#"$WALLPAPER_DIR"/}"
		thumbname=$(echo "${relpath%.*}" | tr '/' '_')
		thumb="$CACHE_DIR/${thumbname}.jpg"
		if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
			magick "$img" -thumbnail "$SIZE^" -gravity center -extent "$SIZE" -quality 80 "$thumb" 2>/dev/null
		fi
	done < "$IMGLIST"

	# Clean stale thumbnails
	VALID=$(mktemp)
	while IFS='	' read -r img _; do
		relpath="${img#"$WALLPAPER_DIR"/}"
		echo "$CACHE_DIR/$(echo "${relpath%.*}" | tr '/' '_').jpg"
	done < "$IMGLIST" > "$VALID"
	find "$CACHE_DIR" -maxdepth 1 -name '*.jpg' -type f | while IFS= read -r cached; do
		if ! grep -qxF "$cached" "$VALID"; then
			"rm" -f "$cached"
		fi
	done
	"rm" -f "$VALID"
) < /dev/null > /dev/null 2>&1 &
disown
