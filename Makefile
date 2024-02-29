LATEST_EZA 	    := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/eza-community/eza/releases/latest |  jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("_x86_64-unknown-linux-gnu.zip")).value'`
LATEST_BAT 	    := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_FD 	    := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|(contains("amd64.deb") and contains("musl")))'.value`
LATEST_ZOXIDE   := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`
LATEST_GRC 	    := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/garabik/grc/releases/latest | jq -r '.zipball_url'`
LATEST_NVIM     := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith("appimage")).value'`
LATEST_RG       := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("amd64.deb")).value'`
LATEST_VIDDY    := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/sachaos/viddy/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("Linux_x86_64")).value'`
LATEST_GITMUX   := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/arl/gitmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|contains("linux_amd64")).value'`
LATEST_LIBEVENT := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/libevent/libevent/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".tar.gz")).value'`
LATEST_NCURSES  := `curl -s https://invisible-mirror.net/archives/ncurses/current/ | sed -n 's/.*href="\([^"]*\).*/\1/p' | grep ncurses | tail -n +2 | head -n 1 | xargs -I {} echo https://invisible-mirror.net/archives/ncurses/current/{}`
LATEST_TMUX     := `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/tmux/tmux/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")).value'`
LATEST_JC     	:= `curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/repos/kellyjonbrazil/jc/releases/latest | jq -r '.assets[] | to_entries[] | select(.key|startswith("browser_download_url")) | select(.value|endswith(".deb")).value'`
LATEST_KUBECTL  := `curl -L -s https://dl.k8s.io/release/stable.txt`

#################
#    TARGETS    #
#################

.PHONY: all
all: \
	preconfigure \
	install_tools \
	install_k8s_tools \
	configure_zsh \
	configure_tmux \
	configure_nvim \
	postconfigure

preconfigure: \
	install_prereqs \
	create_symlinks
	#create_folders \

install_apps: \
	install_google_chrome

install_tools: \
	install_kitty \
	install_eza \
	install_bat \
	install_fd \
	install_zoxide \
	install_grc \
	install_rg \
	install_fzf \
	install_viddy \
	install_gitmux \
	install_tmux \
	install_nvim \
	install_jc

install_k8s_tools: \
	install_kubectl \
	install_krew \
	install_krew_plugins

configure_nvim: \
	cleanup_nvim_state \
	install_nvim_conf

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
		zsh \
		jq \
		curl \
		unzip \
		p7zip \
		autotools-dev \
		automake \
		gcc \
		bison \
		flex \
		evolution \
		libevent-core-2.1-7 xclip \
		smbclient \
		dialog \
		xdotool
		# guake

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
	ln -sf ${HOME}/dotfiles/kitty/kitty.conf ${HOME}/.config/kitty/kitty.conf

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
	git clone https://github.com/dexpota/kitty-themes.git ~/.config/kitty/kitty-themes/
	ln -sf ~/dotfiles/kitty/theme.conf ~/.config/kitty/theme.conf

install_eza:
	@echo "Installing eza"
	wget ${LATEST_EZA} -O /tmp/eza.zip
	unzip -d /tmp/eza -o /tmp/eza.zip
	sudo cp -f /tmp/eza/eza /usr/local/eza
	rm -rf /tmp/eza.zip /tmp/eza

install_fd:
	@echo "Installing fd"
	wget ${LATEST_FD} -O /tmp/fd.deb
	sudo dpkg -i /tmp/fd.deb
	rm -rf /tmp/fd.deb

install_bat:
	@echo "Installing bat"
	wget ${LATEST_BAT} -O /tmp/bat.deb
	sudo dpkg -i /tmp/bat.deb
	rm -rf /tmp/bat.deb

install_zoxide:
	@echo "Installing zoxide"
	wget ${LATEST_ZOXIDE} -O /tmp/zoxide.deb
	sudo dpkg -i /tmp/zoxide.deb
	rm -rf /tmp/zoxide.deb

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

install_jc:
	@echo "Installing jc"
	wget ${LATEST_JC} -O /tmp/jc.deb
	sudo dpkg -i /tmp/jc.deb
	rm -rf /tmp/jc.deb

install_fzf:
	@echo "Installing fzf"
	rm -rf ${HOME}/.fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
	${HOME}/.fzf/install --all

install_tdrop:
	@echo "Installing tdrop"
	rm -rf ${HOME}/Downloads/tdrop
	git clone https://github.com/noctuid/tdrop.git ${HOME}/Downloads/tdrop
	cd ${HOME}/Downloads/tdrop && sudo make install

install_viddy:
	@echo "Installing viddy"
	wget ${LATEST_VIDDY} -O /tmp/viddy.tar.gz
	mkdir -p /tmp/viddy
	tar xzvf /tmp/viddy.tar.gz -C /tmp/viddy
	sudo cp -f /tmp/viddy/viddy /usr/local/bin/viddy
	rm -rf /tmp/viddy.tar.gz /tmp/viddy

install_gitmux:
	@echo "Installing gitmux"
	wget ${LATEST_GITMUX} -O /tmp/gitmux.tar.gz
	mkdir -p /tmp/gitmux
	tar xzvf /tmp/gitmux.tar.gz -C /tmp/gitmux
	sudo cp -f /tmp/gitmux/gitmux /usr/local/bin/gitmux
	rm -rf /tmp/gitmux.tar.gz /tmp/gitmux

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
	PATH="${PATH}:${HOME}/.krew/bin" kubectl krew install ns ctx neat sniff konfig stern resource-capacity

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
#      END      #
#################

define FINAL_STEPS
Done! Remember to do the following:
	1. Create a new shortcut to open kitty: `tdrop kitty --start-as fullscreen`
	2. Run neovim to finish LazyVim configuration
	3. Install tmux plugins with ctrl-A + I
	4. (Optional) Reboot!
endef
export FINAL_STEPS
echo_final_steps:
	@echo "$$FINAL_STEPS"
