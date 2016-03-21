#!/usr/bin/env bash

function set_update_source() {
    sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo cp sources.list.tmp /etc/apt/sources.list
    sudo cat /etc/apt/sources.list.bak >> /etc/apt/sources.list
    sudo apt-get update
}

function install_common_tools() {
    sudo apt-get install openssh-server
    sudo apt-get install cscope
    sudo apt-get install ctags
    sudo apt-get install git
}

function install_samba() {
    sudo apt-get install samba
    echo "Please input usr_name"
    echo ">> "
    read usr_name
    test -e /home/$usr_name/share
    if [[ $? -ne 0 ]];then
        mkdir /home/$usr_name/share
    fi
    chmod 777 -R /home/$usr_name/share

    test -e /etc/samba
    if [[ $? -ne 0 ]];then
        sudo mkdir  /etc/samba
    fi

    test -e /etc/samba/smb.conf
    if [[ $? -eq 0 ]];then
        sudo touch /etc/samba/smb.conf
    fi
    sudo cp /etc/samba/smb.conf  /etc/samba/smb.conf.bak
    sudo chmod 666 /etc/samba/smb.conf
    sudo echo "[share]" >> /etc/samba/smb.conf
    sudo echo "path=/home/$usr_name/share" >> /etc/samba/smb.conf
    sudo echo "available=yes" >> /etc/samba/smb.conf
    sudo echo "browseable=yes" >> /etc/samba/smb.conf
    sudo echo "public=yes" >> /etc/samba/smb.conf
    sudo echo "writable=yes" >> /etc/samba/smb.conf
    sudo chmod 444 /etc/samba/smb.conf

    sudo touch /etc/samba/smbpasswd
    sudo smbpasswd -a $usr_name
    sudo service smbd restart
}

function install_tmux() {
    cp tmux.conf ~/.tmux.conf
    sudo apt-get install tmux
}

function install_vim() {
    sudo apt-get install vim
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    cp vimrc ~/.vimrc
    cp vimrc.bundles ~/.vimrc.bundles
}

#####################################################################
# Main 

#test the os type, this script only for ubuntu
sudo lsb_release -a > version_log.txt
cat version_log.txt | grep Ubuntu
retval=$?
rm version_log.txt
if [[ $retval -eq 1 ]]; then
    echo "Error: sorry this script only for ubuntu os" 
    exit
fi

for (( ; ; )); do
    echo "Please select what you want to do"
    echo "1. Setup Update sources list"
    echo "2. Install openssh, git, ctags, cscope, and so on"
    echo "3. Install samba"
    echo "4. Install tmux"
    echo "5. Install vim"
    echo "6. Give up, and exit"
    echo ">> "

    read input

    case $input in 
    1)
        clear
        set_update_source
        ;;
    2)
        clear
        install_common_tools
        ;;
    3)
        clear
        install_samba
        ;;
    4)
        clear
        install_tmux
        ;;
    5)
        clear
        install_vim
        ;;
    6)
        clear
        exit
        ;;
    *)
        clear
        echo "Error: Invalid select!, please select again"
        ;;
    esac
    sleep 1
done
