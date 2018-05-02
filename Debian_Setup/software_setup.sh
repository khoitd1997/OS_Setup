#!/bin/bash
# scripts written for setting up a fresh Debian based system

#----------------------------------------------------------------------------------------------------
# Variables start here
# Modify software lists here
# NO SPACE AROUND '=' for variable assignment

# list of general utilities without GUI
software_general_repo_non_gui=" doxygen checkinstall lm-sensors cmake valgrind \
gcc clang llvm emacs build-essential htop net-tools  minicom screen python3-pip curl "

# list of software with GUI
software_with_gui=" xclip terminator guake ddd evince synaptic psensor gufw xpad \
libreoffice-style-hicontrast unattended-upgrades gparted \
libappindicator1 libindicator7 hardinfo chromium-browser moserial libncurses* nautilus-dropbox meld \
bustle d-feet "

# list of dropped app
software_dropped=" gitg"

# all tool chains and utilities
tool_chain_not_18_04_compat=" gdb-arm-none-eabi " # not compatible with ubuntu 18.04 for now
arm_toolchain=" openocd qemu gcc-arm-none-eabi"
avr_arduino_toolchain="avrdude avr-libc simulavr"

source ../utils.sh
# Configuration Parameters
wsl=1 # 0 for installing on Window Subsystem for Linux, 1 for not wsl by default
set -e 
set -o pipefail
set -o nounset

#----------------------------------------------------------------------------------------------------
check_dir OS_Setup/Debian_Setup

# disable root account
sudo passwd -l root

printf "\n ${cyan} ---------BASIC-----------\n ${reset}"
print_message "Starting $(basename $0)\n " # extract base name from $0
cd # back to home directory

if [ $wsl -eq 1 ] ; then
if sudo ufw enable; then
print_message "Firewall Enabled\n"
sleep 4
else
print_error "Firewall failed to enable\n "
exit 1
sleep 4
fi
fi



# update the system, only proceed if the previous command is successful
if [ $wsl -eq 1 ] ; then
    SOFTWARE_GENERAL_REPO="${software_general_repo_non_gui}${software_with_gui}"
else
    SOFTWARE_GENERAL_REPO="${software_general_repo_non_gui}"
fi

if sudo apt-get update\
&& sudo apt-get dist-upgrade\
&& sudo apt-get install ${SOFTWARE_GENERAL_REPO}
then
print_error "Basic Setup Done\n "
else
print_error "Failed in Basic update and install\n "
exit 1
fi

sudo dpkg-reconfigure unattended-upgrades

# Added access to usb ports for current user
sudo usermod -a -G dialout ${USER}

# setup GNOME keyring git credential helper
sudo apt-get install libgnome-keyring-dev
sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring/
git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
git config --global user.email "khoidinhtrinh@gmail.com"
git config --global user.name "khoitd1997"

#----------------------------------------------------------------------------------------------------

# Dev tools installations start here
printf "\n ${cyan}--------DEV-TOOLS----------- ${reset}"
printf "${cyan}\n Basic Install is done, please select additional install options separated by space: \n${reset}"
printf  "${cyan}1/ARM 2/AVR 3/Java${reset}"
read input

# handle options
for option in ${input}; do
case $option in 
    1) 
print_message "Installing ARM\n"
    if ! sudo apt-get install $arm_toolchain; then
print_error "Failed to install ARM toolchain\n"
    exit 1
    fi ;;
    2) 
print_message "Installing AVR\n "
    if ! sudo apt-get install $avr_arduino_toolchain; then
print_error "Failed to install AVR toolchain\n"
    exit 1
    fi ;;
    3) 
print_message "Installing java 8, gradle, check PPA and newer version of Java, press anykey to confirm\n"
    read confirm
print_message "Please press any key again for final confirm\n"
    read confirm
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update 
    sudo apt-get install gradle -y 
    sudo apt-get install oracle-java8-installer -y ;;
esac
done 
sudo apt autoremove -y

#----------------------------------------------------------------------------------------------------
# Post installtion messages start here
exit 0