#!/bin/bash

function ssh_status_cell() {
    user=$(whoami)
    hostname=$(cat /etc/hostname)
    if [[ -n $SSH_CONNECTION ]]; then
        echo "#[fg=green,bg=default]#[fg=black,bg=green] $user"@"$hostname #[fg=green,bg=default] "
    fi
}

ssh_status_cell
