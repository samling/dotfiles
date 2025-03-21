# History settings
set -g fish_history_file $HOME/.fish_history
set -g history_max_size 10000

# Don't show greeting on start
set -g fish_greeting ""

# Case-insensitive completion
set -g fish_complete_path case-insensitive

# Enable directory autocd
set -g fish_autocd 1

# Enable extended glob patterns
set -g fish_glob 1

# Don't exit on Ctrl-d
set -g fish_exit_on_eof 0