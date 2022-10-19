export PS1=$PS1'$([ -n $TMUX ] && tmux setenv -g TMUX_AWS_PROFILE_$(tmux display -p "#D" | tr -d %) ${AWS_PROFILE:-default})'
