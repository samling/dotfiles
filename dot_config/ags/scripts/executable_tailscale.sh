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

            self=$(tailscale status --json | jq -r '.Self')
            self_ip=$(echo "${self}" | jq -r '.TailscaleIPs')
            
            # Extract just the IPv4 address using regex pattern matching
            # This matches any string that has the pattern of IPv4 (numbers and dots)
            ipv4_address=$(echo "${self_ip}" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)

            # Get the exit node name if one is being used
            exitnode=$(tailscale status --json | jq -r '.Self.ExitNode // "None"')
            
            # Format peers as a dictionary with DNS names as keys and online status as values
            peers=$(tailscale status --json | jq -c '{tooltip: (.Peer | reduce .[] as $p ({}; .[$p.DNSName | split(".")[0]] = {online: $p.Online}))}')
            
            # Remove the enclosing braces to merge with the outer JSON
            peers=${peers:1:${#peers}-2}
            
            echo "{\"text\":\"$exitnode\",\"class\":\"connected\",\"alt\":\"connected\", \"ip\":\"$ipv4_address\", $peers}"
        else
            echo "{\"text\":\"\",\"class\":\"stopped\",\"alt\":\"stopped\", \"tooltip\": \"The VPN is not active.\"}"
        fi
    ;;
    --toggle)
        toggle_status
    ;;
esac


