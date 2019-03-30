#!/bin/bash
# source :
# http://askubuntu.com/questions/237835/script-to-switch-between-two-sound-devices

#custom entre cat et tac : élimine les sorties hdmi
declare -i sinks=(`pacmd list-sinks | tac | sed 'N;/.name:.\+hdmi/d' | tac | sed -n -e 's/\**[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`)
declare -i sinks_count=${#sinks[*]}
declare -i active_sink_index=`pacmd list-sinks | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`
declare -i next_sink_index=${sinks[0]}

#find the next sink (not always the next index number)
declare -i ord=0
while [ $ord -lt $sinks_count ];
do
    if [ ${sinks[$ord]} -gt $active_sink_index ] ; then
	next_sink_index=${sinks[$ord]}
	break
    fi
    let ord++
done
#change the default sink
pacmd "set-default-sink ${next_sink_index}"

#move all inputs to the new sink
for app in $(pacmd list-sink-inputs | sed -n -e 's/index:[[:space:]]\([[:digit:]]\)/\1/p');
do
pacmd "move-sink-input $app $next_sink_index"
done
#needs libnotify
name=`pacmd list-sinks | sed '0,/\*/d' | grep -m 1 device.description | cut -d '"' -f2`
notify-send -t 2000 "sortie son" "$name"
