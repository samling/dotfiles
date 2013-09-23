#!/bin/bash

# Functions

function check_for_zsh {
	if ! type zsh > /dev/null
			then
				echo "zsh is not installed on this system; attempting to install"
				echo ""
				if [ -f /etc/lsb-release ]
				then
					echo "OS: $(lsb_release -s -d)"
					sudo apt-get install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/debian_version ]
				then
					echo "OS: $(cat /etc/debian_version)"
					sudo apt-get install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/redhat-release ]
				then
					echo "OS: $(cat /etc/redhat-release)"
					sudo yum install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/arch-release ]
				then
					echo "OS: $(cat /etc/arch-release)"
					sudo pacman -S zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/SuSE-release ]
				then
					echo "OS: $(cat /etc/SuSE-release)"
			       		sudo zypper in zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				else
					echo "Distribution not recognized! Please install zsh and run this script again."
				fi
			else
				echo "zsh is already installed!"
				echo ""
				echo "Changing shell to zsh..."
				chsh -s $(which zsh)
				echo ""
				echo "Setting up oh-my-zsh..." &&
				install_oh_my_zsh
			fi
		}

function install_oh_my_zsh {
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Moving to directory /root"
					cd /root
					echo ""
					echo "Cloning into /root"
					echo ""
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh &&
					echo ""
					echo ""
				else
					echo "Moving to directory /home/$currentuser"
					cd /home/$currentuser
					echo ""
					echo "Cloning into /home/$currentuser"
					echo ""
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh &&
					echo ""
					echo ""
				fi
				unset currentuser
			}

function oh_my_zsh_customize {
                echo "Customizing zsh..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .zshrc into /$currentuser..."
					if [ -f /root/.zshrc ]
					then
						mv /root/.zshrc /root/.zshrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /root/dotfiles/zsh/.zshrc /root
					else
						ln -s /root/dotfiles/zsh/.zshrc /root
					fi

					echo "Cloning clean-check and custom themes into /$currentuser/.oh-my-zsh/themes..."
					if [ -f /root/.oh-my-zsh/themes/clean-check.zsh-theme ] || [ -f /root/.oh-my-zsh/themes/custom.zsh-theme ]
					then
						mv /root/.oh-my-zsh/themes/clean-check.zsh-theme /root/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						mv /root/.oh-my-zsh/themes/custom.zsh-theme /root/.oh-my-zsh/themes/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						ln -s /root/dotfiles/zsh/clean-check.zsh-theme /root/.oh-my-zsh/themes
						ln -s /root/dotfiles/zsh/custom.zsh-theme /root/.oh-my-zsh/themes
					else
						ln -s /root/dotfiles/zsh/clean-check.zsh-theme /root/.oh-my-zsh/themes
						ln -s /root/dotfiles/zsh/custom.zsh-theme /root/.oh-my-zsh/themes
					fi
	
					echo "Cloning custom, functions into /$currentuser/.oh-my-zsh/custom..."
					if [ -f /root/.oh-my-zsh/custom/custom.zsh ]
					then
						mv /root/.oh-my-zsh/custom/custom.zsh /root/.oh-my-zsh/custom/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /root/dotfiles/zsh/custom.zsh /root/.oh-my-zsh/custom
					else
						ln -s /root/dotfiles/zsh/custom.zsh /root/.oh-my-zsh/custom
					fi

					if [ -f /root/.oh-my-zsh/custom/functions.zsh ]
					then
						mv /root/.oh-my-zsh/custom/functions.zsh /root/.oh-my-zsh/custom/functions-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /root/dotfiles/zsh/functions.zsh /root/.oh-my-zsh/custom
					else
						ln -s /root/dotfiles/zsh/functions.zsh /root/.oh-my-zsh/custom
					fi

					echo "Cloning main-highlighter.zsh into /$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main..."
					if [ -f /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh ]
					then
						mv /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /root/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /root/dotfiles/zsh/main-highlighter.zsh /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
                        cd /root/.oh-my-zsh/custom/plugins
                        sh /root/dotfiles/zsh/git.sh
						mv /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /root/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /root/dotfiles/zsh/main-highlighter.zsh /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				else
					echo "Cloning .zshrc into /home/$currentuser..."
					if [ -f /home/$currentuser/.zshrc ]
					then
						mv /home/$currentuser/.zshrc /home/$currentuser/.zshrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /home/$currentuser/dotfiles/zsh/.zshrc /home/$currentuser
					else
						sudo ln -s /home/$currentuser/dotfiles/zsh/.zshrc /home/$currentuser
					fi

					echo "Cloning clean-check and custom themes into /home/$currentuser/.oh-my-zsh/themes..."
					if [ -f /home/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme ] || [ -f /home/$currentuser/.oh-my-zsh/themes/custom.zsh-theme ]
					then
						mv /home/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						mv /home/$currentuser/.oh-my-zsh/themes/custom.zsh-theme /home/$currentuser/.oh-my-zsh/themes/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						sudo ln -s /home/$currentuser/dotfiles/zsh/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes
						sudo ln -s /home/$currentuser/dotfiles/zsh/custom.zsh-theme /home/$currentuser/.oh-my-zsh/themes
					else
						sudo ln -s /home/$currentuser/dotfiles/zsh/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes
						sudo ln -s /home/$currentuser/dotfiles/zsh/custom.zsh-theme /home/$currentuser/.oh-my-zsh/themes
					fi
	
					echo "Cloning custom, functions into /home/$currentuser/.oh-my-zsh/custom..."
					if [ -f /home/$currentuser/.oh-my-zsh/custom/custom.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/custom.zsh /home/$currentuser/.oh-my-zsh/custom/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						sudo ln -s /home/$currentuser/dotfiles/zsh/custom.zsh /home/$currentuser/.oh-my-zsh/custom
					else
						sudo ln -s /home/$currentuser/dotfiles/zsh/custom.zsh /home/$currentuser/.oh-my-zsh/custom
					fi

					if [ -f /home/$currentuser/.oh-my-zsh/custom/functions.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/functions.zsh /home/$currentuser/.oh-my-zsh/custom/functions-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						sudo ln -s /home/$currentuser/dotfiles/zsh/functions.zsh /home/$currentuser/.oh-my-zsh/custom
					else
						sudo ln -s /home/$currentuser/dotfiles/zsh/functions.zsh /home/$currentuser/.oh-my-zsh/custom
					fi

					echo "Cloning main-highlighter.zsh into /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main..."
					if [ -f /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /home/$currentuser/dotfiles/zsh/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
                        cd /home/$currentuser/.oh-my-zsh/custom/plugins
                        sh /home/$currentuser/dotfiles/zsh/git.sh
						mv /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /home/$currentuser/dotfiles/zsh/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				fi
				unset currentuser
}

function check_for_vim {
	if ! type vim > /dev/null
			then
				echo "vim is not installed on this system; attempting to install"
				echo ""
				if [ -f /etc/lsb-release ]
				then
					echo "OS: $(lsb_release -s -d)"
					sudo apt-get install vim && echo ""
				elif [ -f /etc/debian_version ]
				then
					echo "OS: $(cat /etc/debian_version)"
					sudo apt-get install vim && echo ""
				elif [ -f /etc/redhat-release ]
				then
					echo "OS: $(cat /etc/redhat-release)"
					sudo yum install vim && echo ""
				elif [ -f /etc/arch-release ]
				then
					echo "OS: $(cat /etc/arch-release)"
					sudo pacman -S vim && echo ""
				elif [ -f /etc/SuSE-release ]
				then
					echo "OS: $(cat /etc/SuSE-release)"
			       		sudo zypper in vim && echo ""
				else
					echo "Distribution not recognized! Please install vim and run this script again."
				fi
			else
				echo "vim is already installed!"
                echo ""
			fi
		}

function vim_customize {
                echo "Setting up vim..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .vimrc into /$currentuser..."
					if [ -f /root/.vimrc ]
					then
						mv /root/.vimrc /root/.vimrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /root/dotfiles/vim/.vimrc /root
					else
						ln -s /root/dotfiles/vim/.vimrc /root
					fi

					echo "Cloning .vim into /$currentuser/.vim..."
					if [ -d /root/.vim ]
					then
						mv /root/.vim /root/.vim-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /root/dotfiles/vim/.vim /root
						cd /root/.vim/bundle
						sh git.sh
					else
						ln -s /root/dotfiles/vim/.vim /root
						cd /root/.vim/bundle
						sh git.sh
					fi
				else
					echo "Cloning .vimrc into /home/$currentuser..."
					if [ -f /home/$currentuser/.vimrc ]
					then
						mv /home/$currentuser/.vimrc /home/$currentuser/.vimrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /home/$currentuser/dotfiles/vim/.vimrc /home/$currentuser
					else
						sudo ln -s /home/$currentuser/dotfiles/vim/.vimrc /home/$currentuser
					fi

					echo "Cloning clean-check theme into /home/$currentuser/.vim..."
					if [ -d /home/$currentuser/.vim ]
					then
						mv /home/$currentuser/.vim /home/$currentuser/.vim-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /home/$currentuser/dotfiles/vim/.vim /home/$currentuser
						cd /home/$currentuser/.vim/bundle
						sh git.sh
					else
						sudo ln -s /home/$currentuser/dotfiles/vim/.vim /home/$currentuser
						cd /home/$currentuser/.vim/bundle
						sh git.sh
					fi
				fi
				unset currentuser

}

function check_for_tmux {
	if ! type tmux > /dev/null
			then
				echo "tmux is not installed on this system; attempting to install"
				echo ""
				if [ -f /etc/lsb-release ]
				then
					echo "OS: $(lsb_release -s -d)"
					sudo apt-get install tmux && echo ""
				elif [ -f /etc/debian_version ]
				then
					echo "OS: $(cat /etc/debian_version)"
					sudo apt-get install tmux && echo ""
				elif [ -f /etc/redhat-release ]
				then
					echo "OS: $(cat /etc/redhat-release)"
					sudo yum install tmux && echo ""
				elif [ -f /etc/arch-release ]
				then
					echo "OS: $(cat /etc/arch-release)"
					sudo pacman -S tmux && echo ""
				elif [ -f /etc/SuSE-release ]
				then
					echo "OS: $(cat /etc/SuSE-release)"
			       		sudo zypper in tmux && echo ""
				else
					echo "Distribution not recognized! Please install tmux and run this script again."
				fi
			else
				echo "tmux is already installed!"
                echo ""
			fi
		}

function tmux_customize {
                echo "Setting up tmux..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .tmux.conf into /$currentuser..."
					if [ -f /root/.tmux.conf ]
					then
						mv /root/.tmux.conf /root/.tmux.conf-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /root/dotfiles/tmux/.tmux.conf /root
                        cd /root/dotfiles/tmux
                        sh git.sh && sudo ln -s /root/dotfiles/tmux/linux/sam-linux.sh /root/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /root/dotfiles/tmux/linux/.tmux-powerlinerc /root
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					else
						ln -s /root/dotfiles/tmux/.tmux.conf /root
                        cd /root/dotfiles/tmux
                        sh git.sh && sudo ln -s /root/dotfiles/tmux/linux/sam-linux.sh /root/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /root/dotfiles/tmux/linux/.tmux-powerlinerc /root
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"

					fi
                else
					echo "Cloning .tmux.conf into /home/$currentuser..."
					if [ -f /home/$currentuser/.tmux.conf ]
					then
						mv /home/$currentuser/.tmux.conf /home/$currentuser/.tmux.conf-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /home/$currentuser/dotfiles/tmux/.tmux.conf /home/$currentuser
                        cd /home/$currentuser/dotfiles/tmux
                        sh git.sh && sudo ln -s /home/$currentuser/dotfiles/tmux/linux/sam-linux.sh /home/$currentuser/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /home/$currentuser/dotfiles/tmux/linux/.tmux-powerlinerc /home/$currentuser
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					else
						sudo ln -s /home/$currentuser/dotfiles/tmux/.tmux.conf /home/$currentuser
                        cd /home/$currentuser/dotfiles/tmux
                        sh git.sh && sudo ln -s /home/$currentuser/dotfiles/tmux/linux/sam-linux.sh /home/$currentuser/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /home/$currentuser/dotfiles/tmux/linux/.tmux-powerlinerc /home/$currentuser
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"

					fi
				fi
				unset currentuser

}


				
function check_for_zsh_mac {
	if ! type zsh > /dev/null
			then
				echo "zsh is not installed on this system"
				break
			else
				echo "zsh is already installed!"
				echo ""
				echo "Changing shell to zsh..."
				chsh -s $(which zsh)
				echo ""
				echo "Setting up oh-my-zsh..." &&
				install_oh_my_zsh_mac
			fi
		}

function install_oh_my_zsh_mac {
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "var/root" ]
				then
					echo "Moving to directory /var/root"
					cd /var/root
					echo ""
					echo "Cloning into /var/root"
					echo ""
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh &&
					echo ""
					echo ""
				else
					echo "Moving to directory /home/$currentuser"
					cd /home/$currentuser
					echo ""
					echo "Cloning into /home/$currentuser"
					echo ""
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh &&
					echo ""
					echo ""
				fi
				unset currentuser
			}

function oh_my_zsh_customize_mac {
                echo "Customizing zsh..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .zshrc into /var/$currentuser..."
					if [ -f /var/root/.zshrc ]
					then
						mv /var/root/.zshrc /var/root/.zshrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /var/root/dotfiles/zsh/.zshrc /var/root
					else
						ln -s /var/root/dotfiles/zsh/.zshrc /var/root
					fi

					echo "Cloning clean-check and custom themes into /var/$currentuser/.oh-my-zsh/themes..."
					if [ -f /var/root/.oh-my-zsh/themes/clean-check.zsh-theme ] || [ -f /var/root/.oh-my-zsh/themes/custom.zsh-theme ]
					then
						mv /var/root/.oh-my-zsh/themes/clean-check.zsh-theme /var/root/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						mv /var/root/.oh-my-zsh/themes/custom.zsh-theme /var/root/.oh-my-zsh/themes/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						ln -s /var/root/dotfiles/zsh/clean-check.zsh-theme /var/root/.oh-my-zsh/themes
						ln -s /var/root/dotfiles/zsh/custom.zsh-theme /var/root/.oh-my-zsh/themes
					else
						ln -s /var/root/dotfiles/zsh/clean-check.zsh-theme /var/root/.oh-my-zsh/themes
						ln -s /var/root/dotfiles/zsh/custom.zsh-theme /var/root/.oh-my-zsh/themes
					fi
	
					echo "Cloning custom, functions into /var/$currentuser/.oh-my-zsh/custom..."
					if [ -f /var/root/.oh-my-zsh/custom/custom.zsh ]
					then
						mv /var/root/.oh-my-zsh/custom/custom.zsh /var/root/.oh-my-zsh/custom/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /var/root/dotfiles/zsh/custom.zsh /var/root/.oh-my-zsh/custom
					else
						ln -s /var/root/dotfiles/zsh/custom.zsh /var/root/.oh-my-zsh/custom
					fi

					if [ -f /var/root/.oh-my-zsh/custom/functions.zsh ]
					then
						mv /var/root/.oh-my-zsh/custom/functions.zsh /var/root/.oh-my-zsh/custom/functions-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /var/root/dotfiles/zsh/functions.zsh /var/root/.oh-my-zsh/custom
					else
						ln -s /var/root/dotfiles/zsh/functions.zsh /var/root/.oh-my-zsh/custom
					fi

					echo "Cloning main-highlighter.zsh into /var/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main..."
					if [ -f /var/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh ]
					then
						mv /var/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /var/root/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /var/root/dotfiles/zsh/main-highlighter.zsh /var/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
                        cd /var/root/.oh-my-zsh/custom/plugins
                        sh /var/root/dotfiles/zsh/git.sh
						mv /var/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /var/root/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /var/root/dotfiles/zsh/main-highlighter.zsh /var/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				else
					echo "Cloning .zshrc into /Users/$currentuser..."
					if [ -f /Users/$currentuser/.zshrc ]
					then
						mv /Users/$currentuser/.zshrc /Users/$currentuser/.zshrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /Users/$currentuser/dotfiles/zsh/.zshrc /Users/$currentuser
					else
						sudo ln -s /Users/$currentuser/dotfiles/zsh/.zshrc /Users/$currentuser
					fi

					echo "Cloning clean-check and custom themes into /Users/$currentuser/.oh-my-zsh/themes..."
					if [ -f /Users/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme ] || [ -f /Users/$currentuser/.oh-my-zsh/themes/custom.zsh-theme ]
					then
						mv /Users/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme /Users/$currentuser/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						mv /Users/$currentuser/.oh-my-zsh/themes/custom.zsh-theme /Users/$currentuser/.oh-my-zsh/themes/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						sudo ln -s /Users/$currentuser/dotfiles/zsh/clean-check.zsh-theme /Users/$currentuser/.oh-my-zsh/themes
						sudo ln -s /Users/$currentuser/dotfiles/zsh/custom.zsh-theme /Users/$currentuser/.oh-my-zsh/themes
					else
						sudo ln -s /Users/$currentuser/dotfiles/zsh/clean-check.zsh-theme /Users/$currentuser/.oh-my-zsh/themes
						sudo ln -s /Users/$currentuser/dotfiles/zsh/custom.zsh-theme /Users/$currentuser/.oh-my-zsh/themes
					fi
	
					echo "Cloning custom, functions into /Users/$currentuser/.oh-my-zsh/custom..."
					if [ -f /Users/$currentuser/.oh-my-zsh/custom/custom.zsh ]
					then
						mv /Users/$currentuser/.oh-my-zsh/custom/custom.zsh /Users/$currentuser/.oh-my-zsh/custom/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						sudo ln -s /Users/$currentuser/dotfiles/zsh/custom.zsh /Users/$currentuser/.oh-my-zsh/custom
					else
						sudo ln -s /Users/$currentuser/dotfiles/zsh/custom.zsh /Users/$currentuser/.oh-my-zsh/custom
					fi

					if [ -f /Users/$currentuser/.oh-my-zsh/custom/functions.zsh ]
					then
						mv /Users/$currentuser/.oh-my-zsh/custom/functions.zsh /Users/$currentuser/.oh-my-zsh/custom/functions-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						sudo ln -s /Users/$currentuser/dotfiles/zsh/functions.zsh /Users/$currentuser/.oh-my-zsh/custom
					else
						sudo ln -s /Users/$currentuser/dotfiles/zsh/functions.zsh /Users/$currentuser/.oh-my-zsh/custom
					fi

					echo "Cloning main-highlighter.zsh into /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main..."
					if [ -f /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh ]
					then
                        mv /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /Users/$currentuser/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /Users/$currentuser/dotfiles/zsh/main-highlighter.zsh /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
                        cd /Users/$currentuser/.oh-my-zsh/custom/plugins
                        sh /Users/$currentuser/dotfiles/zsh/git.sh
						mv /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /Users/$currentuser/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /Users/$currentuser/dotfiles/zsh/main-highlighter.zsh /Users/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				fi
				unset currentuser
}

function check_for_vim_mac {
	if ! type vim > /dev/null
			then
				echo "vim is not installed on this system"
				break
			else
				echo "vim is already installed!"
                echo ""
			fi
		}

function vim_customize_mac {
                echo "Setting up vim..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .vimrc into /var/$currentuser..."
					if [ -f /var/root/.vimrc ]
					then
						mv /var/root/.vimrc /var/root/.vimrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /var/root/dotfiles/vim/.vimrc /var/root
					else
						ln -s /var/root/dotfiles/vim/.vimrc /var/root
					fi

					echo "Cloning .vim into /var/$currentuser/.vim..."
					if [ -d /var/root/.vim ]
					then
						mv /var/root/.vim /var/root/.vim-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /var/root/dotfiles/vim/.vim /var/root
						cd /var/root/.vim/bundle
						sh git.sh
					else
						ln -s /var/root/dotfiles/vim/.vim /var/root
						cd /var/root/.vim/bundle
						sh git.sh
					fi
				else
					echo "Cloning .vimrc into /Users/$currentuser..."
					if [ -f /Users/$currentuser/.vimrc ]
					then
						mv /Users/$currentuser/.vimrc /Users/$currentuser/.vimrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /Users/$currentuser/dotfiles/vim/.vimrc /Users/$currentuser
					else
						sudo ln -s /Users/$currentuser/dotfiles/vim/.vimrc /Users/$currentuser
					fi

					echo "Cloning clean-check theme into /Users/$currentuser/.vim..."
					if [ -d /Users/$currentuser/.vim ]
					then
						mv /Users/$currentuser/.vim /Users/$currentuser/.vim-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /Users/$currentuser/dotfiles/vim/.vim /Users/$currentuser
						cd /Users/$currentuser/.vim/bundle
						sh git.sh
					else
						sudo ln -s /Users/$currentuser/dotfiles/vim/.vim /Users/$currentuser
						cd /Users/$currentuser/.vim/bundle
						sh git.sh
					fi
				fi
				unset currentuser
}

function check_for_tmux_mac {
	if ! type tmux > /dev/null
			then
				echo "tmux is not installed on this system"
				break
			else
				echo "tmux is already installed!"
                echo ""
			fi
		}

function tmux_customize_mac {
                echo "Setting up tmux..."
				export currentuser=`env | grep USER | head -n 1 | cut -d'=' -f2`
				if [ "$currentuser" == "root" ]
				then
					echo "Cloning .tmux.conf into /var/$currentuser..."
					if [ -f /var/root/.tmux.conf ]
					then
						mv /var/root/.tmux.conf /var/root/.tmux.conf-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /var/root/dotfiles/tmux/.tmux.conf /var/root
                        cd /var/root/dotfiles/tmux
                        sh git.sh && sudo ln -s /var/root/dotfiles/tmux/sam.sh /var/root/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /var/root/dotfiles/tmux/.tmux-powerlinerc /var/root
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					else
						ln -s /var/root/dotfiles/tmux/.tmux.conf /var/root
                        cd /var/root/dotfiles/tmux
                        sh git.sh && sudo ln -s /var/root/dotfiles/tmux/sam.sh /var/root/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /var/root/dotfiles/tmux/.tmux-powerlinerc /var/root
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					fi
				else
					echo "Cloning .tmux.conf into /Users/$currentuser..."
					if [ -f /Users/$currentuser/.tmux.conf ]
					then
						mv /Users/$currentuser/.tmux.conf /Users/$currentuser/.tmux.conf-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						sudo ln -s /Users/$currentuser/dotfiles/tmux/.tmux.conf /Users/$currentuser
                        cd /Users/$currentuser/dotfiles/tmux
                        sh git.sh && sudo ln -s /Users/$currentuser/dotfiles/tmux/sam.sh /Users/$currentuser/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /Users/$currentuser/dotfiles/tmux/.tmux-powerlinerc /Users/$currentuser
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					else
						sudo ln -s /Users/$currentuser/dotfiles/tmux/.tmux.conf /Users/$currentuser
                        cd /Users/$currentuser/dotfiles/tmux 
                        sh git.sh && sudo ln -s /Users/$currentuser/dotfiles/tmux/sam.sh /Users/$currentuser/dotfiles/tmux/tmux-powerline/themes && sudo ln -s /Users/$currentuser/dotfiles/tmux/.tmux-powerlinerc /Users/$currentuser
                        sudo gem install tmuxinator || echo "Ruby not installed or installation failed!"
					fi
				fi
				unset currentuser
}








echo "This script will automatically configure a Unix-based system with custom configs and other files"
echo "Current supported distributions are: Ubuntu (and derivatives), Debian, Redhat, Arch, and SuSE, with partial support for OS X"
echo "(c)2013 Sam Boynton"
echo ""
echo "What OS are you configuring?"
echo ""
OS=("Linux" "OSX" "Other" "Quit")
select opt in "${OS[@]}"
do
	case $opt in
		"Linux" )
			echo "Configuring for Linux"
			echo ""
			echo ""
			echo "Setting up zsh"
			echo ""
			check_for_zsh
            oh_my_zsh_customize
			echo ""
			echo "Setting up vim"
			echo ""
			check_for_vim
            customize_vim
			echo ""
            echo "Setting up tmux"
            echo ""
            check_for_tmux
            tmux_customize
			echo ""
			echo "Done! If any of the git repos failed to download, simply run vim/.vim/bundle/git.sh again"
			;;
		"OSX" )
			echo "Configuring for OSX"
			echo ""
			echo ""
			echo "Setting up zsh"
			echo ""
			check_for_zsh_mac
            oh_my_zsh_customize_mac
			echo ""
			echo "Setting up vim"
			echo ""
			check_for_vim_mac
            customize_vim_mac
			echo ""
            echo "Setting up tmux"
            echo ""
            check_for_tmux_mac
            tmux_customize_mac
			echo ""
			echo "Done! If any of the git repos failed to download, simply run vim/.vim/bundle/git.sh again"
			;;
		"Other" )
			echo "Nothing here yet!"
			;;
		"Quit" )
			break
			;;
		* )
			echo invalid option
			;;
	esac
done

