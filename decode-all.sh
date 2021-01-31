#!/bin/sh

if [ "$1" = "" ]; then
    echo "Usage: decode-all.sh json-file"
    exit 1
fi

MQTT_BROKER=192.168.1.4
MQTT_TOPIC=powerrouter
INFLUXDB_HOST='http://xxxxxxxxxxxxxxxxxxx:8086/api/v2/write?org=MYORG&bucket=MYDB'
INFLUXDB_TOKEN="yyyyyyyyyyyyyyyyyyyyyyyyyyyy"

FILE=$1
if [ ! -r $FILE ]; then
    echo "ERROR: cannot find $FILE"
    exit 1
fi
export IFS=","
CDATA=/mytmp/$$.cdata
rm -f $CDATA
cat pr-data.dat | while read mod param var ; do
    val=`sh decode.sh $FILE $mod $param`
    echo $mod, $param, $var = $val
    if [ "$var" != "" ]; then
        mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/$var -m $val
        echo "$var,site_name=Powerrouter value=$val" >>$CDATA
    fi
done

E1=`sh get-var.sh $FILE E_GRID1`
E2=`sh get-var.sh $FILE E_GRID2`
E3=`sh get-var.sh $FILE E_GRID3`
E_GRID_TOTAL=`expr $E1 + $E2 + $E3`
echo E_GRID_TOTAL=$E_GRID_TOTAL
mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/E_GRID_TOTAL -m $E_GRID_TOTAL
echo "E_GRID_TOTAL,site_name=Powerrouter value=$E_GRID_TOTAL" >>$CDATA

S1=`sh get-var.sh $FILE E_SOLAR1_PRODUCED`
S2=`sh get-var.sh $FILE E_SOLAR2_PRODUCED`
E_SOLAR_TOTAL=`expr $S1 + $S2`
echo E_SOLAR_TOTAL=$E_SOLAR_TOTAL
mosquitto_pub -h $MQTT_BROKER -t $MQTT_TOPIC/E_SOLAR_TOTAL -m $E_SOLAR_TOTAL
echo "E_SOLAR_TOTAL,site_name=Powerrouter value=$E_SOLAR_TOTAL" >>$CDATA

# post to InfluxDB

curl -i -XPOST "$INFLUXDB_HOST" \
    --header "Authorization: Token $INFLUXDB_TOKEN" \
    --data-binary "@$CDATA"

rm -f $CDATA

exit 0

# end of file
