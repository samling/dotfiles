#!/bin/bash

# case "$1" in
#   "root")   echo "#[fg=colour4,bg=default]#[fg=#000000,italics,bg=colour4]NORMAL#[fg=colour4,bg=default,nobold,noitalics]" ;;
#   "prefix")   echo "#[fg=#cba6f7,bg=default]#[fg=#000000,italics,bg=#cba6f7]PREFIX#[fg=#cba6f7,bg=default,nobold,noitalics]" ;;
#   "locked")   echo "#[fg=red,bg=default]#[fg=#000000,italics,bg=red]LOCKED#[fg=red,bg=default,nobold,noitalics]" ;;
#   "move")   echo "#[fg=yellow,bg=default]#[fg=#000000,italics,bg=yellow] MOVE #[fg=yellow,bg=default,nobold,noitalics]" ;;
#   *)        echo "#[fg=white]$1#[default]" ;;
# esac

case "$1" in
  "root")   echo "#[fg=colour4,bg=default,bold,italics]NORMAL#[fg=default,bg=default,nobold,noitalics]" ;;
  "prefix")   echo "#[fg=#cba6f7,bg=default,bold,italics]PREFIX#[fg=default,bg=default,nobold,noitalics]" ;;
  "locked")   echo "#[fg=red,bg=default,bold,italics]LOCKED#[fg=default,bg=default,nobold,noitalics]" ;;
  "move")   echo "#[fg=yellow,bg=default,bold,italics]MOVE#[fg=default,bg=default,nobold,noitalics]" ;;
  *)        echo "#[fg=white]$1#[default]" ;;
esac
