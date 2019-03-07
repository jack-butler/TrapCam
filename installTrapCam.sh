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

cp /boot/cmdline.txt /boot/cmdline.txt.old
cp cmdline.txt /boot/cmdline.txt

cp /boot/config.txt /boot/config.txt.old
cp config.txt /boot/config.txt

cp ~/.bashrc ~/.bashrc.old
cp .bashrc ~/.bashrc

cp /etc/rc.local /etc/rc.local.old
cp rc.local /etc/rc.local

cd ..

# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
cd services/

cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
cp autologin@.service /etc/systemd/system/autologin@.service

cp image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service
cp splashscreen.service /etc/systemd/system/splashscreen.service

systemctl enable splashscreen.service
systemctl start splashscreen.service

systemctl enable image_on_shutdown.service
systemctl start image_on_shutdown.service

cd ..

# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
cd schedules/

cp TrapCam_* ~/wittyPi/schedules/

cd ..

# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------
cd scripts/

cp TrapCam.sh ~/TrapCam.sh
cp shutdown_now.sh ~/shutdown_now.sh

cd ..

# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
cp splash.png /etc/splash.png

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
cd /media
mkdir DATA 2>$1 /dev/null
chown -R pi:pi /media/DATA

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
