#!/bin/bash

# Initialize variables
source=""
filepath=""

# Parse command line options
while getopts "s:" opt; do
	case $opt in
		s)
			source="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

# Shift to get the actual filepath argument
shift $((OPTIND-1))
input="$1"

# Process filepath based on source
if [[ "$source" == "zoxide" ]]; then
	# For zoxide, strip the score (float followed by whitespace)
	# Handle optional whitespace before the score, then the score, then required whitespace
	filepath=$(echo "$input" | sed -E 's/^[[:space:]]*[0-9]+\.[0-9]+[[:space:]]+//')
else
	# For other sources, use the input as-is
	filepath="$input"
fi

# MIME type of the file
mime=$(file --mime-type -b "$filepath" 2>/dev/null)

# Cleanup function
cleanup() {
	[[ -n "$thumb_cache" ]] && rm -f "$thumb_cache"
}
trap cleanup EXIT

# Handle different MIME types 
case "$mime" in
	text/*)
		# Use bat for text files
		bat --color=always --style=numbers "$filepath" 2>/dev/null
		;;
	application/*)
		bat --color=always --style=numbers "$filepath" 2>/dev/null
		;;
	inode/directory)
		eza --group-directories-first --color=always "$filepath" 2>/dev/null
		# tree -L 1 "$filepath" 2>/dev/null
		;;
	#image/jpeg | image/png)
	#	# Use magick to display images in the terminal using sixel
	#	magick "$filepath" -geometry 800x480 sixel:-
	#	;;
	#application/pdf)
	#	# Use pdftotext for PDF files
	#	pdftotext "$filepath" - | head -n 1000 2>/dev/null
	#	;;
	#application/epub+zip)
	#	# Use epub2txt for EPUB files
	#	epub2txt "$filepath" | head -n 1000 2>/dev/null
	#	;;
	#video/*)
	#	# Generate a thumbnail for video files
	#	thumb_cache=$(mktemp "${TMPDIR:-/tmp}/thumb_cache.XXXXX.png")
	#	ffmpegthumbnailer -i "$filepath" -o "$thumb_cache" -s 0 2>/dev/null
	#	# Display the thumbnail
	#	img2sixel < "$thumb_cache" 2>/dev/null
	#	;;
	#application/x-tar | application/gzip | application/x-compressed-tar | application/x-bzip2 | application/x-xz | application/zip | application/x-7z-compressed | application/x-rar-compressed)
	#	~/.config/lf/pistol-static-linux-x86_64 "$filepath" 2>/dev/null
	#	;;
	*)
		# Default: show file details
		if [[ "$source" == "zoxide" ]]; then
			echo "Original input: $input"
			echo "Processed: $filepath"
		fi
		echo "No preview available for this file type: $mime"
		;;
esac
