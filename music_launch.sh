#!/bin/bash

path="$HOME/.playlists.d/"
backup="$path.playlists"
ext=".m3u"

#############################
# Launch MOC if not running #
#############################

if [ $(ps -ef | grep -v grep | grep -cw mocp) -eq 0 ];then
    mocp -S
fi

##################################
# Check the available choices #
##################################

lists=$(ls $path | grep $ext | sort)
formers=$(comm -12 --nocheck-order <(echo "$lists") <(cat "$backup"))

# I have a backup file : I fetch previously selected playlists and
# select them today.
if [ $(echo $"formers" | wc -l) -gt 0 ];then
    # Mark TRUE previously selected playlists
    while read -r former;do
	lists=$(echo "$lists" | sed "s/^$former/TRUE $former/")
    done <<< "$formers"
    # Mark FALSE the others playlists
    lists=$(echo "$lists" \ | sed '/^TRUE/! s/^/FALSE /')
    
    # I have no backup file : I select the first playlist I see.
else
    lists=$(echo "$lists" \ | sed -e '1 s/^/TRUE /' -e '2,$s/^/FALSE /')
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

if [ $? = 0 ];then
    
    mocp -s # stop currently playing music
    mocp -c # clear current playlist

    # Add each playlist displaying progress bar
    percent=0
    choices=$(echo $choices | tr "|" "\n")
    delta=$(( 100 / $(echo "$choices" | wc -l) ))
    echo "$choices" > $backup # Backup the selection
    (for choice in $choices;do
	 echo "#Ajout de $choice"
	 mocp -a "$path$choice" # add each playlist
	 percent=$(( $percent + $delta ))
	 echo "$percent"
     done) |
	zenity --progress \
	       --title="Ajout des playlists" \
	       --text="Ajout des playlists" \
	       --percentage=$percent \
	       --auto-close
    
    mocp -p # play
fi
