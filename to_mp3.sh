#!/bin/bash

find -name "*.flac" -exec sh -c 'ffmpeg -i "$1" -acodec libmp3lame -aq 4 "${1%.flac}.mp3" && rm -f "$1"' _ {} \;
