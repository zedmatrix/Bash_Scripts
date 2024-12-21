#!/bin/bash
# Some of my Bash Scripts to Automate my Linux Environment
PicUpload() {
    curl --progress-bar -F"file=@$1" 0x0.st
}

mcd() {
	mkdir -pv "$1"
	cd "$1"
}

WATCH() {
  yt-dlp -o - "$1" | ffplay -
}

YTD() {
  yt-dlp "$*" --cookies-from-browser firefox
}

# ie. ListSort > playlist 
ListSort() {
    find . -name "*.mp4" -type f -printf '%T@ %p\n' | sort -r | cut -d' ' -f2-
}
# ie. Shuffle | sort > playlist
Shuffle() {
    find . -name "*.mp4" -type f | shuf -n 10
}

alias GO='time sh Batch.sh'
alias RADIO="mpv --volume=50 --loop-playlist --shuffle --playlist="
alias ls='ls --color=auto'
alias ll='ls -l'

export PATH=~/MyBin:$PATH
export -f mcd WATCH YTD ListSort Shuffle
# End of Profile_Addons.sh
