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
	echo "Git is not installed. Please install git, reboot and try again."
	echo "Exiting TrapCam install..."
	exit 1
fi

fbi --version
if [ $? -ne 0 ]; then
	echo "fbi package is not currently installed."
	echo "Installing fbi package now..."
	apt update
	echo "y" | apt install fbi
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
echo "--------------------------------------------------------------------------------"

cd /home/
WD=/home/$(ls)
cd $WD
# ----------------------------------------------------------
# Copy configs
# ----------------------------------------------------------
echo "Copying config files. Previous cmdline, config, bashrc, and rclocal files are stored as .old"

cp /boot/cmdline.txt /boot/cmdline.txt.old
echo "$(cat /boot/cmdline.txt) logo.nologo quiet splash loglevel=0" > /boot/cmdline.txt
cp /boot/config.txt /boot/config.txt.old
cp $WD/TrapCam/configs/config.txt /boot/config.txt

cp .bashrc .bashrc.old
cp $WD/TrapCam/configs/.bashrc .

cp /etc/rc.local /etc/rc.local.old
cp $WD/TrapCam/configs/rc.local /etc/rc.local

echo "Done copying configs"
# ----------------------------------------------------------
# Copy and install services
# ----------------------------------------------------------
echo "Copying and installing services..."

cp /etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service.old
cp $WD/TrapCam/services/autologin@.service /etc/systemd/system/autologin@.service

cp $WD/TrapCam/services/image_on_shutdown.service /etc/systemd/system/image_on_shutdown.service
cp $WD/TrapCam/services/splashscreen.service /etc/systemd/system/splashscreen.service

systemctl enable splashscreen.service
systemctl start splashscreen.service

systemctl enable image_on_shutdown.service
systemctl start image_on_shutdown.service

cd ..

echo "Done creating boot and shutdown services"
# ----------------------------------------------------------
# Copy schedule scripts
# ----------------------------------------------------------
echo "Copying wittyPi schedule scripts..."

cd $WD/wittyPi/schedules

cp $WD/TrapCam/schedules/TrapCam_* .

cd $WD

echo "Done copying schedules..."
# ----------------------------------------------------------
# Copy shell scripts
# ----------------------------------------------------------
echo "Copying TrapCam shell scripts..."

cp $WD/TrapCam/scripts/TrapCam.sh .
cp $WD/TrapCam/scripts/shutdown_now.sh .

echo "Done"
# ----------------------------------------------------------
# Copy splashscreen image
# ----------------------------------------------------------
cp $WD/TrapCam/splash.png /etc/splash.png

# ----------------------------------------------------------
# Make USB mount location
# ----------------------------------------------------------
echo "Creating USB mount directory..."
cd /media

if [ ! -d "DATA" ]; then
	mkdir DATA
	chown -R pi:pi /media/DATA
else
	echo "Mount directory already exists"
fi

# ----------------------------------------------------------
# Finish install
# ----------------------------------------------------------
cd $WD
echo "-------------------------------------------------------------------------------"
echo ""
echo "TrapCam software has been installed and will start upon reboot"
echo ""
echo "-------------------------------------------------------------------------------"

exit 0
