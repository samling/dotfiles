#!/bin/bash

case "$1" in
  "root")   echo "" ;;
  "prefix")   echo "#[fg=colour4,bg=default]#[fg=#000000,italics,bg=colour4]^A#[fg=colour4,bg=default,nobold,noitalics]" ;;
  "locked")   echo "#[fg=red,bg=default]#[fg=#000000,italics,bg=red]LOCKED#[fg=red,bg=default,nobold,noitalics]" ;;
  "move")   echo "#[fg=yellow,bg=default]#[fg=#000000,italics,bg=yellow]move#[fg=yellow,bg=default,nobold,noitalics]" ;;
  *)        echo "#[fg=white]$1#[default]" ;;
esac
