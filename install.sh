#!/usr/bin/env bash

current_shell=$(ps -p $$ -o comm=)
if [[ "$current_shell" != *"zsh"* ]] && command -v zsh >/dev/null 2>&1; then
    # This will reexecute the script inside zsh; the following elif statement will then run if this is true
    exec zsh "$0" "$@"
elif [[ "$current_shell" == *"zsh"* ]]; then
    echo "zsh is available; continuing with zsh"
fi

set -e

# Check prereqs
echo -e "\nChecking requirements..."
CURR_SHELL=$(ps -p $$ -o comm= | sed 's/^-//')
[ "${GITHUB_TOKEN}" ] && echo -e "  [✓] GITHUB_TOKEN is set" || (echo "  [x] GITHUB_TOKEN is not set" && exit 1)
[[ "${CURR_SHELL}" == "zsh" ]] && echo -e "  [✓] Current shell is ZSH" || (
        echo "  [x] ZSH is not installed or is not the current shell. Please install zsh and rerun script"
        exit 1
)

if command -v make &>/dev/null; then
  echo -e "  [✓] Make is installed"
else
        echo "  [x] Make is not installed."
        exit 1
fi

# Check if we're running as root; if not, elevate via sudo
sudo bash -c "echo -e '  [✓] We can use sudo'"
echo ""
echo ""

# Provision system
ARCH=$(uname -s)
MAKEFILE="Makefile"
if [[ $ARCH == "Darwin" ]]; then
  MAKEFILE="Makefile.darwin"
fi

make -f ${MAKEFILE}
