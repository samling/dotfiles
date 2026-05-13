# Initialize tools that need to inject fish code/completions.
# Guarded by `command -q` to keep startup cheap when a tool is missing.

# fnm
if test -d $HOME/.local/share/fnm
    fish_add_path -gP $HOME/.local/share/fnm
end
command -q fnm; and fnm env --use-on-cd --shell fish | source

# zoxide
command -q zoxide; and zoxide init fish --cmd cd | source

# direnv
command -q direnv; and direnv hook fish | source

# kubectl + kubecolor (alias-completion mirror)
command -q kubectl; and kubectl completion fish | source
command -q kubecolor; and complete -c kubecolor -w kubectl

# flux
command -q flux; and flux completion fish | source

# talos
command -q talosctl; and talosctl completion fish | source
command -q talhelper; and talhelper completion fish | source

# uv
command -q uv; and uv generate-shell-completion fish | source

# vkv
command -q vkv; and vkv completion fish | source

# zellij
command -q zellij; and zellij setup --generate-completion fish | source

# colima
command -q colima; and colima completion fish | source

# fx
command -q fx; and fx --comp fish | source

# vault: register with its built-in autocomplete
command -q vault; and complete -c vault -f -a '(commandline -ct | vault -autocomplete)'

# conda
if test -f $HOME/miniconda3/etc/fish/conf.d/conda.fish
    source $HOME/miniconda3/etc/fish/conf.d/conda.fish
else if test -x $HOME/miniconda3/bin/conda
    eval $HOME/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
