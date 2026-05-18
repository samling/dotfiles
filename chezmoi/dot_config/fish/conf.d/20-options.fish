# Fish-native equivalents of opt.zsh. Most zsh setopts (HIST_*, COMPLETE_*,
# PUSHD_*, GLOBBING) have no fish equivalent because fish does them natively
# (dedup history, share history across sessions, etc.).

set -g fish_greeting ""
set -g fish_history_max 100000

# Free Ctrl-S from terminal flow control so it can be a keybinding.
status is-interactive; and stty -ixon 2>/dev/null
