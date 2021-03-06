#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

readonly LAUNCH="-l"
readonly TOGGLE="-p"
readonly REPEAT="-r"
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
readonly CMD_TIME="$PLAYER -Q %cs"
readonly CMD_REPEAT="$PLAYER -k -$($CMD_TIME)"
readonly CMD_INFO="$PLAYER -Q %song\\n%artist\\n%album"

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
    local -r PATH_D="$HOME/.playlists.d/"
    local -r BACKUP="$PATH_D.history"
    local -r EXT=".m3u"
    local -r WIN_HEIGHT=300

    ## Launch the player if not running yet
    
    if [ $(ps -ef | grep -v grep | grep -cw "$PLAYER") -eq 0 ];then
	$CMD_LAUNCH
    fi

    ## Read the playlists directory
    
    local lists=$(ls $PATH_D | grep $EXT | sort)
    if [ $(echo $lists | wc -l) -eq 0 ] ; then
	local -r message="Aucun fichier $EXT dans $PATH_D !"
	zenity --error \
	       --text="$message"
	exit 0
    fi

    ## Preselect some choices
    
    local -r FORMERS=$(comm -12 --nocheck-order \
			    <(echo "$lists") \
			    <(cat "$BACKUP"))
    if [ $(echo $"FORMERS" | wc -l) -gt 0 ];then
	while read -r former;do
	    lists=$(echo "$lists" | sed "s/^$former/TRUE $former/")
	done <<< "$FORMERS"
	lists=$(echo "$lists" \ | sed '/^TRUE/! s/^/FALSE /')
    else
	lists=$(echo "$lists" \ | sed -e '1 s/^/TRUE /' -e '2,$s/^/FALSE /')
    fi

    ## Let the user choose
    
    local choices=$(zenity \
			--window-icon=question \
			--list --checklist \
			--height="$WIN_HEIGHT" \
			--title="Choix de la playlist" \
			--column="" \
			--column="Playlist" \
			$lists)

    ## Smooth & backup his choices
    
    if [ $(echo "$choices" | wc -w) -eq 0 ];then
	exit 1
    fi
    choices=$(echo $choices | tr "|" "\n")
    if [ "$choices" != "$FORMERS" ];then
	echo "$choices" > $BACKUP
    fi
    
    ## Apply his choices
    
    local -r DELTA=$(( 100 / $(echo "$choices" | wc -l) ))
    local percent=0
    $CMD_STOP
    $CMD_CLEAR
    (for choice in $choices;do
	 echo "#Ajout de $choice"
	 $CMD_ADD "$PATH_D$choice"
	 percent=$(( $percent + $DELTA ))
	 echo "$percent"
     done) |
	zenity --progress \
	       --title="Ajout des playlists" \
	       --text="Ajout des playlists" \
	       --percentage=$percent \
	       --auto-close
    
    $CMD_PLAY
}

previous_song () {
    local -r DELTA=2
    local -r MYTIME=$($CMD_TIME)

    if [ $(echo "$MYTIME") -gt "$DELTA" ];then
	$CMD_REPEAT
    else
	$CMD_PREV
    fi
}

current_song () {
    local song=$($CMD_INFO)
    
    if [ $(echo "$song" | wc -w) -eq 0 ];then
	zenity --error --text="Pas de chanson en cours de lecture !"
    else
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
    "$TOGGLE")
	$CMD_TOGGLE
	;;
    "$SKBACK")
	previous_song
	;;
    "$SKNEXT")
	$CMD_NEXT
	;;
    "$MYSONG")
	current_song
	;;
    *)
	wrong_input
	;;
esac
