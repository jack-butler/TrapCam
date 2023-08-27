#!/bin/bash
# file: syncTime.sh
#
# This script can syncronize the time between system and RTC
#

# delay if first argument exists
if [ ! -z "$1" ]; then
  sleep $1
fi

# include utilities script in same directory
my_dir="`dirname \"$0\"`"
my_dir="`( cd \"$my_dir\" && pwd )`"
if [ -z "$my_dir" ] ; then
  exit 1
fi
. $my_dir/utilities.sh


# if RTC presents
log 'Synchronizing time between system and Witty Pi...'

# get RTC time
rtctime="$(get_rtc_time)"
  
# if RTC time is OK, write RTC time to system first
if [[ $rtctime != *"1999"* ]] && [[ $rtctime != *"2000"* ]]; then
  rtc_to_system
fi