#! /usr/bin/sh

windowsInfo='sort_by(.workspace.id) | .[] | .address + "\t" + (.workspace.id|tostring) + "\t" + .title'

hyprctl clients -j \
  | jq "$windowsInfo" -r \
  | fzf +m --with-nth 2,3 \
      --delimiter '\t' \
      --bind='enter:become:hyprctl dispatch focuswindow address:{1}'
