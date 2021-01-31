#!/bin/sh
cd /home/pi/pr-process
pidof -x capture.sh >/dev/null
if [ $? -ne 0 ]; then
    nohup ./capture.sh </dev/null >/dev/null 2>&1 &
    echo capture.sh started
fi
