#!/bin/bash

# Launch MOC if not running
if [ $(ps -ef | grep -v grep | grep -cw mocp) -eq 0 ]
then
    mocp -S
fi

path="/home/hugo/.playlists.d/"
backup="$path.playlists"
ext=".m3u"
lists=$(ls $path | grep $ext | sort)

##################################
# Checking the available choices #
##################################

if [ -f "$backup" ]
   
   # I have a backup file : I fetch previously selected playlists and
   # select them today.
then
    for former in $(cat $backup)
    do
	lists=$(echo "$lists" | sed -e "s/^$former/TRUE $former/")
    done
    lists=$(echo "$lists" \ | sed -e '/^TRUE/! s/^/FALSE /')
    
    # I have no backup file : I select the first playlist I see.
else
    lists=$(echo "$lists" \ | sed -e '1 s/^/TRUE /' | sed -e '2,$s/^/FALSE /')
fi

#######################
# Let the user choose #
#######################

choices=$(zenity \
	      --window-icon=question \
              --list --checklist \
              --height=400 \
              --title="Choix de la playlist" \
              --column="" \
              --column="Playlist" \
	      $lists)

######################
# Handle his choices #
######################

if [ $? = 0 ]
then
    choices=$(echo $choices | tr "|" "\n")
    echo "$choices" > $backup # Backup the selection
    mocp -s # stop currently playing music
    mocp -c # clear current playlist
    for choice in $choices
    do
	selection="$path$choice"
	mocp -a $selection # add each playlist
    done
    mocp -p # play
fi
