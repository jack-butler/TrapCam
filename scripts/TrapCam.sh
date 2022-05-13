#!/bin/bash

# TrapCam.sh

# Author: Jack Butler
# Created: Feb 2019
# Last Edit: J Butler April 2020
# Edit Comments: Offloads startup scheduling to another script that runs before
#								 this script to help prevent a schedule error

# Take video from camera, turn on/off lights

clear
echo ' .___________..______          ___      .______     ______     ___      .___  ___. '
echo ' |           ||   _  \        /   \     |   _  \   /      |   /   \     |   \/   | '
echo ' `---|  |----`|  |_)  |      /  ^  \    |  |_)  | |  ,----   /  ^  \    |  \  /  | '
echo '     |  |     |      /      /  /_\  \   |   ___/  |  |      /  /_\  \   |  |\/|  | '
echo '     |  |     |  |\  \----./  _____  \  |  |      |  `----./  _____  \  |  |  |  | '
echo '     |__|     | _| `._____/__/     \__\ | _|       \______/__/     \__\ |__|  |__| '

# -----------------------------------------------------------------------
# Set up
# -----------------------------------------------------------------------

rf="run.log"
uhome="$(getent passwd $SUDO_USER | cut -d: -f6)"
user="$(getent passwd $SUDO_USER | cut -d: -f1)"

echo "Start time of TrapCam.sh: $(date)" |& tee -a "${rf}"

# -----------------------------------------------------------------------
# Mount USB
# -----------------------------------------------------------------------
for usb in $(ls /dev/disk/by-label | grep -E -v 'boot|root')
do
	sudo mount /dev/disk/by-label/$usb /media/DATA |& tee -a "${rf}"
	# if disk usage is 240GB or less, break the loop and use the disk
	if [[ $(df --total /media/DATA | awk '$1=="total"{print$3}') -le 240000000 ]]; then
		echo "Video recording stored to $usb" |& tee -a "${rf}"
		break
	else
		echo "$usb is full. Unmounting..."
		sudo umount /media/DATA
	fi
done

# check whether a usb is mounted to /media/DATA
if mountpoint -q /media/DATA; then
	echo "Writing video to $(lsblk -o label,mountpoint | grep -E /media/DATA | cut --delimiter=' ' -f1)"
else
	echo "All USB drives are full. Video stored to SD card on /media/DATA" |& tee -a "${rf}"
fi

# -----------------------------------------------------------------------
# Turn on lights, if necessary
# -----------------------------------------------------------------------
if [ $(date +%H) -ge 19 ] || [ $(date +%H) -lt 7 ]; then
	echo "Time is between 19:00 and 07:00. Turning on lights..." |& tee -a "${rf}"

	gpio mode 25 out
	gpio write 25 1

else
	echo "It's daytime; no need for lights..." |& tee -a "${rf}"

	gpio mode 25 out
	gpio write 25 0 # for good measure

fi

# -----------------------------------------------------------------------
# Take video
# -----------------------------------------------------------------------
vidname="${user}_$(date +%Y%m%d%H%M%S)"
echo "Video filename: "$vidname".h264" |& tee -a "${rf}"

cd /media/DATA
echo "Video recording started at $(date +%T)" |& tee -a "${rf}"
echo "Video filename: "$vidname".h264" |& tee -a "${rf}"

timeout --signal=SIGKILL 360 \
	raspivid -o $vidname.h264 -t 300000 -md 4 -fps 24 -b 0 \
		-lev 4.2 -pf high -g 96 \
		-a 4 -a "$HOSTNAME %X %Y/%m/%d" -n

echo "Video recording ended at $(date +%T)" |& tee -a "${rf}"
echo "" |& tee -a "${rf}"
cd $uhome

# -----------------------------------------------------------------------
# Check temperature
# -----------------------------------------------------------------------
. $uhome/wittypi/utilities.sh

cd $uhome/wittypi && temp="$(get_temperature)"
cd $uhome && echo "wittyPi temperature at $(date +%T) is $temp" |& tee -a "${rf}"

# -----------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------
echo "End time of TrapCam.sh: $(date +%T)" |& tee -a "${rf}"

# -----------------------------------------------------------------------
# Exit TrapCam
# -----------------------------------------------------------------------
echo "Exiting TrapCam.sh..."
exit 0
