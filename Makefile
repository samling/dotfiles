LATEST_EXA 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/ogham/exa/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-x86_64-v")).value'`
LATEST_BAT 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_GRC 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/garabik/grc/releases/latest | jq -r '.zipball_url'`
LATEST_RG 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`

#################
#    TARGETS    #
#################

.PHONY: all
all: \
	preconfigure \
	install_tools \
	configure_vim \
	postconfigure

preconfigure: \
	install_prereqs \
	create_symlinks

install_tools: \
	install_exa \
	install_bat \
	install_grc \
	install_rg \
	install_fzf

configure_vim: \
	install_vundle \
	nvim_use_vimrc

postconfigure: \
	echo_final_steps

#################
#    PREREQS    #
#################

install_prereqs:
	@echo "Downloading prereqs"
	sudo apt update
	sudo apt install -y neovim tmux zsh jq

create_symlinks:
	@echo "Creating symlinks"
	ln -sf ${HOME}/dotfiles/zsh/.zshrc ${HOME}/.zshrc
	ln -sf ${HOME}/dotfiles/vim/.vim ${HOME}/.vim
	ln -sf ${HOME}/dotfiles/vim/.vimrc ${HOME}/.vimrc
	ln -sf ${HOME}/dotfiles/tmux/.tmux ${HOME}/.tmux
	ln -sf ${HOME}/dotfiles/tmux/.tmux.conf	${HOME}/.tmux.conf

#################
#     TOOLS     #
#################

install_exa:
	@echo "Installing exa"
	wget ${LATEST_EXA} -O /tmp/exa.zip
	unzip -d /tmp/exa -o /tmp/exa.zip
	sudo cp -f /tmp/exa/bin/exa /usr/local/bin/exa
	rm -rf /tmp/exa.zip /tmp/exa

install_bat:
	@echo "Installing bat"
	wget ${LATEST_BAT} -O /tmp/bat.deb
	sudo dpkg -i /tmp/bat.deb
	rm -rf /tmp/bat.deb

install_grc:
	@echo "Installing grc"
	wget ${LATEST_GRC} -O /tmp/grc.zip
	unzip -d /tmp/grc -o /tmp/grc.zip
	cd /tmp/grc/garabik*; sudo sh install.sh
	rm -rf /tmp/grc.zip /tmp/grc

install_rg:
	@echo "Installing rg"
	wget ${LATEST_RG} -O /tmp/rg.deb
	sudo dpkg -i /tmp/rg.deb
	rm -rf /tmp/rg.deb

install_fzf:
	@echo "Installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	${HOME}/.fzf/install --all

#################
#     NVIM      #
#################

define NVIM_INIT
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
endef
export NVIM_INIT
install_vundle:
	@echo "Installing Vundle"
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	@echo "Using .vimrc in nvim"
	mkdir -p ${HOME}/.config/nvim && touch ${HOME}/.config/nvim/init.vim
	echo "$$NVIM_INIT" > ${HOME}/.config/nvim/init.vim

#################
#      END      #
#################

define FINAL_STEPS
Done! Remember to do the following:
	1. chsh -s /usr/bin/zsh
	2. vim +PluginInstall +qall
endef
export FINAL_STEPS
echo_final_steps:
	@echo "$$FINAL_STEPS"