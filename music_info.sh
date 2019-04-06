#!/bin/bash

if [ $(mocp -i | wc -l) -le 1 ];then
    zenity --error --text="Pas de chanson en cours de lecture !"
else
    song=$(mocp -i | sed -n '4,6 p' | cut --complement -d ' ' -f 1)
    zenity --info --title="Lecture" --text="$song"
fi
