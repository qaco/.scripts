#!/bin/bash

# Assuming moc server is already running
# If not, do mocp -S

pl_path=$1
pl_ext=".m3u"
reprendre=">>"

pl=$(ls $pl_path | grep $pl_ext | sed -e 's/^/FALSE /' | sort)

choix=$(zenity --list --radiolist \
               --height=400 \
               --title="Choix de la playlist" \
               --column="" \
               --column="Playlist" \
               TRUE $reprendre $pl)

if [ $? = 0 ]
then
    if [ $choix = $reprendre ]
    then
        mocp -U
    else
        mocp -s
        choix="$pl_path$choix"
        mocp -c
        mocp -a $choix
        mocp -p
    fi   
fi
