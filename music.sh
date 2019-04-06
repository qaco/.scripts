#!/bin/bash

readonly LAUNCH="-l"
readonly TOGGLE="-p"
readonly SKBACK="-b"
readonly SKNEXT="-f"
readonly MYSONG="-s"
readonly HELPME="-h"

readonly VIEWER="zenity"
readonly PLAYER="mocp"
readonly CMD_LAUNCH="$PLAYER -S"
readonly CMD_STOP="$PLAYER -s"
readonly CMD_CLEAR="$PLAYER -c"
readonly CMD_ADD="$PLAYER -a"
readonly CMD_PLAY="$PLAYER -p"
readonly CMD_PREV="$PLAYER -r"
readonly CMD_NEXT="$PLAYER -f"
readonly CMD_TOGGLE="$PLAYER -G"
readonly CMD_INFO="$PLAYER -i"

wrong_input () {
    local help=$(printf \
		     '%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n' \
		     "Usage: $0 [OPTIONS]" \
		     "Options:" \
		     "  $LAUNCH    Launch playlists" \
		     "  $TOGGLE    Toggle play/pause" \
		     "  $SKBACK    Skip backward" \
		     "  $SKNEXT    Skip forward" \
		     "  $MYSONG    Current song" \
		     "  $HELPME    Help" \
		     "Dependencies:" \
		     "  $PLAYER" \
		     "  $VIEWER")
    
    echo "$help" 2>&1
    exit 0
}

my_launcher () {
    local -r path="$HOME/.playlists.d/"
    local -r backup="$path.playlists"
    local -r ext=".m3u"
    local -r winheight=300

    #############################
    # Launch MOC if not running #
    #############################

    if [ $(ps -ef | grep -v grep | grep -cw mocp) -eq 0 ];then
	$CMD_LAUNCH
    fi

    ##################################
    # Check the available choices #
    ##################################
    local lists=$(ls $path | grep $ext | sort)
    local -r formers=$(comm -12 --nocheck-order \
			    <(echo "$lists") \
			    <(cat "$backup"))

    if [ $(echo $lists | wc -l) -eq 0 ] ; then
	local -r message="Aucun fichier $ext dans $path !"
	zenity --error \
	       --text="$message"
	exit 0
    fi
    
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
    local choices=$(zenity \
			--window-icon=question \
			--list --checklist \
			--height="$winheight" \
			--title="Choix de la playlist" \
			--column="" \
			--column="Playlist" \
			$lists)

    ######################
    # Handle his choices #
    ######################
    if [ $(echo "$choices" | wc -w) -eq 0 ];then
	exit 1
    fi

    local percent=0
    local delta
    
    $CMD_STOP
    $CMD_CLEAR # clear current playlist

    # Add each playlist displaying progress bar
    choices=$(echo $choices | tr "|" "\n")
    delta=$(( 100 / $(echo "$choices" | wc -l) ))

    if [ "$choices" != "$formers" ];then
	echo "$choices" > $backup # Backup the selection
    fi
    (for choice in $choices;do
	 echo "#Ajout de $choice"
	 $CMD_ADD "$path$choice" # add each playlist
	 percent=$(( $percent + $delta ))
	 echo "$percent"
     done) |
	zenity --progress \
	       --title="Ajout des playlists" \
	       --text="Ajout des playlists" \
	       --percentage=$percent \
	       --auto-close
    
    $CMD_PLAY
}

current_song () {
    local song=$($CMD_INFO)
    
    if [ $(echo "$song" | wc -l) -le 1 ];then
	zenity --error --text="Pas de chanson en cours de lecture !"
    else
	song=$(echo "$song" | sed -n '4,6 p' | cut --complement -d ' ' -f 1)
	zenity --info --title="Lecture" --text="$song"
    fi
    }

if  [ "$#" -ne 1 ] \
	|| [ $(command -v "$VIEWER" | wc -l) -eq 0 ] \
	|| [ $(command -v "$PLAYER" | wc -l) -eq 0 ];then
    wrong_input
fi

case "$1" in
    "$LAUNCH")
	my_launcher
	;;
    "$SKBACK")
	$CMD_PREV
	;;
    "$SKNEXT")
	$CMD_NEXT
	;;
    "$TOGGLE")
	$CMD_TOGGLE
	;;
    "$MYSONG")
	current_song
	;;
    *)
	wrong_input
	;;
esac
