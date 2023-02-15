#!/bin/bash

set -e

# TODO: Check that we have the zshrc-local repo cloned as well

# Check prereqs
CURR_SHELL=$(ps -p $$ | tail -n -1 | awk '{print $4}')
[ "${GITHUB_TOKEN}" ] && echo "Found GITHUB_TOKEN; continuing with install" || ( echo "GITHUB_TOKEN is not set" )
[ "${CURR_SHELL}" ] && echo "Current shell is ZSH; continuing with install" || ( echo "ZSH is not installed or is not the current shell; installing ZSH. Please reboot after installation and rerun script"; apt-get install zsh; chsh -s /usr/bin/zsh )

# Check if we're running as root; if not, elevate via sudo
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# Provision system
make -f ./Makefile
