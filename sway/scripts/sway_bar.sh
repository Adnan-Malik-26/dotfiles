#!/bin/sh
i=1
date_formatted(){
    date_formatted=$(date +' %d.%m.%Y    %H:%M')
}

volume(){
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}')
    if [[ $(pactl get-sink-mute @DEFAULT_SINK@) = "Mute: no" ]];
    then
        mute=""
    else
        mute=""
    fi
}
memory(){
    memory=" $(free -m | grep Mem | awk '{print int(($3/$2)*100)}')%"
}
network(){
    if [[ $(iwctl station wlp2s0 show | grep "State" | awk '{ print $2 }') = "connected" ]];
    then
        ip="󰩟 $(iwctl station wlp2s0 show | grep "IPv4" | awk '{ print $3 }')"
        network_icon="󰖩"
        network=$(iwctl station wlp2s0 show | grep "Connected network" | awk '{ print $3 }')
    else
        ip=""
        network_icon=""
        network=""
    fi
}
battery(){
    battery="$(cat /sys/class/power_supply/BAT1/capacity)"
    if [[ $(cat /sys/class/power_supply/BAT1/status) = "Charging" ]];
    then
        if [[ i -lt $# ]]
        then
            battery_icon=${!i}
            ((i++))
        else
            battery_icon=${!i}
            i=1
        fi
    elif [[ $battery -eq 100 ]];
    then
        i=$#
        battery_icon=${!i}
    else
        i=$((5*$battery/100))
        ((i++))
        battery_icon=${!i}
    fi
}

while true
do
    date_formatted
    volume
    memory
    network
    battery     
    echo " $ip   $network_icon $network   $battery_icon $battery%   $memory   $mute $volume   $date_formatted "
    sleep 2
done
