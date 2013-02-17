#!/usr/bin/bash

sinks=$(pacmd list-sinks | grep index | awk '{ if ($1 == "*") print "1"; else print "0" }')
sink_names=$(pacmd list-sinks | awk -F: '/description/ {ORS=";"; getline; split($0,a," = "); print a[2]}')
inputs=$(pacmd list-sink-inputs | grep index | awk '{print $2}')

#find active sink and count available sinks
active=0
sink_count=0
for i in ${sinks}
do
    if [ $i -eq 1 ]; then active=$sink_count; fi
    sink_count=$(($sink_count+1))
done

# Set new sink id
new=$(($active+1))

# Setup last allowed sink+1 for if purposes,
# if its the last sink then set new sink id to 0 to enable looping through the list
last_sink=$sink_count
if [ $new -eq $last_sink ]; then new=0; fi


OIFS=$IFS;
IFS=";";
c=0
# Ugly workaround to not being able to get ${sink_names[$new]} to work @ 07:36 AM
for device in ${sink_names}
do
    if [ $new -eq $c ]
        then
            notify-send -u low -i audio-volume-medium-symbolic "Sound output changed: $device"
            break
    fi
    c=$(($c+1))
done
IFS=$OIFS;

pacmd set-default-sink $new > /dev/null
for i in ${inputs}
do
    pacmd move-sink-input $i $new > /dev/null
done