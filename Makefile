LATEST_AICHAT		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sigoden/aichat/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("x86_64-unknown-linux-musl.tar.gz"))'.value`
LATEST_BAT		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and (contains("musl") | not)))'.value`
LATEST_BTOP     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/aristocratos/btop/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("x86_64-linux-musl.tbz")).value'`
LATEST_DELTA 	   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/dandavison/delta/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("_amd64.deb")).value'`
LATEST_DUF  	   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/muesli/duf/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("_amd64.deb")).value'`
LATEST_EZA 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/eza-community/eza/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("_linux_amd64.deb")).value'`
LATEST_FD 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_GITMUX   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/arl/gitmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux_amd64")).value'`
LATEST_GO		:= `curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version'`
LATEST_GRC 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/garabik/grc/releases/latest | jq -r '.zipball_url'`
LATEST_HELM     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name'`
LATEST_JC     		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/kellyjonbrazil/jc/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".deb")).value'`
LATEST_K9s		:= `curl -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux_amd64.deb")).value'`
LATEST_KUBECTL  	:= `curl -L -s https://dl.k8s.io/release/stable.txt`
LATEST_LAZYGIT		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'`
LATEST_LIBEVENT 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/libevent/libevent/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".tar.gz")).value'`
LATEST_LSD      	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/lsd-rs/lsd/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_NVM      	:= `curl -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.name'`
LATEST_NVIM     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("linux-x86_64.appimage")).value'`
LATEST_RG       	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`
LATEST_TEALDEER		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/tealdeer-rs/tealdeer/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("-linux-x86_64-musl")).value'`
LATEST_TERRAGRUNT	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("_linux_amd64")).value'`
LATEST_TMUX		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/tmux/tmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")).value'`
LATEST_VENDIR    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/carvel-dev/vendir/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-amd64")).value'`
LATEST_VIDDY    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sachaos/viddy/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-x86_64.tar.gz")).value'`
LATEST_VKV		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/FalcoSuessgott/vkv/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("linux_amd64.deb")).value'`
LATEST_YTT	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/carvel-dev/ytt/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-amd64")).value'`
LATEST_ZELLIJ   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/zellij-org/zellij/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("x86_64-unknown-linux-musl.tar.gz")).value'`
LATEST_ZOXIDE   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`

#####################
#    ENVIRONMENT    #
#####################

SHELL := /bin/bash

#################
#    TARGETS    #
#################

.PHONY: all
all: \
	preconfigure \
	install_tools \
	configure \
	postconfigure

preconfigure: \
	install_prereqs \
	create_folders \
	create_files \
	create_symlinks \
	configure_locale

install_tools: \
	install_common_tools \
	install_carvel_tools \
	install_cloud_tools \
	install_k8s_tools \
	install_terraform_tools \
	install_tmux_tools

install_apps: \
	install_google_chrome

install_cloud_tools: \
	install_aws \
	install_az

install_common_tools: \
	install_aichat \
	install_bat \
	install_btop \
	install_delta \
	install_duf \
	install_fd \
	install_fzf \
	install_grc \
	install_helm \
	install_jc \
	install_kitty \
	install_lazygit \
	install_lsd \
	install_nvim \
	install_pyenv \
	install_rg \
	install_tealdeer \
	install_viddy \
	install_vkv \
	install_zoxide

install_carvel_tools: \
	install_vendir \
	install_ytt

install_k8s_tools: \
	install_kubectl \
	install_krew \
	add_krew_index \
	install_krew_plugins

install_terraform_tools: \
	install_terraform \
	install_terragrunt

install_tmux_tools: \
	install_tmux \
	install_gitmux

configure: \
	configure_kitty \
	configure_zsh \
	configure_tmux \
	configure_npm \
	configure_nvim \
	configure_pyenv

configure_kitty: \
	install_kitty_themes

configure_npm: \
	install_fnm \
	install_npm

configure_nvim: \
	cleanup_nvim_state \
	install_nvim_conf

configure_pyenv: \
	install_python310

configure_vim: \
	install_vundle \
	install_vundle_plugins

configure_tmux: \
	install_tmux_tpm

configure_zsh: \
	install_gitstatus \
	install_zsh_pure \
	install_zsh_plugins

postconfigure: \
	echo_final_steps

#################
#    PREREQS    #
#################

install_prereqs:
	@echo "Downloading prereqs"
	sudo apt update
	sudo apt install -y \
		autotools-dev \
		automake \
		bison \
		build-essential \
		curl \
		dialog \
		direnv \
		gcc \
		gnupg \
		flex \
		evolution \
		jq \
		libevent-core-2.1-7 \
		libbz2-dev \
		libffi-dev \
		libfuse2 \
		liblzma-dev \
		libncurses6 \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxmlsec1-dev \
		llvm \
		locales \
		nmap \
		p7zip \
		rename \
		smbclient \
		software-properties-common \
		telnet \
		traceroute \
		tk-dev \
		unzip \
		xclip \
		xdotool \
		xz-utils \
		zlib1g-dev \
		zsh
		#libncursesw6 \
		#libncursesw6-dev \
		#libncurses6-dev \

create_folders:
	@echo "Creating required folders"
	mkdir -p ${HOME}/.config
	mkdir -p ${HOME}/.config/bat
	mkdir -p ${HOME}/.config/ghostty
	mkdir -p ${HOME}/.config/kitty
	mkdir -p ${HOME}/.config/lsd
	mkdir -p ${HOME}/.kube/kubeconfigs
	mkdir -p ${HOME}/.local/bin
	mkdir -p ${HOME}/.tmux-continuum-sessions

create_files:
	@echo "Creating required files and stubs"
	touch ${HOME}/.kube/config

create_symlinks:
	@echo "Creating symlinks"
	ln -sf ${HOME}/dotfiles/zsh/.zshrc ${HOME}/.zshrc
	ln -sf ${HOME}/dotfiles/tmux/.tmux ${HOME}/.tmux
	rm -f ${HOME}/dotfiles/tmux/.tmux/.tmux
	ln -sf ${HOME}/dotfiles/tmux/.tmux.conf	${HOME}/.tmux.conf
	ln -sf ${HOME}/dotfiles/tmux/.gitmux.conf	${HOME}/.gitmux.conf
	ln -sf ${HOME}/dotfiles/linux/config/bat/themes ${HOME}/.config/bat
	ln -sf ${HOME}/dotfiles/linux/config/git/gitconfig ${HOME}/.gitconfig
	ln -sf ${HOME}/dotfiles/linux/config/ghostty/themes ${HOME}/.config/ghostty
	ln -sf ${HOME}/dotfiles/linux/config/ghostty/config ${HOME}/.config/ghostty
	ln -sf ${HOME}/dotfiles/linux/config/kitty/kitty.conf ${HOME}/.config/kitty/kitty.conf
	ln -sf ${HOME}/dotfiles/linux/config/kitty/theme.conf ${HOME}/.config/kitty/theme.conf
	ln -sf ${HOME}/dotfiles/linux/config/lsd/config.yaml ${HOME}/.config/lsd/config.yaml
	ln -sf ${HOME}/dotfiles/linux/config/lsd/icons.yaml ${HOME}/.config/lsd/icons.yaml
	ln -sf ${HOME}/dotfiles/linux/config/lsd/colors.yaml ${HOME}/.config/lsd/colors.yaml
	ln -sf ${HOME}/dotfiles/linux/config/ripgrep/.ripgreprc	${HOME}
	ln -sf ${HOME}/dotfiles/linux/config/starship/starship.toml ${HOME}/.config/starship.toml

configure_locale:
	@echo "Configuring locale"
	sudo locale-gen en_US.UTF-8
	sudo locale-gen en_US.ISO-8859-15

################
#     APPS     #
################

install_google_chrome:
	@echo "Installing Google Chrome"
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
	sudo dpkg -i /tmp/google-chrome.deb
	rm -rf /tmp/google-chrome.deb
	
#################
#     TOOLS     #
#################

install_aichat:
	@echo "Installing aichat"
	wget ${LATEST_AICHAT} -O /tmp/aichat.tar.gz
	mkdir -p /tmp/aichat
	tar xzvf /tmp/aichat.tar.gz -C /tmp/aichat
	sudo cp -f /tmp/aichat/aichat /usr/local/bin/aichat
	rm -rf /tmp/aichat.tar.gz /tmp/aichat

install_aws:
	@echo "Installing aws"
	wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O /tmp/awscliv2.zip
	unzip -od /tmp /tmp/awscliv2.zip
	(cd /tmp/aws && sudo ./install --update)

install_az:
	@echo "Installing az"
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

install_bat:
	@echo "Installing bat"
	wget ${LATEST_BAT} -O /tmp/bat.deb
	sudo dpkg -i /tmp/bat.deb
	rm -rf /tmp/bat.deb
	@echo "Configuring bat themes"
	bat cache --build

install_btop:
	@echo "Installing btop"
	wget ${LATEST_BTOP} -O /tmp/btop.tbz
	mkdir -p /tmp/btop
	tar xjf /tmp/btop.tbz -C /tmp/btop
	cd /tmp/btop/btop/ && sudo make install
	rm -rf /tmp/btop.tbz /tmp/btop

install_delta:
	@echo "Installing delta"
	wget ${LATEST_DELTA} -O /tmp/delta.deb
	sudo dpkg -i /tmp/delta.deb
	rm -rf /tmp/delta.deb

install_duf:
	@echo "Installing duf"
	wget ${LATEST_DUF} -O /tmp/duf.deb
	sudo dpkg -i /tmp/duf.deb
	rm -rf /tmp/duf.deb

install_fd:
	@echo "Installing fd"
	wget ${LATEST_FD} -O /tmp/fd.deb
	sudo dpkg -i /tmp/fd.deb
	rm -rf /tmp/fd.deb

install_eza:
	@echo "Installing eza"
	wget ${LATEST_EZA} -O /tmp/eza.zip
	unzip -d /tmp/eza -o /tmp/eza.zip
	sudo cp -f /tmp/eza/eza /usr/local/eza
	rm -rf /tmp/eza.zip /tmp/eza

install_fzf:
	@echo "Installing fzf"
	rm -rf ${HOME}/.fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	${HOME}/.fzf/install --all

install_grc:
	@echo "Installing grc"
	wget ${LATEST_GRC} -O /tmp/grc.zip
	unzip -d /tmp/grc -o /tmp/grc.zip
	cd /tmp/grc/garabik*; sudo sh install.sh
	rm -rf /tmp/grc.zip /tmp/grc

install_gitmux:
	@echo "Installing gitmux"
	wget ${LATEST_GITMUX} -O /tmp/gitmux.tar.gz
	mkdir -p /tmp/gitmux
	tar xzvf /tmp/gitmux.tar.gz -C /tmp/gitmux
	sudo cp -f /tmp/gitmux/gitmux /usr/local/bin/gitmux
	rm -rf /tmp/gitmux.tar.gz /tmp/gitmux

install_go:
	@echo "Installing go"
	wget https://go.dev/dl/${LATEST_GO}.linux-amd64.tar.gz -O /tmp/go.tar.gz
	mkdir -p /tmp/go
	tar xzvf /tmp/go.tar.gz -C /tmp/go
	sudo cp -r /tmp/go/go /usr/local
	rm -rf /tmp/go.tar.gz /tmp/go

install_helm:
	@echo "Installing helm"
	wget "https://get.helm.sh/helm-${LATEST_HELM}-linux-amd64.tar.gz" -O /tmp/helm.tar.gz
	mkdir -p /tmp/helm
	tar xzvf /tmp/helm.tar.gz -C /tmp/helm
	sudo cp -f /tmp/helm/linux-amd64/helm /usr/local/bin/helm
	rm -rf /tmp/helm.tar.gz /tmp/helm

install_jc:
	@echo "Installing jc"
	wget ${LATEST_JC} -O /tmp/jc.deb
	sudo dpkg -i /tmp/jc.deb
	rm -rf /tmp/jc.deb

install_kitty:
	@echo "Installing kitty"
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
	@echo "Creating application launcher"
	mkdir -p ~/.local/share/applications
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop
	
install_kitty_themes:
	@echo "Installing kitty themes"
	if [ ! -d ~/.config/kitty/kitty-themes ]; then git clone https://github.com/dexpota/kitty-themes.git ~/.config/kitty/kitty-themes/; fi
	ln -sf ~/dotfiles/kitty/theme.conf ~/.config/kitty/theme.conf

install_lazygit:
	@echo "Installing lazygit"
	curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LATEST_LAZYGIT}_Linux_x86_64.tar.gz"
	mkdir -p /tmp/lazygit
	tar xzvf /tmp/lazygit.tar.gz -C /tmp/lazygit
	sudo mv /tmp/lazygit/lazygit /usr/local/bin
	rm -rf /tmp/lazygit /tmp/lazygit.tar.gz

install_lsd:
	@echo "Installing lsd"
	wget ${LATEST_LSD} -O /tmp/lsd.deb
	sudo dpkg -i /tmp/lsd.deb
	rm -rf /tmp/lsd.deb

install_nvm:
	@echo "Installing nvm"
	(unset ZSH_VERSION && curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${LATEST_NVM}/install.sh" | bash)

install_pyenv:
	@echo "Installing pyenv"
	rm -rf ${HOME}/.pyenv
	curl https://pyenv.run | bash

install_rg:
	@echo "Installing rg"
	wget ${LATEST_RG} -O /tmp/rg.deb
	sudo dpkg -i /tmp/rg.deb
	rm -rf /tmp/rg.deb

install_starship:
	@echo "Installing starship"
	(unset ZSH_VERSION && curl -sS https://starship.rs/install.sh | sh)

install_tealdeer:
	@echo "Installing tealdeer"
	wget ${LATEST_TEALDEER} -O /tmp/tealdeer
	sudo mv /tmp/tealdeer /usr/local/bin && chmod +x /usr/local/bin/tealdeer

install_terraform:
	@echo "Installing terraform"
	wget -O- https://apt.releases.hashicorp.com/gpg | \
		gpg --dearmor | \
		sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
	gpg --no-default-keyring \
		--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
		--fingerprint
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update
	sudo apt-get install terraform

install_terragrunt:
	@echo "Installing terragrunt"
	wget ${LATEST_TERRAGRUNT} -O /tmp/terragrunt
	sudo mv /tmp/terragrunt /usr/local/bin && chmod +x /usr/local/bin/terragrunt

install_tdrop:
	@echo "Installing tdrop"
	git clone https://github.com/noctuid/tdrop.git /tmp/tdrop
	cd /tmp/tdrop && sudo make install
	rm -rf /tmp/tdrop

install_tmux:
	@echo "Installing tmux"
	@echo "Installing prereq: libevent"
	wget ${LATEST_LIBEVENT} -O /tmp/libevent.tar.gz
	mkdir -p /tmp/libevent
	tar xzvf /tmp/libevent.tar.gz -C /tmp/libevent
	cd /tmp/libevent/libevent*; sh configure --disable-openssl && make && sudo make install
	rm -rf /tmp/libevent.tar.gz /tmp/libevent
	@echo "Installing tmux"
	wget ${LATEST_TMUX} -O /tmp/tmux.tar.gz
	mkdir -p /tmp/tmux
	tar xzvf /tmp/tmux.tar.gz -C /tmp/tmux
	cd /tmp/tmux/tmux*; sh configure && make && sudo make install
	rm -rf /tmp/tmux.tar.gz /tmp/tmux

install_vendir:
	@echo "Installing vendir"
	wget ${LATEST_VENDIR} -O /tmp/vendir
	sudo mv /tmp/vendir /usr/local/bin && chmod +x /usr/local/bin/vendir

install_viddy:
	@echo "Installing viddy"
	wget ${LATEST_VIDDY} -O /tmp/viddy.tar.gz
	mkdir -p /tmp/viddy
	tar xzvf /tmp/viddy.tar.gz -C /tmp/viddy
	sudo cp -f /tmp/viddy/viddy /usr/local/bin/viddy
	rm -rf /tmp/viddy.tar.gz /tmp/viddy

install_vkv:
	@echo "Installing vkv"
	wget ${LATEST_VKV} -O /tmp/vkv.deb
	sudo dpkg -i /tmp/vkv.deb
	rm /tmp/vkv.deb

install_ytt:
	@echo "Installing ytt"
	wget ${LATEST_YTT} -O /tmp/ytt
	sudo mv /tmp/ytt /usr/local/bin && chmod +x /usr/local/bin/ytt

install_zellij:
	@echo "Installing zellij"
	wget ${LATEST_ZELLIJ} -O /tmp/zellij.tar.gz
	mkdir -p /tmp/zellij
	tar xzvf /tmp/zellij.tar.gz -C /tmp/zellij
	sudo cp -f /tmp/zellij/zellij /usr/local/bin/zellij
	rm -rf /tmp/zellij.tar.gz /tmp/zellij

install_zoxide:
	@echo "Installing zoxide"
	wget ${LATEST_ZOXIDE} -O /tmp/zoxide.deb
	sudo dpkg -i /tmp/zoxide.deb
	rm -rf /tmp/zoxide.deb

################
# TMUX PLUGINS #
################

install_tmux_tpm:
	@echo "Installing tpm"
	if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm; else echo "tpm is already installed; skipping..."; fi

###############
# ZSH PLUGINS #
###############

install_gitstatus:
	@echo "Installing gitstatus"
	if [ ! -d "${HOME}/dotfiles/zsh/gitstatus" ] || [ -n "$(find "$HOME/dotfiles/zsh/gitstatus" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then git clone --depth=1 https://github.com/romkatv/gitstatus.git "${HOME}/dotfiles/zsh/gitstatus"; else echo "Gitstatus already cloned"; fi

install_zsh_pure:
	@echo "Installing zsh pure prompt"
	if [ ! -d "${HOME}/dotfiles/zsh/pure" ] || [ -n "$(find "$HOME/dotfiles/zsh/pure" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then git clone https://github.com/sindresorhus/pure.git "${HOME}/dotfiles/zsh/pure"; else echo "Zsh Pure already cloned"; fi

install_zsh_plugins:
	@echo "Installing zsh plugins"
	@echo "  Installing zsh-syntax-highlighting"
	if [ ! -d "${HOME}/dotfiles/zsh/plugins/zsh-syntax-highlighting" ] || [ -n "$(find "$HOME/dotfiles/zsh/plugins/zsh-syntax-highlighting" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/dotfiles/zsh/plugins/zsh-syntax-highlighting"; else echo "Zsh Syntax Highlighting already cloned"; fi
	# @echo "  Installing zsh-autosuggestions"
	# if [ ! -d "${HOME}/dotfiles/zsh/plugins/zsh-autosuggestions" ] || [ -n "$(find "$HOME/dotfiles/zsh/plugins/zsh-autosuggestions" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then git clone https://github.com/zsh-users/zsh-autosuggestions.git "${HOME}/dotfiles/zsh/plugins/zsh-autosuggestions"; else echo "Zsh Syntax Highlighting already cloned"; fi

#################
#   K8S-TOOLS   #
#################

install_kubectl:
	@echo "Installing kubectl"
	cd /tmp && { curl -LO "https://dl.k8s.io/release/${LATEST_KUBECTL}/bin/linux/amd64/kubectl"; cd -; }
	sudo mv /tmp/kubectl /usr/local/bin/kubectl
	sudo chmod +x /usr/local/bin/kubectl

install_krew:
	@echo "Installing krew"
	set -x; cd "$$(mktemp -d)" && \
	OS="$$(uname | tr '[:upper:]' '[:lower:]')" && \
	ARCH="$$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$$/arm64/')" && \
	KREW="krew-$${OS}_$${ARCH}" && \
	curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/$${KREW}.tar.gz" && \
	tar zxvf "$${KREW}.tar.gz" && \
	./"$${KREW}" install krew

add_krew_index:
	@echo "Adding Krew index"
	PATH="${PATH}:${HOME}/.krew/bin" kubectl krew index add kubectl-ai https://github.com/sozercan/kubectl-ai

install_krew_plugins:
	@echo "Installing krew plugins"
	PATH="${PATH}:${HOME}/.krew/bin" kubectl krew install ns ctx neat sniff konfig stern resource-capacity tree ktop

install_k9s:
	@echo "Installing k9s"
	wget ${LATEST_K9s} -O /tmp/k9s.deb
	sudo dpkg -i /tmp/k9s.deb
	rm /tmp/k9s.deb

#################
#     NPM      #
#################
install_fnm:
	@echo "Installing fnm"
	curl -fsSL https://fnm.vercel.app/install | bash

install_npm:
	@echo "Installing latest npm"
	fnm install --lts

#################
#     NVIM      #
#################

install_nvim:
	@echo "Removing any previous neovim installations"
	yes | sudo apt remove neovim neovim-runtime
	@echo "Installing neovim"
	wget ${LATEST_NVIM} -O /tmp/nvim.appimage
	chmod +x /tmp/nvim.appimage && sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

cleanup_nvim_state:
	@echo "Cleaning up old lazyvim state"
	rm -rf "${HOME}/.local/share/nvim/lazy"
	rm -rf "${HOME}/.local/state/nvim/lazy"
	rm -f "${HOME}/.config/nvim/lazy-lock.json"

install_nvim_conf:
	@echo ""
	current_dt=$(date '+%d-%m-%Y_%H-%M-%S')
	if [ -d "${HOME}/.config/nvim" ]; then mv ${HOME}/.config/nvim ${HOME}/.config/nvim.old.${current_dt}; fi
	ln -sf ${HOME}/dotfiles/nvim ${HOME}/.config/nvim

#################
#     PYENV    #
#################
install_python310:
	@echo "Installing latest python3 with pyenv"
	[[ -d ${HOME}/.pyenv/bin ]] && PATH="${HOME}/.pyenv/bin:${PATH}" pyenv install -f 3.10

#################
#      END      #
#################

define FINAL_STEPS
Done! Remember to do the following:
	1. Run neovim to finish LazyVim configuration
	2. Install tmux plugins with ctrl-A + I
	3. Make sure bat cache is built: bat cache --build
	4. (Optional) Reboot!
endef
export FINAL_STEPS
echo_final_steps:
	@echo "$$FINAL_STEPS"
