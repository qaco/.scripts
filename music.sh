#!/bin/bash

path="$HOME/.playlists.d/"
backup="$path.playlists"
ext=".m3u"

launch="-l"
toggle="-p"
skback="-b"
sknext="-f"
mysong="-s"

help=$(printf '%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n' \
	      "Usage: $0 [OPTIONS]" \
	      "Options:" \
	      "  $launch    Launch playlists" \
	      "  $toggle    Toggle play/pause" \
	      "  $skback    Skip backward" \
	      "  $sknext    Skip forward" \
	      "  $mysong    Current song")

wrong_input () {
    echo "$help" 2>&1
    exit 0
}

my_launcher () {

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
}

if [ "$#" -ne 1 ];then
    wrong_input
fi

case "$1" in

    "$launch")
	my_launcher
	;;
    
    "$skback")
	mocp -r
	;;

    "$sknext")
	mocp -f
	;;

    "$toggle")
	mocp -G
	;;
    
    "$mysong")
	if [ $(mocp -i | wc -l) -le 1 ];then
	    zenity --error --text="Pas de chanson en cours de lecture !"
	else
	    song=$(mocp -i | sed -n '4,6 p' | cut --complement -d ' ' -f 1)
	    zenity --info --title="Lecture" --text="$song"
	fi
	;;
    *)
	wrong_input
	;;
esac
