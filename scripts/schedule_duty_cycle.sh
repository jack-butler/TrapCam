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
uhome="$(eval echo \"/home/$(dir /home)\")"
#uhome="$(getent passwd $SUDO_USER | cut -d: -f6)"

echo "" |& tee -a "${rf}"
echo "Scheduling next start-up..." |& tee -a "${rf}"

sudo cp $uhome/wittypi/schedules/TrapCam_duty_cycle.wpi $uhome/wittypi/schedule.wpi
sudo $uhome/wittypi/runScript.sh |& tee -a "${rf}"
