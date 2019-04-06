#!/bin/bash

readonly launch="-l"
readonly toggle="-p"
readonly skback="-b"
readonly sknext="-f"
readonly mysong="-s"
readonly helpme="-h"
readonly player="moc"
readonly viewer="zenity"

wrong_input () {
    local help=$(printf \
		     '%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n' \
		     "Usage: $0 [OPTIONS]" \
		     "Options:" \
		     "  $launch    Launch playlists" \
		     "  $toggle    Toggle play/pause" \
		     "  $skback    Skip backward" \
		     "  $sknext    Skip forward" \
		     "  $mysong    Current song" \
		     "  $helpme    Help" \
		     "Dependencies:" \
		     "  $player" \
		     "  $viewer")
    
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
	mocp -S
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
    
    mocp -s # stop currently playing music
    mocp -c # clear current playlist

    # Add each playlist displaying progress bar
    choices=$(echo $choices | tr "|" "\n")
    delta=$(( 100 / $(echo "$choices" | wc -l) ))

    if [ "$choices" != "$formers" ];then
	echo "$choices" > $backup # Backup the selection
    fi
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
}

current_song () {
    local song=$(mocp -i)
    
    if [ $(echo "$song" | wc -l) -le 1 ];then
	zenity --error --text="Pas de chanson en cours de lecture !"
    else
	song=$(echo "$song" | sed -n '4,6 p' | cut --complement -d ' ' -f 1)
	zenity --info --title="Lecture" --text="$song"
    fi
    }

if  [ "$#" -ne 1 ] \
	|| [ $(command -v "$viewer" | wc -l) -eq 0 ] \
	|| [ $(command -v "$player" | wc -l) -eq 0 ];then
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
	current_song
	;;
    *)
	wrong_input
	;;
esac
