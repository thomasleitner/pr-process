#!/bin/sh
export IFS=","
grep $2 pr-data.dat | ( read mod param var ;
    if [ "$mod" != "" ]; then
        sh decode.sh $1 $mod $param
    fi
)

