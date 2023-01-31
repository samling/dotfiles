#!/usr/bin/env bash

URL="github.com/p-e-w/argos"
DIR=$(dirname "$0")

source /home/sboynton/.pyenv/versions/3.11.1/envs/venv/bin/activate
python /home/sboynton/Documents/GitHub/xbar-plugins/Finance/stock-ticker.30s.py

echo "---"
echo "$URL"
echo "$DIR | iconName=folder-symbolic href='file://$DIR'"

