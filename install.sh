#!/bin/bash

set -e

# Check prereqs
echo -e "\nChecking requirements..."
CURR_SHELL=$(ps -p $$ | tail -n -1 | awk '{print $4}')
[ "${GITHUB_TOKEN}" ] && echo -e "  [✓] GITHUB_TOKEN is set" || (echo "  [x] GITHUB_TOKEN is not set" && exit 1)
[ "${CURR_SHELL}" == "zsh" ] && echo -e "  [✓] Current shell is ZSH" || (
	echo "  [x] ZSH is not installed or is not the current shell; installing ZSH. Please reboot after installation and rerun script"
	sudo apt-get install zsh
	chsh -s /usr/bin/zsh
)

if command -v make &>/dev/null; then
  echo -e "  [✓] Make is installed"
else
	echo "  [x] Make is not installed; installing make."
  sudo apt-get install make
fi

# Check if we're running as root; if not, elevate via sudo
sudo bash -c "echo -e '  [✓] We can use sudo'"
echo ""
echo ""

# Provision system
make -f ./Makefile
