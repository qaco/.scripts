#!/bin/bash

DIR="/home/hpompougnac/Images/Wallpapers/Favoris"
CUR=$(gsettings get org.mate.background picture-filename | sed "s/'//g" | sed "s/\//\\n/g" | tail -n 1)
PIC=$(find "$DIR" \( ! -regex '.*/\..*' \) -type f -name "*" | shuf -n1)
gsettings set org.mate.background picture-filename "$PIC"
echo "$PIC" >> /tmp/wallpapers.history
