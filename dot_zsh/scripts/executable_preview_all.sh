#!/bin/bash

# MIME type of the file
mime=$(file --mime-type -b "$1" 2>/dev/null)

# Cleanup function
cleanup() {
	[[ -n "$thumb_cache" ]] && rm -f "$thumb_cache"
}
trap cleanup EXIT

# Handle different MIME types 
case "$mime" in
	text/*)
		# Use bat for text files
		bat --color=always --style=numbers "$1" 2>/dev/null
		;;
	inode/directory)
		tree "$1" 2>/dev/null
		;;
	image/jpeg | image/png)
		# Use magick to display images in the terminal using sixel
		#magick "$1" -geometry 800x480 sixel:- 2>/dev/null
		;;
	application/pdf)
		# Use pdftotext for PDF files
		pdftotext "$1" - | head -n 1000 2>/dev/null
		;;
	application/epub+zip)
		# Use epub2txt for EPUB files
		epub2txt "$1" | head -n 1000 2>/dev/null
		;;
	video/*)
		# Generate a thumbnail for video files
		thumb_cache=$(mktemp "${TMPDIR:-/tmp}/thumb_cache.XXXXX.png")
		ffmpegthumbnailer -i "$1" -o "$thumb_cache" -s 0 2>/dev/null
		# Display the thumbnail
		img2sixel < "$thumb_cache" 2>/dev/null
		;;
	application/x-tar | application/gzip | application/x-compressed-tar | application/x-bzip2 | application/x-xz | application/zip | application/x-7z-compressed | application/x-rar-compressed)
		~/.config/lf/pistol-static-linux-x86_64 "$1" 2>/dev/null
		;;
	*)
		# Default: show file details
		echo "File type: $mime"
		echo "No preview available for this file type."
		;;
esac
