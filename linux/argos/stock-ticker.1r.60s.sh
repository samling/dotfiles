#!/bin/bash

URL="github.com/p-e-w/argos"
DIR=$(dirname "$0")
lastupdated=$(cat /tmp/argos-stockticker-lastupdated.txt)

source /home/sboynton/.pyenv/versions/3.11.1/envs/venv/bin/activate
python /home/sboynton/dotfiles/linux/argos/stock-ticker.py

echo "---"
echo "Last updated: $lastupdated"
