#!/usr/bin/env bash

APP_DIR="${HOME}/.local/share/applications"
PATTERN_CURSOR="*Cursor.desktop"

if [[ ! -d "$APP_DIR" ]]; then
  echo "Error: '$APP_DIR' not found."
  exit 1
fi

shopt -s nullglob
files=("$APP_DIR"/$PATTERN_CURSOR)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No files matching '$PATTERN_CURSOR' found in '$APP_DIR'."
else
  echo "Found ${#files[@]} file(s) matching '$PATTERN_CURSOR' in '$APP_DIR':"
  for file in "${files[@]}"; do
    if [[ -f "$file" || -L "$file" ]]; then
      echo "Patching icon for file: $file"
      sed -i.bak "s|^Icon=.*|Icon=$HOME/Applications/cursor.png|" $file
    fi
  done
fi

echo "Done."
exit 0
