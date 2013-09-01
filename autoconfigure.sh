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
					apt-get install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/debian_version ]
				then
					echo "OS: $(cat /etc/debian_version)"
					apt-get install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/redhat-release ]
				then
					echo "OS: $(cat /etc/redhat-release)"
					yum install zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/arch-release ]
				then
					echo "OS: $(cat /etc/arch-release)"
					pacman -S zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
				elif [ -f /etc/SuSE-release ]
				then
					echo "OS: $(cat /etc/SuSE-release)"
			       		zypper in zsh && echo "" && echo "Changing shell to zsh..." && chsh -s $(which zsh) && echo "Setting up oh-my-zsh..." && install_oh_my_zsh
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
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
					echo ""
					echo ""
					echo "Customizing zsh..."
					echo ""
					oh_my_zsh_customize
				else
					echo "Moving to directory /home/$currentuser"
					cd /home/$currentuser
					echo ""
					echo "Cloning into /home/$currentuser"
					echo ""
					wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
					echo ""
					echo ""
					echo "Customizing zsh..."
					echo ""
					oh_my_zsh_customize
				fi
				unset currentuser
			}

function oh_my_zsh_customize {
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

					echo "Cloning clean-check theme into /$currentuser/.oh-my-zsh/themes..."
					if [ -f /root/.oh-my-zsh/themes/clean-check.zsh-theme ]
					then
						mv /root/.oh-my-zsh/themes/clean-check.zsh-theme /root/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						ln -s /root/dotfiles/zsh/clean-check.zsh-theme /root/.oh-my-zsh/themes
					else
						ln -s /root/dotfiles/zsh/clean-check.zsh-theme /root/.oh-my-zsh/themes
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
						mkdir -p /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main && ln -s /root/dotfiles/zsh/main-highlighter.zsh /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
						mkdir -p /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main && ln -s /root/dotfiles/zsh/main-highlighter.zsh /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				else
					echo "Cloning .zshrc into /home/$currentuser..."
					if [ -f /home/$currentuser/.zshrc ]
					then
						mv /home/$currentuser/.zshrc /home/$currentuser/.zshrc-`date|cut -d' ' -f5|sed 's/:/_/g'` &&
						ln -s /home/$currentuser/dotfiles/zsh/.zshrc /home/$currentuser
					else
						ln -s /home/$currentuser/dotfiles/zsh/.zshrc /home/$currentuser
					fi

					echo "Cloning clean-check theme into /home/$currentuser/.oh-my-zsh/themes..."
					if [ -f /home/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme ]
					then
						mv /home/$currentuser/.oh-my-zsh/themes/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes/clean-check-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh-theme &&
						ln -s /home/$currentuser/dotfiles/zsh/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes
					else
						ln -s /home/$currentuser/dotfiles/zsh/clean-check.zsh-theme /home/$currentuser/.oh-my-zsh/themes
					fi
	
					echo "Cloning custom, functions into /home/$currentuser/.oh-my-zsh/custom..."
					if [ -f /home/$currentuser/.oh-my-zsh/custom/custom.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/custom.zsh /home/$currentuser/.oh-my-zsh/custom/custom-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /home/$currentuser/dotfiles/zsh/custom.zsh /home/$currentuser/.oh-my-zsh/custom
					else
						ln -s /home/$currentuser/dotfiles/zsh/custom.zsh /home/$currentuser/.oh-my-zsh/custom
					fi

					if [ -f /home/$currentuser/.oh-my-zsh/custom/functions.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/functions.zsh /home/$currentuser/.oh-my-zsh/custom/functions-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						ln -s /home/$currentuser/dotfiles/zsh/functions.zsh /home/$currentuser/.oh-my-zsh/custom
					else
						ln -s /home/$currentuser/dotfiles/zsh/functions.zsh /home/$currentuser/.oh-my-zsh/custom
					fi

					echo "Cloning main-highlighter.zsh into /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main..."
					if [ -f /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh ]
					then
						mv /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/zsh-syntax-highlighting/highlighters/main/main-highlighter-`date|cut -d' ' -f5|sed 's/:/_/g'`.zsh
						mkdir -p /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main && ln -s /home/$currentuser/dotfiles/zsh/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					else
						mkdir -p /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main && ln -s /home/$currentuser/dotfiles/zsh/main-highlighter.zsh /home/$currentuser/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/highlighters/main
					fi
				fi
				unset currentuser
}
				



echo "This script will automatically configure a Unix-based system with custom configs and other files"
echo "Current supported distributions are: Ubuntu (and derivatives), Debian, Redhat, Arch, SuSE"
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
			;;
		"OSX" )
			echo "Configuring for OSX"
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
