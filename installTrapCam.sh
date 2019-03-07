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
# Install TrapCam Software
# ----------------------------------------------------------
clear
echo "--------------------------------------------------------------------------------"
echo "|																				  |"
echo "|																				  |"
echo "| 						Installing TrapCam software							  |"
echo "|																				  |"
echo "|																				  |"
echo "---------------------------------------------------------------------------------"

# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------
cd configs/

sudo cp /boot/cmdline.txt /boot/cmdline.txt.old 2>$1 /dev/null
sudo cp cmdline.txt /boot/cmdline.txt 2>$1 /dev/null

sudo cp /boot/config.txt /boot/config.txt.old 2>$1 /dev/null
sudo cp config.txt /boot/config.txt 2>$1 /dev/null

sudo cp ~/.bashrc ~/.bashrc.old 2>$1 /dev/null
sudo cp .bashrc ~/.bashrc 2>$1 /dev/null

sudo cp /etc/rc.local /etc/rc.local.old 2>$1 /dev/null
sudo cp rc.local /etc/rc.local 2>$1 /dev/null

cd ..

# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
cd services/

sudo cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old 2>$1 /dev/null
sudo cp autologin@.service /etc/systemd/system/autologin@.service 2>$1 /dev/null

sudo cp image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service 2>$1 /dev/null
sudo cp splashscreen.service /etc/systemd/system/splashscreen.service 2>$1 /dev/null

sudo systemctl enable splashscreen.service 2>$1 /dev/null
sudo systemctl start splashscreen.service 2>$1 /dev/null

sudo systemctl enable image_on_shutdown.service 2>$1 /dev/null
sudo systemctl start image_on_shutdown.service 2>$1 /dev/null

cd ..

# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
cd schedules/

sudo cp TrapCam_* ~/wittyPi/schedules/ 2>$1 /dev/null

cd ..

# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------
cd scripts/

sudo cp TrapCam.sh ~/TrapCam.sh 2>$1 /dev/null
sudo cp shutdown_now.sh ~/shutdown_now.sh 2>$1 /dev/null

cd ..

# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
sudo cp splash.png /etc/splash.png 2>$1 /dev/null

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
cd /media
sudo mkdir DATA 2>$1 /dev/null
sudo chown -R pi:pi /media/DATA 2>$1 /dev/null

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
