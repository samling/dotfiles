#!/bin/bash

function ssh_status_cell() {
    user=$(whoami)
    hostname=$(cat /etc/hostname)
    if [[ -n $SSH_CONNECTION ]]; then
        echo "#[fg=#cba6f7,bg=default]#[fg=black,bold,bg=#cba6f7] $user"@"$hostname #[fg=#cba6f7,bg=default] "
    fi
}

ssh_status_cell
