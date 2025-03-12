#!/bin/bash

current_sessions=$(zellij list-sessions -ns)

max_numeric=-1
while IFS= read -r session; do
  if [[ $session =~ ^[0-9]+$ ]]; then
    if ((session > max_numeric )); then
      max_numeric=$session
    fi
  fi
done <<< "$current_sessions"

next_session=$((max_numeric + 1))

zellij -s "${next_session}" $@ 2>&1
