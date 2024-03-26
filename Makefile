LATEST_BAT			:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_BTOP     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/aristocratos/btop/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("x86_64-linux-musl.tbz")).value'`
LATEST_EZA 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/eza-community/eza/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("_x86_64-unknown-linux-gnu.zip")).value'`
LATEST_FD 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_GITMUX   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/arl/gitmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux_amd64")).value'`
LATEST_GRC 	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/garabik/grc/releases/latest | jq -r '.zipball_url'`
LATEST_KUBECTL  	:= `curl -L -s https://dl.k8s.io/release/stable.txt`
LATEST_LAZYGIT		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'`
LATEST_LIBEVENT 	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/libevent/libevent/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".tar.gz")).value'`
LATEST_LSD      	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/lsd-rs/lsd/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_NCURSES  	:= `curl -s https://invisible-mirror.net/archives/ncurses/current/ | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep ncurses | tail -n +2 | head -n 1 | xargs -I {} echo https://invisible-mirror.net/archives/ncurses/current/{}`
LATEST_NVM      	:= `curl -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.name'`
LATEST_NVIM     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("appimage")).value'`
LATEST_RG       	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`
LATEST_TERRAGRUNT	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("_linux_amd64")).value'`
LATEST_TMUX			:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/tmux/tmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")).value'`
LATEST_VENDIR    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/carvel-dev/vendir/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-amd64")).value'`
LATEST_VIDDY    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sachaos/viddy/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("Linux_x86_64")).value'`
LATEST_YTT	    	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/carvel-dev/ytt/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux-amd64")).value'`
LATEST_ZOXIDE   	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`
LATEST_JC     		:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/kellyjonbrazil/jc/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".deb")).value'`


#################
#    TARGETS    #
#################

.PHONY: all
all: \
	preconfigure \
	install_tools \
	configure \
	postconfigure

configure: \
	configure_kitty \
	configure_zsh \
	configure_tmux \
	configure_nvm \
	configure_nvim \
	configure_pyenv

preconfigure: \
	install_prereqs \
	create_folders \
	create_symlinks

install_apps: \
	install_google_chrome

install_tools: \
	install_common_tools \
	install_carvel_tools \
	install_cloud_tools \
	install_k8s_tools \
	install_terraform_tools \
	install_tmux_tools

install_cloud_tools: \
	install_aws \
	install_az

install_common_tools: \
	install_bat \
	install_btop \
	install_fd \
	install_fzf \
	install_grc \
	install_jc \
	install_kitty \
	install_lazygit \
	install_lsd \
	install_nvm \
	install_nvim \
	install_pyenv \
	install_rg \
	install_tdrop \
	install_viddy \
	install_zoxide

install_carvel_tools: \
	install_vendir \
	install_ytt

install_k8s_tools: \
	install_kubectl \
	install_krew \
	install_krew_plugins

install_terraform_tools: \
	install_terraform \
	install_terragrunt

install_tmux_tools: \
	install_tmux \
	install_gitmux

configure_kitty: \
	install_kitty_themes

configure_nvm: \
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
	install_zsh_pure

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
		libncurses5 \
		libncurses5-dev \
		libncursesw5 \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxmlsec1-dev \
		llvm \
		p7zip \
		smbclient \
		software-properties-common \
		tk-dev \
		unzip \
		xclip \
		xdotool \
		xz-utils \
		zlib1g-dev \
		zsh

create_folders:
	@echo "Creating required folders"
	#mkdir -p ${HOME}/.config/nvim/lua/custom
	mkdir -p ${HOME}/.config/kitty

create_symlinks:
	@echo "Creating symlinks"
	ln -sf ${HOME}/dotfiles/zsh/.zshrc ${HOME}/.zshrc
	#ln -sf ${HOME}/dotfiles/vim/.vim ${HOME}/.vim
	# TODO: Try just symlinking to ${HOME}
	#rm -f ${HOME}/dotfiles/vim/.vim/.vim
	#ln -sf ${HOME}/dotfiles/vim/.vimrc ${HOME}/.vimrc
	ln -sf ${HOME}/dotfiles/tmux/.tmux ${HOME}/.tmux
	rm -f ${HOME}/dotfiles/tmux/.tmux/.tmux
	ln -sf ${HOME}/dotfiles/tmux/.tmux.conf	${HOME}/.tmux.conf
	ln -sf ${HOME}/dotfiles/tmux/.gitmux.conf	${HOME}/.gitmux.conf
	ln -sf ${HOME}/dotfiles/config/linux/kitty/kitty.conf ${HOME}/.config/kitty/kitty.conf
	ln -sf ${HOME}/dotfiles/config/linux/kitty/theme.conf ${HOME}/.config/kitty/theme.conf

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

install_aws:
	@echo "Installing aws"
	wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O /tmp/awscliv2.zip
	unzip -od /tmp /tmp/awscliv2.zip
	(cd /tmp/aws && sudo ./install)

install_az:
	@echo "Installing az"
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

install_bat:
	@echo "Installing bat"
	wget ${LATEST_BAT} -O /tmp/bat.deb
	sudo dpkg -i /tmp/bat.deb
	rm -rf /tmp/bat.deb

install_btop:
	@echo "Installing btop"
	wget ${LATEST_BTOP} -O /tmp/btop.tbz
	mkdir -p /tmp/btop
	tar xjf /tmp/btop.tbz -C /tmp/btop
	cd /tmp/btop/btop/ && sudo make install
	rm -rf /tmp/btop.tbz /tmp/btop

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
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin
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
	curl https://pyenv.run | bash

install_rg:
	@echo "Installing rg"
	wget ${LATEST_RG} -O /tmp/rg.deb
	sudo dpkg -i /tmp/rg.deb
	rm -rf /tmp/rg.deb

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
	@echo "Installing prereq: ncurses"
	wget ${LATEST_NCURSES} -O /tmp/ncurses.tar.gz
	mkdir -p /tmp/ncurses
	tar xzvf /tmp/ncurses.tar.gz -C /tmp/ncurses
	cd /tmp/ncurses/ncurses*; sh configure && make && sudo make install
	rm -rf /tmp/ncurses.tar.gz /tmp/ncurses
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

install_ytt:
	@echo "Installing ytt"
	wget ${LATEST_YTT} -O /tmp/ytt
	sudo mv /tmp/ytt /usr/local/bin && chmod +x /usr/local/bin/ytt

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

install_krew_plugins:
	@echo "Installing krew plugins"
	PATH="${PATH}:${HOME}/.krew/bin" kubectl krew install ns ctx neat sniff konfig stern resource-capacity tree

#################
#     NPM      #
#################
install_npm:
	@echo "Installing latest npm"
	. ${HOME}/.nvm/nvm.sh && \
	nvm install stable

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
	pyenv install -f 3.10

#################
#      END      #
#################

define FINAL_STEPS
Done! Remember to do the following:
	1. Create a new shortcut to open kitty: `tdrop -a -s 0 kitty --start-as fullscreen`
	2. Run neovim to finish LazyVim configuration
	3. Install tmux plugins with ctrl-A + I
	4. (Optional) Reboot!
endef
export FINAL_STEPS
echo_final_steps:
	@echo "$$FINAL_STEPS"
