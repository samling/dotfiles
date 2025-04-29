#!/bin/bash

# --- Configuration ---
N=15  # Set the total number of notifications you want to send
SUMMARY="Test Notification" # Optional: Set a title for your notifications
BODY_PREFIX="This is notification number:" # Optional: Text before the index

# --- Loop ---
for (( i=1; i<=N; i++ ))
do
  # Construct the body string with the index
  current_body="$BODY_PREFIX $i"

  # Send the notification
  notify-send "$SUMMARY" "$current_body"

  # Optional: Add a small delay to avoid overwhelming the notification system
  # sleep 0.5 # Sleep for half a second
done

echo "Sent $N notifications."
