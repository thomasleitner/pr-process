#!/bin/sh
export IFS=","
grep $2 pr-data.dat | ( read mod param var div;
    if [ "$mod" != "" ]; then
        val=`sh decode.sh $1 $mod $param`
        echo $val $div | awk '{ print $1 / $2 }'
    fi
)

