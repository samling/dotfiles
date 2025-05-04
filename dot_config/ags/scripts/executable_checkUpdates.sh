#!/bin/bash

has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

wait_for_process_to_finish() {
    local process_name="$1"
    local pid

    while pid=$(pgrep -x "$process_name"); do
        wait "$pid" 2>/dev/null || true
    done

    sleep 2
}

check_arch_updates() {
    if command -v paru &> /dev/null; then
        aur_helper="paru"
    else
        aur_helper="yay"
    fi

    # Simple header colors
    if has_param "-color" "$@"; then
        pacman_color="\033[1;34m" # Blue
        aur_color="\033[1;32m"    # Green
        NC="\033[0m"              # No Color
    else
        pacman_color=""
        aur_color=""
        NC=""
    fi

    if has_param "-tooltip" "$@"; then
        # command=" | head -n 50"
        command=""
        official_updates=""
        aur_updates=""
        wait_for_process_to_finish "checkupdates"
    else
        command="2>/dev/null | wc -l"
        official_updates=0
        aur_updates=0
    fi

    official_command="checkupdates $command"
    aur_command="$aur_helper -Qum $command"

    if has_param "-nosync" "$@"; then
        official_command="checkupdates --nosync $command"
        aur_command="$aur_helper -Qua $command"
    fi

    if has_param "-y" "$@"; then
        aur_updates=$(eval "$aur_command")
    elif has_param "-p" "$@"; then
        official_updates=$(eval "$official_command")
    else
        aur_updates=$(eval "$aur_command")
        official_updates=$(eval "$official_command")
    fi

    if has_param "-tooltip" "$@"; then
        if [ "$official_updates" ];then
            echo -e "${pacman_color}pacman:${NC}"
            echo "$official_updates"
        fi
        if [ "$official_updates" ] && [ "$aur_updates" ];then
            echo ""
        fi
        if [ "$aur_updates" ];then
            echo -e "${aur_color}AUR:${NC}"
            echo "$aur_updates"
        fi
    else
        total_updates=$((official_updates + aur_updates))
        echo $total_updates
    fi
}

check_ubuntu_updates() {
    result=$(apt-get -s -o Debug::NoLocking=true upgrade | grep -c ^Inst)
    echo "$result"
}

check_fedora_updates() {
    result=$(dnf check-update -q | grep -v '^Loaded plugins' | grep -v '^No match for' | wc -l)
    echo "$result"
}

case "$1" in
    -arch)
        check_arch_updates "$2" "$3" "$4"
        ;;
    -ubuntu)
        check_ubuntu_updates
        ;;
    -fedora)
        check_fedora_updates
        ;;
    *)
        echo "0"
        ;;
esac
