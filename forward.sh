#!/bin/sh
i=0
stdbuf -i0 -o0 -e0 socat -v tcp-l:80,fork,reuseaddr tcp:logging1-orig.powerrouter.com:80 2>&1 | \
    stdbuf -i0 -o0 -e0 fgrep '{"header"' | while read a ;
 do
    f=`printf pr%d.dat $i`
    echo $f
    echo "$a" | sed -e 's/<.*//g' >/mytmp/$f
    i=`expr $i + 1`
done
