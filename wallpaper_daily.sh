#!/bin/bash

cd /tmp
MYURL=$(curl https://awallpaperaday.com/ | grep -a2 "<a class=\"post-preview" -m 1 | grep -o "https.*\.jpg")
wget $MYURL
MYFILE=$(echo "$MYURL" | grep -o "[^/]*\.jpg")
gsettings set org.mate.background picture-filename "/tmp/$MYFILE"
echo "$MYURL" >> /tmp/wallpapers.history
