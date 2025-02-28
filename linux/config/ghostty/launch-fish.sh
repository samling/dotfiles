#!/bin/zsh

# Launch fish with the login shell
if command -v /usr/local/bin/fish >/dev/null 2>&1; then
    /usr/local/bin/fish --login --interactive
else
    echo "Fish not found; falling back to zsh"
    echo "Create a symlink to fish in /usr/local/bin"
    zsh
fi
