# function current_dir() {
#     local current_dir=$PWD
#     if [[ $current_dir == $HOME ]]; then
#         current_dir="~"
#     else
#         current_dir=${current_dir##*/}
#     fi
#
#     echo $current_dir
# }

# function change_tab_title() {
#     local title=$1
#     command nohup zellij action rename-tab $title >/dev/null 2>&1
# }
#
# function set_tab_to_working_dir() {
#     local result=$?
#     local title=$(current_dir)
#     # uncomment the following to show the exit code after a failed command
#     # if [[ $result -gt 0 ]]; then
#     #     title="result]" 
#     # fi
#
#     change_tab_title $title
# }
#
# This function automatically renames the default "Tab #1", "Tab #2" etc. to "zsh".
# Since it's highly unlikely we'll ever rename our tabs to the original zellij format,
# this should hopefully not cause any conflicts.
function rename_default_tab_name_to_current_shell() {
    local shell=$(echo ${SHELL##*/}) # print only 'zsh' from e.g. '/usr/bin/zsh'
    if $(zellij action query-tab-names | grep -q "Tab #"); then
      command nohup zellij action rename-tab $shell >/dev/null 2>&1
    fi
}

function set_tab_to_command_line() {
    local cmdline=$1
    change_tab_title $cmdline
}

if [[ -n $ZELLIJ ]]; then
    add-zsh-hook precmd rename_default_tab_name_to_current_shell
    # add-zsh-hook precmd set_tab_to_working_dir
    # add-zsh-hook preexec set_tab_to_command_line
fi
