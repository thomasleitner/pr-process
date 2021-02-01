#!/bin/sh

if [ "$1" = "" ]; then
    echo "Usage: decode-all.sh json-file"
    exit 1
fi

MQTT_BROKER=192.168.1.4
MQTT_TOPIC=powerrouter
INFLUXDB_HOST='http://xxxxxxxxxxxxxxxxxxxxxxxx:8086/api/v2/write?org=MYORG&bucket=MYDB'
INFLUXDB_TOKEN="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"

FILE=$1
if [ ! -r $FILE ]; then
    echo "ERROR: cannot find $FILE"
    exit 1
fi

#cp $FILE /mytmp/test

fgrep param_0 $FILE >/dev/null
if [ $? -ne 0 ]; then
    exit 1
fi

export IFS=","
CDATA=/mytmp/$$.cdata
rm -f $CDATA

EXPORT_FILE=$HOME/pr-data/`date +%Y%m%d`.csv
touch $EXPORT_FILE
NEW_EXPORT_FILE=1
if [ -s $EXPORT_FILE ]; then
    NEW_EXPORT_FILE=0
fi

HEADER=/mytmp/$$.header
DATA=/mytmp/$$.data
rm -f $HEADER $DATA

DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
printf "DATE;TIME" >$HEADER
printf "$DATE;$TIME" >$DATA

cat pr-data.dat | while read mod param var div; do
    val=`sh decode.sh $FILE $mod $param`
    if [ "$val" = ""]; then
        continue;
    fi
    val=`echo $val $div | awk '{ print $1 / $2 }'`
    echo $mod, $param, $var = $val
    if [ "$var" != "" ]; then
        mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/$var -m $val
        echo "$var,site_name=Powerrouter value=$val" >>$CDATA
    fi
    if [ -s "$HEADER" ]; then
        printf ";$var" >>$HEADER
        printf ";$val" >>$DATA
    else
        printf "$var" >>$HEADER
        printf "$val" >>$DATA
    fi
done

E1=`sh get-var.sh $FILE E_GRID1`
E2=`sh get-var.sh $FILE E_GRID2`
E3=`sh get-var.sh $FILE E_GRID3`
E_GRID_TOTAL=`expr $E1 + $E2 + $E3`
echo E_GRID_TOTAL=$E_GRID_TOTAL
mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/E_GRID_TOTAL -m $E_GRID_TOTAL
echo "E_GRID_TOTAL,site_name=Powerrouter value=$E_GRID_TOTAL" >>$CDATA
printf ";E_GRID_TOTAL"  >>$HEADER
printf ";$E_GRID_TOTAL" >>$DATA

S1=`sh get-var.sh $FILE E_SOLAR1_PRODUCED`
S2=`sh get-var.sh $FILE E_SOLAR2_PRODUCED`
E_SOLAR_TOTAL=`expr $S1 + $S2`
echo E_SOLAR_TOTAL=$E_SOLAR_TOTAL
mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/E_SOLAR_TOTAL -m $E_SOLAR_TOTAL
echo "E_SOLAR_TOTAL,site_name=Powerrouter value=$E_SOLAR_TOTAL" >>$CDATA
printf ";E_SOLAR_TOTAL\n"  >>$HEADER
printf ";$E_SOLAR_TOTAL\n" >>$DATA

# post to InfluxDB

curl -i -XPOST "$INFLUXDB_HOST" \
    --header "Authorization: Token $INFLUXDB_TOKEN" \
    --data-binary "@$CDATA"

rm -f $CDATA

# write CVS logfile

if [ $NEW_EXPORT_FILE -eq 1 ]; then
    cat $HEADER >$EXPORT_FILE
fi
# if you use "," as a decimal point use this statement, otherwise use the next
cat $DATA | sed -e 's/\./,/g' >>$EXPORT_FILE
#cat $DATA  >>$EXPORT_FILE
rm -f $HEADER $DATA

exit 0

# end of file
