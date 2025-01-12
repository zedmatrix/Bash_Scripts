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
    if [[ -z $1 ]]; then
        find . -name "*.mp4" -type f | shuf -n 10
    elif [[ $1 =~ ^[0-9]+$ ]]; then
        find . -name "*.mp4" -type f | shuf -n "$1"
    else
        echo "Usage: Shuffle [number] > playlist.m3u"
    fi
}
# PlayLise Creator sort forward or reverse by creation date
PlayList() {
    if [[ $1 == "r" ]]; then
        find . -name "*.mp4" -type f -printf '%T@ %p\n' | sort -r | cut -d' ' -f2-
    elif [[ $1 == "n" ]]; then
        find . -name "*.mp4" -type f -printf '%T@ %p\n' | sort | cut -d' ' -f2-
    else
        echo "Usage: PlayList [r|n] > playlist.m3u"
    fi
}
# Helpful Aliases
alias GO='time sh Batch.sh'
alias RADIO="mpv --volume=60 --loop-playlist --shuffle --playlist="
alias ls='ls --color=auto'
alias ll='ls -l'

export PATH=~/MyBin:$PATH
export -f mcd WATCH YTD PlayList ListSort Shuffle
# End of Profile_Addons.sh
