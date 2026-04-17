# Ignore all packages — managed by metapac instead.
function IgnoreAllPackages() {
    mapfile -t ignore_foreign_packages < <(pacman -Qqm)
    mapfile -t ignore_packages < <(pacman -Qqn)
}
IgnoreAllPackages

# Ignore all paths — aconfmgr is only used for non-dotfile system config.
# To start managing specific paths, replace with a whitelist call, e.g.:
#   etc_whitelist=(
#       'systemd/system/*.service'
#       'NetworkManager/conf.d/*'
#   )
#   IgnorePathsExcept /etc "${etc_whitelist[@]}"
IgnorePath '/*'
