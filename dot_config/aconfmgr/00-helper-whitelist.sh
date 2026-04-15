# Whitelist helper — IgnorePathsExcept
# Source: https://github.com/CyberShadow/aconfmgr/wiki/Whitelist-files
# Copied from https://github.com/hcartiaux/aconfmgr/blob/main/02-helper-whitelist.sh
#
# Usage:
#   white_list=(
#       'systemd/system/*.service'
#       'NetworkManager/conf.d/*'
#   )
#   IgnorePathsExcept /etc "${white_list[@]}"

function IgnorePathsExcept() {
    local search_dir="${1%/}"
    shift
    local white_list=("$@")
    local find_args=()
    local ignore_path

    if [ ! -d "$search_dir" ]; then
        FatalError "The path ${search_dir} must be an existing directory\n"
    fi

    for ignore_path in "${white_list[@]}"; do
        local base="$ignore_path"
        if [[ "$ignore_path" =~ ^/ ]]; then
            FatalError "The path ${ignore_path} in the whitelist is not relative to the directory ${search_dir}\n"
        fi
        while [ "$base" != '.' ]; do
            find_args+=(-path "$search_dir/$base" -o)
            base="$(dirname "$base")"
        done
    done

    find "$search_dir" -not \( "${find_args[@]}" -path "$search_dir" \) -prune | \
        while read -r file; do
            if [[ -d "$file" ]]; then
                IgnorePath "$file/*"
            fi
            IgnorePath "$file"
        done
}
