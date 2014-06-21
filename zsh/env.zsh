# Environment
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Default editor
export EDITOR="vim"

# Tmux
export TMUX_POWERLINE_SEG_WEATHER_LOCATION="2411898"

# GCC
export ARCHFLAGS="-arch x86_64"

# Docker
export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
