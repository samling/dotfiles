# Phase 1: manage packages only.
#
# IgnorePath patterns use find -regex semantics where `*` expands to `.*`,
# so a single `/*` covers every path on the system. Aconfmgr still tracks
# installed packages — file tracking is fully disabled.
#
# To start managing specific paths (Phase 2), replace this line with a
# whitelist call, e.g.:
#   etc_whitelist=(
#       'systemd/system/*.service'
#       'NetworkManager/conf.d/*'
#   )
#   IgnorePathsExcept /etc "${etc_whitelist[@]}"
#   # ...and similar for other top-level dirs you want to track.

IgnorePath '/*'
