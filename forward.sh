#!/bin/sh
i=0
stdbuf -i0 -o0 -e0 socat tcp-l:80,fork,reuseaddr - | \
    stdbuf -i0 -o0 -e0 fgrep '{"header"' | while read a ;
 do
    f=`printf pr%d.dat $i`
    echo $f
    echo "$a" | sed -e 's/<.*//g' | sed -e 's/POST.*$//g' >/mytmp/$f
    i=`expr $i + 1`
done
