# FNM (Fast Node Manager) configuration

# Linux path
set -l FNM_PATH "$HOME/.local/share/fnm"
if test -d "$FNM_PATH"
    fish_add_path --path --append "$FNM_PATH"
    fnm env | source
end

# Enable directory-specific version switching
if type -q fnm
    fnm env --use-on-cd | source
end 