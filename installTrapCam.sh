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
echo "|"
echo "|"
echo "| 	Installing TrapCam software"
echo "|"
echo "|"
echo "---------------------------------------------------------------------------------"

cd $HOME
# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------

cp /boot/cmdline.txt /boot/cmdline.txt.old
echo "$(cat /boot/cmdline.txt) logo.nologo quiet splash loglevel=0" > /boot/cmdline.txt
cp /boot/config.txt /boot/config.txt.old
cp TrapCam/configs/config.txt /boot/config.txt

cp .bashrc .bashrc.old
cp TrapCam/configs/.bashrc .

cp /etc/rc.local /etc/rc.local.old
cp TrapCam/configs/rc.local /etc/rc.local

# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------

cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
cp TrapCam/services/autologin@.service /etc/systemd/system/autologin@.service

cp TrapCam/services/image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service
cp TrapCam/services/splashscreen.service /etc/systemd/system/splashscreen.service

systemctl enable splashscreen.service
systemctl start splashscreen.service

systemctl enable image_on_shutdown.service
systemctl start image_on_shutdown.service

cd ..

# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
cd $HOME/wittyPi/schedules

cp $HOME/TrapCam/TrapCam_* .

cd $HOME

# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------

cp TrapCam/TrapCam.sh .
cp TrapCam/shutdown_now.sh .

# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
cp TrapCam/splash.png /etc/splash.png

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
cd /media
mkdir DATA
chown -R pi:pi /media/DATA

# ----------------------------------------------------------
# Finish install
# ----------------------------------------------------------
cd $HOME
echo "-------------------------------------------------------------------------------"
echo ""
echo "TrapCam software has been installed and will start upon reboot"
echo ""
echo "-------------------------------------------------------------------------------"

exit 0
