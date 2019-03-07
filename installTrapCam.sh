#! /bin/bash

# installTrapCam.sh

# Author: Jack Butler
# Created: March 2019
# Last Edit: J Butler March 2019

# Installs TrapCam dependencies, shell scripts, and configs

# ----------------------------------------------------------
# Check whether git and fbi are installed
# ----------------------------------------------------------
git --version
if [ $? -ne 0 ]; then
	echo "Git is not installed. Please install git and try again."
	echo "Exiting TrapCam install..."
	exit 1
fi

fbi --version
if [ $? -ne 0 ]; then
	echo "fbi package not installed. Please install fbi and try again."
	echo "Exiting TrapCam install..."
	exit 1
fi

# ----------------------------------------------------------
# Pull TrapCam software from GitHub
# ----------------------------------------------------------
git clone https://github.com/jack-butler/TrapCam
clear

cd TrapCam/

# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------
cd configs/

sudo cp /boot/cmdline.txt /boot/cmdline.txt.old
sudo cp cmdline.txt /boot/cmdline.txt

sudo cp /boot/config.txt /boot/config.txt.old
sudo cp config.txt /boot/config.txt

sudo cp ~/.bashrc ~/.bashrc.old
sudo cp .bashrc ~/.bashrc

sudo cp /etc/rc.local /etc/rc.local.old
sudo cp rc.local /etc/rc.local

cd ..

# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
cd services/

sudo cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
sudo cp autologin@.service /etc/systemd/system/autologin@.service

sudo cp image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service
sudo cp splashscreen.service /etc/systemd/system/splashscreen.service

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

sudo cp TrapCam.sh ~/TrapCam.sh
sudo cp shutdown_now.sh ~/shutdown_now.sh

cd ..

# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
sudo cp splash.png /etc/splash.png

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
echo "TrapCam software has been installed and will start upon reboot"
echo ""
echo "---------------------------------------------------------------"

exit 0
