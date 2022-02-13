#!/bin/bash
while true
do
    globalTime="";
    globalUnit="";

#Set total seconds to full/empty as per unit(hours or minutes)
    getSeconds() {
        t=$1;
        u=$2;
        
        #timeValue=${t%%[[:space:]]*};
        #unit=${t##*[[:space:]]};
        globalTime=$t;
        globalUnit=$u;
        
        hour=3600;
        minute=60;

        if test $u == "hours";
        then
            globalTime=$(echo "$globalTime*$hour"| bc);
            echo $globalTime;
        else
            if test $u == "minutes";
            then
                globalTime=$(echo "$globalTime*$minute"| bc);
            fi
        fi

    }

#get battery stats from upower commands
    charge=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1| grep -E "percentage");
    empty=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1| grep -E "to\ empty");
    full=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1| grep -E "to\ full");

    level=${charge:15:-1};
    empty=${empty:19};

    if [ -z ${empty+x} ];
    then
        full=${full:19}
        
        if [ -z ${full+x} ];
        then
            sleep 600;
            continue;
        fi

        getSeconds "$full";
        timeToFull=$globalTime;
        echo "Sleeping for $timeToFull seconds";
        sleep $timeToFull;
    else
        getSeconds $empty;
        thirty=30;
        timeToThirty=$(echo "($globalTime*$thirty)/$level"| bc);


        if test $level -lt 30;
        then
            notify-send -u critical "Please charge battery $level%";
            sleep 1800;
        else
            echo "Sleeping for $timeToThirty seconds";
            sleep $timeToThirty;
        fi
    fi
done
