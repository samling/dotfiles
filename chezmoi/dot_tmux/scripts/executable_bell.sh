#!/bin/sh
SESSION="$1"
WINDOW="$2"
LAST=$(tmux capture-pane -t "$SESSION:$WINDOW" -p -S -3 | sed '/^$/d' | tail -n 1)
MSG="🦴 $SESSION:$WINDOW — ${LAST:-bell} 🦴"

tmux display-popup -t "$SESSION:$WINDOW" -x P -y P -w 60 -h 3 \
    "printf '%s' \"$MSG\"" &
(sleep 1 && tmux display-popup -t "$SESSION:$WINDOW" -C) &


