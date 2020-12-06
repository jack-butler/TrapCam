#!/bin/bash

# schedule_duty_cycle.sh

# Author: Jack Butler
# Created: Apr 2020
# Last Edit: J Butler Apr 2020
# Edit Comments: Fixes wittypi 3 directory issue

# -----------------------------------------------------------------------
# Schedule next start-up
# -----------------------------------------------------------------------
rf="run.log"

echo "" |& tee -a "${rf}"
echo "Scheduling next start-up..." |& tee -a "${rf}"

sudo cp /home/pi/wittypi/schedules/TrapCam_duty_cycle.wpi /home/pi/wittypi/schedule.wpi
sudo /home/pi/wittypi/runScript.sh |& tee -a "${rf}"
