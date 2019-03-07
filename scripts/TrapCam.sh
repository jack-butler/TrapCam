#!/bin/bash

# TrapCam.sh

# Author: Jack Butler
# Created: Feb 2019
# Last Edit: J Butler Feb 2019

# Take video from camera, turn on/off lights, schedule next rPi start-up

clear
echo "--------------------------------------------------------------------------------"
echo "|																				  |"
echo "|																				  |"
echo "| 							Welcome to TrapCam								  |"
echo "|																				  |"
echo "|																				  |"
echo "----------------$(date)--------------------------------------------"


# -----------------------------------------------------------------------
# Set up
# -----------------------------------------------------------------------

rf="run.log"

start=$(date)
hour=$(date +%H)

echo "" |& tee -a "${rf}"
echo "Start time of TrapCam.sh: $start" |& tee -a "${rf}"

if ! [ -s nolights.txt ]; then
	echo $(date +%s -d "+6 days 19:00:00") > nolights.txt
	echo "Lights will not turn on after $(date -d '+6 days 19:00:00')" |& tee -a "${rf}"
fi

# -----------------------------------------------------------------------
# Mount USB
# -----------------------------------------------------------------------
for usb in $(ls /dev/disk/by-label | grep -E -v 'boot|root')
do
	sudo mount /dev/disk/by-label/$usb /media/DATA |& tee -a "${rf}"
	# if disk usage is 90% or less, break the loop and use the disk
	if [ $(df --total /media/DATA | grep -E total | cut -c42-44) -le 90 ]; then
		echo "Video recording stored to $usb" |& tee -a "${rf}"
		break
	fi
done

# -----------------------------------------------------------------------
# Turn on lights, if necessary
# -----------------------------------------------------------------------
if [ $(date +%s) -le $(cat /home/pi/nolights.txt) ]; then
	if [ $(date +%H) -ge 19 ] || [ $(date +%H) -lt 7 ]; then
		echo "Time is between 19:00 and 07:00. Turning on lights..." |& tee -a "${rf}"
		
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
	raspivid -o $vidname.h264 -t 300000 -md 2 -fps 15 -vf -hf -a 12 -n

echo "Video recording ended at $(date +%T)" |& tee -a "${rf}"
echo "" |& tee -a "${rf}"
cd /home/pi

# -----------------------------------------------------------------------
# Schedule next start-up
# -----------------------------------------------------------------------
echo "Scheduling next start-up..." |& tee -a "${rf}"

if [ $(date +%s) -le $(cat /home/pi/nolights.txt) ]; then
# It's within the window when the lights are still cycled on, so run the
# 50% duty cycle schedule
	sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittyPi/schedule.wpi
	sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
else
# Lights no longer come on at night, so no need to turn the camera on at
# night either
	if [ $(date +%H) -ge 19 ] || [ $(date +%H) -lt 7 ]; then
		sudo cp /home/pi/wittyPi/schedules/TrapCam_5AM_wakeup.wpi /home/pi/wittyPi/schedule.wpi
		sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
	else
		sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittyPi/schedule.wpi
		sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
	fi
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

