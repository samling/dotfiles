#!/usr/bin/env bash

# NOTE:This script operates in user mode, which is set with `sudo tailscale set --operator=$USER`
# Running tailscale with `sudo` will _revert_ that, i.e. the above command will need to be run again
# to put tailscale back in user mode. If this script isn't working, try that.

STATUS_KEY="BackendState"
RUNNING="Running"

tailscale_status () {
    status="$(tailscale status --json | jq -r '.'$STATUS_KEY)"
    if [ "$status" = $RUNNING ]; then
        return 0
    fi
    return 1
}

toggle_status () {
    if tailscale_status; then
        tailscale down
    else
        tailscale up --accept-routes
    fi
    sleep 5
}

case $1 in
    --status)
        if tailscale_status; then
            T=${2:-"green"}
            F=${3:-"red"}

            peers=$(tailscale status --json | jq -r --arg T "'$T'" --arg F "'$F'" '.Peer[] | ("<span color=" + (if .Online then $T else $F end) + ">" + (.DNSName | split(".")[0]) + "</span>")' | tr '\n' '\r')
            exitnode=$(tailscale status --json | jq -r '.Peer[] | select(.ExitNode == true).DNSName | split(".")[0]')
            echo "{\"text\":\"${exitnode}\",\"class\":\"connected\",\"alt\":\"connected\", \"tooltip\": \"${peers}\"}"
        else
            echo "{\"text\":\"\",\"class\":\"stopped\",\"alt\":\"stopped\", \"tooltip\": \"The VPN is not active.\"}"
        fi
    ;;
    --toggle)
        toggle_status
    ;;
esac


