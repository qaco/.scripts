#!/bin/bash

DIR="/home/hugo/Images/Wallpapers/Favoris"
CUR=$(gsettings get org.mate.background picture-filename | sed "s/'//g" | sed "s/\//\\n/g" | tail -n 1)
PIC=$(ls $DIR | grep -v "$CUR" | shuf -n1)
CMPL=$DIR/$PIC
gsettings set org.mate.background picture-filename "$CMPL"
