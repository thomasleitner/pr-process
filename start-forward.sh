#!/bin/sh
cd /home/pi/pr-process
pidof -x forward.sh >/dev/null
if [ $? -ne 0 ]; then
    nohup ./forward.sh </dev/null >/dev/null 2>&1 &
    echo `date`: forward.sh started >>start-forward.log
fi
