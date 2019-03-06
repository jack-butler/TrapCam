#!/bin/bash

# shutdown_now.sh

# Author: Jack Butler
# Created: Feb 2019
# Last Edit: Feb 2019

# Shuts down the rPi

# ----------------------------------------
# Set up
# ----------------------------------------
rf="run.log"

# ----------------------------------------
# Check if TrapCam timed out
# ----------------------------------------
if [ $? -ge 124 ]; then
	echo ""
	echo "TrapCam.sh timed out" |& tee -a "${rf}"

# ----------------------------------------
# Schedule next start-up
# ----------------------------------------
	echo "Start-up scheduled from shutdown_now.sh" |& tee -a "${rf}"
	# Check lights
	if [ -s /home/pi/nolights.txt ]; then
		if [ $(date +%s) -lt $(cat /home/pi/nolights.txt) ];then
			sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi \
				/home/pi/wittyPi/schedule.wpi
			sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
		else
			if [ $(date +%H) -ge 19 ] | [ $(date +%H) -lt 7 ]; then
				sudo cp /home/pi/wittyPi/schedules/TrapCam_5AM_wakeup.wpi \
					/home/pi/wittyPi/schedule.wpi
				sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
			else
				sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi \
					/home/pi/wittyPi/schedule.wpi
				sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
			fi
		fi
	else
		sudo cp /home/pi/wittyPi/schedules/TrapCam_duty_cycle.wpi \
			/home/pi/wittyPi/schedule.wpi
		sudo /home/pi/wittyPi/runScript.sh |& tee -a "${rf}"
	fi
fi

# ----------------------------------------
# Shutdown rPi
# ----------------------------------------
echo ""
read -s -p "rPi will shutdown in 5 sec. Press any key to stop..." -t 6

if [ $? -ge 128 ]; then
	echo "rPi shutdown at $(date)" |& tee -a "${rf}"
	echo "" |& tee -a "${rf}"

	sudo shutdown now -h
fi
