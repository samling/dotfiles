#!/usr/bin/env bash

CURR_AWS_PROFILE=$(tmux showenv -g TMUX_AWS_PROFILE_$(tmux display -p "#D" | tr -d %) | sed 's/^.*=//')
CURR_AWS_STATUS="aws:${CURR_AWS_PROFILE:-default}"
echo "☁  ${CURR_AWS_STATUS}"
