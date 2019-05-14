#!/bin/bash

# TrapCam.sh

# Author: Jack Butler
# Created: Feb 2019
# Last Edit: J Butler May 2019
# Edit Comments: Fixed issue with mounting USB

# Take video from camera, turn on/off lights, schedule next rPi start-up

clear
echo "--------------------------------------------------------------------------------"
echo "|"
echo "|"
echo "|		Welcome to TrapCam"
echo "|"
echo "|"
echo "----------------$(date)-------------------------"


# -----------------------------------------------------------------------
# Set up
# -----------------------------------------------------------------------

rf="run.log"

start=$(date)
hour=$(date +%H)

echo "" |& tee -a "${rf}"
echo "Start time of TrapCam.sh: $start" |& tee -a "${rf}"

if ! [ -s nolights.txt ]; then
	# Change +6 days to however long lights should run after initial start-up
	echo $(date +%s -d "+6 days 18:00:00") > nolights.txt
	echo "Lights will not turn on after $(date -d '+6 days 18:00:00')" |& tee -a "${rf}"
fi

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

if [ -s nolights.txt ]; then
	if [ $(date +%s) -le $(cat /home/pi/nolights.txt) ]; then
	# To change the timing of the lights on/off cycle, change the 18 & 8 in the 
	# test command below to the hours at which the lights should turn on or off
		if [ $(date +%H) -ge 18 ] || [ $(date +%H) -lt 8 ]; then
			echo "Time is between 18:00 and 08:00. Turning on lights..." |& tee -a "${rf}"
		
			gpio mode 25 out
			gpio write 25 1
		else
			echo "It's daytime; no need for lights..." |& tee -a "${rf}"

			gpio mode 25 out
			gpio write 25 0 # for good measure
		fi
	else
		echo "Battery considerations preclude using lights..." |& tee -a "${rf}"

		gpio mode 25 out
		gpio write 25 0 # for good measure
	fi
else
	# If nolights.txt doesn't exist, just cycle the lights like normal
	# As above, change the 18 & 8 to change the timing of the lights on/off cycle
	if [ $(date +%H) -ge 18 ] || [ $(date +%H) -lt 8 ]; then
			echo "Time is between 18:00 and 08:00. Turning on lights..." |& tee -a "${rf}"
		
			gpio mode 25 out
			gpio write 25 1
		else
			echo "It's daytime; no need for lights..." |& tee -a "${rf}"

			gpio mode 25 out
			gpio write 25 0 # for good measure
		fi
fi
	
# -----------------------------------------------------------------------
# Take video
# -----------------------------------------------------------------------
vidname=$(date +%Y%m%d%H%M%S)
echo "Video filename: "$vidname".h264" |& tee -a "${rf}"

cd /media/DATA
echo "TrapCam started at $start" |& tee -a "${rf}"
echo "Video recording started at $(date +%T)" |& tee -a "${rf}"
echo "Video filename: "$vidname".h264" |& tee -a "${rf}"

timeout --signal=SIGKILL 360 \
	raspivid -o $vidname.h264 -t 300000 -md 4 -vf -hf \
		-a 4 -a "$HOSTNAME %X %Y/%m/%d" -n

echo "Video recording ended at $(date +%T)" |& tee -a "${rf}"
echo "" |& tee -a "${rf}"
cd /home/pi

# -----------------------------------------------------------------------
# Schedule next start-up
# -----------------------------------------------------------------------
echo "Scheduling next start-up..." |& tee -a "${rf}"

if [ -s /home/pi/nolights.txt ]; then
	if [ $(date +%s) -le $(cat /home/pi/nolights.txt) ]; then
	# It's within the window when the lights are still cycled on, so run the
	# 50% duty cycle schedule
		sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittyPi/schedule.wpi
		sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
	else
	# Lights no longer come on at night, so no need to turn the camera on at
	# night either
		if [ $(date +%H) -ge 18 ] || [ $(date +%H) -lt 8 ]; then
			sudo cp /home/pi/wittyPi/schedules/TrapCam_8AM_wakeup.wpi /home/pi/wittyPi/schedule.wpi
			sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
		else
			sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittyPi/schedule.wpi
			sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
		fi
	fi
else
	# nolights.txt wasn't created at start-up, so just copy the regular duty cycle
	sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittyPi/schedule.wpi
	sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
fi

# -----------------------------------------------------------------------
# Check temperature
# -----------------------------------------------------------------------
. /home/pi/wittyPi/utilities.sh

cd /home/pi/wittyPi && temp="$(get_temperature)"
cd /home/pi && echo "wittyPi temperature at $(date +%T) is $temp" |& tee -a "${rf}"

# -----------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------
echo "End time of TrapCam.sh: $(date +%T)" |& tee -a "${rf}"

# -----------------------------------------------------------------------
# Exit TrapCam
# -----------------------------------------------------------------------
echo "Exiting TrapCam.sh..."
exit 0

