#!/usr/bin/env bash

set -euo pipefail

# Shrink the GTK4 portal file picker a bit on scaled displays. The portal is
# dbus-activated, so update the activation environment rather than this shell.
dbus-update-activation-environment --systemd GDK_DPI_SCALE=0.85 &

# Wait briefly for the notification daemon before launching Chrome. This keeps
# the behavior from the Niri startup config without depending on Niri itself.
(
  for _ in $(seq 1 100); do
    if busctl --user get-name-owner org.freedesktop.Notifications >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
  google-chrome-stable
) &

ghostty &
code &
vesktop &
obsidian &
ie-r &
