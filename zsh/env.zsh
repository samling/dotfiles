# Environment
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Default editor
export EDITOR="vim"

# Go Code
export GOPATH=$HOME/.gocode

# Tmux
export TMUX_POWERLINE_SEG_WEATHER_LOCATION="2411898"

# GCC
export ARCHFLAGS="-arch x86_64"

# Docker
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=/Users/sboynton/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1

# Wireshark
# This exports the symmetric session key to a file
launchctl setenv SSLKEYLOGFILE ~/Documents/Security/Keys/sslkeylog.log
