#!/bin/bash

_reset="\e[0m"
_blue="\e[34m"
_green="\e[32m"
print() { printf "*** ${_green} %s ***" "$*"; printf "${_reset}\n"; }
printdash() { printf "${_blue}"; printf "%.s=" {1..30}; printf "${_reset}\n"; }

Encode () {
  log="-loglevel error -stats"
  vcodec="-c:v copy"
  acodec="-c:a aac -b:a 192k -ac 2"
  loud="loudnorm=I=-10:LRA=12:TP=-1.0"

  ffmpeg ${log} -i "${input}" ${vcodec} -af "${loud}" ${acodec} "${output}"
  print " Finished "
  printdash
}
path="${PWD}"
input="$1"

duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${input}" | cut -d '.' -f 1)

hour=$((duration / 3600))
mins=$(( (duration % 3600) / 60 ))
sec=$((duration % 60))
duration=$(printf "%02d:%02d:%02d" "${hour}" "${mins}" "${sec}")

# Extract file 'extension' only
filename="${input%.*}"
extension="${input##*.}"
printdash
printf '%s %s \nDuration:%s \n' "${filename}" ${extension} ${duration}

input="${path}/${filename}.${extension}"
output=$(echo "${filename}" | sed 's/ \[[^]]*\]//')
output="${path}/remux/${output}.mp4"

if [ -d "${path}/remux" ]; then
  print "Directory Exists"
else
  print "Creating"
  mkdir -v "${path}/remux/"
fi

print "Input=${input}"
print "Output=${output}"
Encode
