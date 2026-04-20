#!/usr/bin/env bash

# Simulate a notification with a desktop entry with the following command:
# notify-send "Test" "Test" -a "Slack" -h string:desktop_entry:slack

# Get the desktop entry from the environment variable
echo $DUNST_APP_NAME
echo $DUNST_DESKTOP_ENTRY
echo $DUNST_ID