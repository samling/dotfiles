#!/bin/bash

SPACER="<span></span> "
RED='#ffb3ba'
YELLOW='#ffffba'
GREEN='#baffc9'

CPU_TEMP=$(/usr/bin/acpi -t | jc --acpi | jq '.[0]["temperature"]')

COLOR='#FFFFFF'
if [ $CPU_TEMP -gt 70 ]; then
  COLOR=$RED
elif [ $CPU_TEMP -gt 50 ] && [ $CPU_TEMP -lt 70 ]; then
  COLOR=$YELLOW
elif [ $CPU_TEMP -lt 50 ]; then
  COLOR=$GREEN
fi
echo "${SPACER}<span foreground='${COLOR}'>${CPU_TEMP}C</span>"
