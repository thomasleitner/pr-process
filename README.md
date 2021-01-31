# pr-process
Raspberry Pi bash scripts to receive data from a NEDAP Powerrouter inverter and publish it on an MQTT broker and Influx DB database.

Some hints for the installation:

* Raspberry PI needs to LAN interfaces:
    1.) one connected directly to the Powerrouter
    2.) one connected the a LAN with internet access
* Configuration of the LAN interfaces as described here: https://github.com/trebb/p-rout
* Processes are started via crontab entries like so:
```
* * * * * /home/pi/pr-process/start-forward.sh >/dev/null 2>&1 </dev/null
* * * * * /home/pi/pr-process/start-capture.sh >/dev/null 2>&1 </dev/null
```
* logging1.powerrouter.com is entered in /etc/hosts to resolve to the IP of the local powerrouter ethernet interface
* logging1-orig.powerrouter.com is entered in /etc/hosts to resolve to 217.114.110.59
* /mytmp is a temporary directory in a RAM disk to save writes on the Raspberry PI SD Card. It's created in FSTAB with
  the following entry:
```
tmpfs           /mytmp          tmpfs   nodev,nosuid,size=5M 0    0
```
Enjoy!
