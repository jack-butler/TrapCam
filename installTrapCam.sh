#! /bin/bash

# installTrapCam.sh

# Author: Jack Butler
# Created: March 2019
# Last Edit: J Butler March 2019

# Installs TrapCam dependencies, shell scripts, and configs

# ----------------------------------------------------------
# Check package dependencies
# ----------------------------------------------------------
# Need git and fbi to be installed
if [ $(dpkg -l | grep fbi) -eq 1 ] || [ $(dpkg -l | grep git) -eq 1 ]; then
	if [ $(dpkg -l | grep fbi) -eq 1 ]; then
		echo "Please apt install fbi package"
		exit 1
	else
		echo "Please apt install git"
		exit 1
	fi
fi

# ----------------------------------------------------------
# Install wittyPi
# ----------------------------------------------------------
wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
sudo echo "y n" | sudo sh installWittyPi.sh
clear

# ----------------------------------------------------------
# Install WiringPi
# ----------------------------------------------------------
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi
./build
clear

# ----------------------------------------------------------
# Pull TrapCam software from GitHub
# ----------------------------------------------------------
cd ~
git clone https://github.com/jack-butler/TrapCam
clear

cd TrapCam/

# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------
cd configs/

sudo cp /boot/cmdline.txt /boot/cmdline.txt.old
sudo cp cmdline.txt /boot/

sudo cp /boot/config.txt /boot/config.txt.old
sudo cp config.txt /boot/

sudo cp ~/.bashrc ~/.bashrc.old
sudo cp .bashrc ~/

sudo cp /etc/rc.local /etc/rc.local.old
sudo cp rc.local /etc/

cd ..

# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
cd services/

sudo cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
sudo cp autologin@.service /etc/systemd/system/

sudo cp image_on_shutdown.service /etc/systemd/system/
sudo cp splashscreen.service /etc/systemd/system/

sudo systemctl enable splashscreen.service
sudo systemctl start splashscreen.service

sudo systemctl enable image_on_shutdown.service
sudo systemctl start image_on_shutdown.service

cd ..

# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
cd schedules/

sudo cp TrapCam_* ~/wittyPi/schedules/

cd ..

# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------
cd scripts/

sudo cp TrapCam.sh ~/
sudo cp shutdown_now.sh ~/

cd ..

# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
sudo cp splash.png /etc/

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
cd /media
sudo mkdir DATA
sudo chown -R pi:pi /media/DATA

# ----------------------------------------------------------
# Finish install
# ----------------------------------------------------------
cd ~
clear
echo "---------------------------------------------------------------"
echo ""
echo "TrapCam software has been installed. Please restart your rPi :)"
echo ""
echo "---------------------------------------------------------------"

exit 0
