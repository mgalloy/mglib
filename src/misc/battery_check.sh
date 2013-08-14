#!/bin/sh

# add this as a cron job to be run regularly

BATTERY_LOG=/Users/mgalloy/data/battery.log
date +%s >> $BATTERY_LOG
/usr/sbin/ioreg -l | grep \"CycleCount\" | sed -e 's/^[ |]*//' -e 's/\"//g' >> $BATTERY_LOG
/usr/sbin/ioreg -l | egrep "(Max|Current|Design)Capacity" | sed -e 's/^[ |]*//' -e 's/\"//g' >> $BATTERY_LOG
