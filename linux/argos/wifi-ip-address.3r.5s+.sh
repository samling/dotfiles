#!/bin/bash

IP_ADDR=$(ifconfig | jc --ifconfig | jq -r '.[] | select(.name | startswith("wlp0s20f3"|"wlp9s0")) | .ipv4[0].address')

OUTPUT="<span></span> <span foreground='#bae1ff'>${IP_ADDR}</span>"

echo "🌐 ${OUTPUT}"
