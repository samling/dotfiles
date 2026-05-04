#!/usr/bin/env bash

# Example of a firefox popup window:
# Window 6462702f3910 -> :
#         mapped: 1
#         hidden: 0
#         at: 5847,12
#         size: 941,1056
#         workspace: 10 (10)
#         floating: 0
#         pseudo: 0
#         monitor: 0
#         class: firefox
#         title:
#         initialClass: firefox
#         initialTitle:
#         pid: 9956
#         xwayland: 0
#         pinned: 0
#         fullscreen: 0
#         fullscreenClient: 0
#         grouped: 0
#         tags:
#         swallowing: 0
#         focusHistoryID: 4
#         inhibitingIdle: 0

# handle_firefox_extension_window() {
#     #  hyprctl dispatch setfloating address:0x6359abe28ee0
#     #  setprop address:6359abe28ee0 maxsize 800 800
#     # dispatch focuswindow address:0x6359abe28ee0;dispatch centerwindow
#     is_floating=$(hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address==$addr) | .floating')
#     if [ "$is_floating" != "true" ]; then
#         command_arg=$(printf 'dispatch setfloating address:%s;setprop address:%s maxsize 800 800;dispatch focuswindow address:%s;dispatch centerwindow' "$1" "$1" "$1")
#         hyprctl --quiet --batch "$command_arg";
#     fi
# }

handle_firefox_popup() {
    #  hyprctl dispatch setfloating address:0x6359abe28ee0
    #  setprop address:6359abe28ee0 maxsize 800 800
    # dispatch focuswindow address:0x6359abe28ee0;dispatch centerwindow
    #command_arg=$(printf 'dispatch setfloating address:%s;setprop address:%s maxsize 800 800;dispatch focuswindow address:%s;dispatch centerwindow' "$1" "$1" "$1")
    #hyprctl --quiet --batch "$command_arg";
    echo "handled"
    echo "$1"
}

handle_firefox_title_change() {
    case $2 in
        # 'Extension:'*'— Firefox') handle_firefox_extension_window "$1" "$2" ;;
        * ) handle_firefox_popup "$1" ;;
    esac
}

handle_title_change() {
    # windowtitlev2>>6359a1e5f730,Extension: (Bitwarden Password Manager) - — Firefox Developer Edition
    # openwindow>>64627033d820,1,firefox,
    window_data=$(printf "%s" "$1" | awk -F'>>' '{print $2}');
    window_address=$(printf "0x%s" "$window_data" | awk -F',' '{print $1}')
    window_initial_class=$(hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address==$addr) | .initialClass');
    window_initial_title=$(hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address==$addr) | .initialTitle');
    window_class=$(hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address==$addr) | .class');
    window_title=$(hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address==$addr) | .title');

    echo """
    window_data: $window_data
    window_address: $window_address
    window_title: $window_title
    window_initial_class: $window_initial_class
    window_initial_title: $window_initial_title
    window_class: $window_class
    """

    if [ "$window_initial_class" == "firefox" ] && \
        [ "$window_initial_title" == "" ] && \
        [ "$window_class" == "firefox" ] && \
        [ "$window_title" == "" ]; then
        # If we get a new firefox window with no title or initialTitle, it's probably a popup
        handle_firefox_popup "$window_address"
    else
        handle_firefox_popup "$window_address"
    fi

    # case $window_initial_class in
    #     firefox-developer-edition) handle_firefox_title_change "$window_address" "$window_title" ;;
    #     firefox) handle_firefox_title_change "$window_address" "$window_title" ;;
    # esac
}

handle() {
  case "$1" in
    openwindow*) handle_title_change "$1";
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done