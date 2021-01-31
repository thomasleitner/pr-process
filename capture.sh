#!/bin/sh

TMP=/mytmp/$$.dat

while true ; do
    n=`ls /mytmp/pr*.dat 2>/dev/null | wc -l`
    if [ $n -eq 0 ]; then
        sleep 5 ;
        continue
    fi
    for f in /mytmp/pr*.dat ; do
        sleep 2
        grep '}]}' $f >/dev/null
        if [ $? -ne 0 ]; then
            grep '"event":' $f >/dev/null
            if [ $? -ne 0 ]; then
                #mv $f /mytmp/rejected
                rm $f
                continue;
            fi 
        fi
        grep '{' $f >$TMP.1 
        if [ $? -ne 0 ]; then
            #mv $f /mytmp/rejected
            rm $f $TMP.1
            continue
        fi
        sh decode-all.sh $TMP.1
        rm -f $f
        echo $f processed
    done
    rm -f $TMP $TMP.1
done
