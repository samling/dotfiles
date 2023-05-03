#!/bin/bash

set -e

# Check prereqs
echo -e "\nChecking requirements..."
CURR_SHELL=$(ps -p $$ | tail -n -1 | awk '{print $4}')
[ "${GITHUB_TOKEN}" ] && echo -e "  [✓] GITHUB_TOKEN is set" || ( echo "  [x] GITHUB_TOKEN is not set" && exit 1 )
[ "${CURR_SHELL}" ]   && echo -e "  [✓] Current shell is ZSH" || ( echo "  [x] ZSH is not installed or is not the current shell; installing ZSH. Please reboot after installation and rerun script"; apt-get install zsh; chsh -s /usr/bin/zsh )

# Check if we're running as root; if not, elevate via sudo
sudo bash -c "echo -e '  [✓] We can use sudo'\n\n"

function prompt_for_nvchad() {
  if [[ -d "${HOME}/.config/nvim" ]]; then
    echo -e "nvchad is already installed; do you want to reinstall? (This will back up and replace your old installation.)"
    select yn in "Yes" "No"; do
      case $yn in
        Yes ) make -f ./Makefile configure_nvim; break;;
        No ) break;;
        * ) echo "Please answer yes or no."; break;;
      esac
    done
  fi
}
# Provision system
make -f ./Makefile preconfigure
make -f ./Makefile install_tools
make -f ./Makefile install_k8s_tools
make -f ./Makefile configure_tmux
prompt_for_nvchad
make -f ./Makefile postconfigure
