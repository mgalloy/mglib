#!/bin/sh

DATA_DIR=$HOME/data
BATTERY_LOG=$DATA_DIR/battery.log

DATE=`date +%s`
CYCLE_COUNT=`/usr/sbin/ioreg -l | grep \"CycleCount\" | sed -e 's/^[ |]*//' -e 's/\"//g'`
CAPACITY=`/usr/sbin/ioreg -l | egrep "(Max|Current|Design)Capacity" | sed -e 's/^[ |]*//' -e 's/\"//g' | tr '\n' ','`
echo "$DATE,$CAPACITY$CYCLE_COUNT" >> $BATTERY_LOG
