#!/bin/bash
_reset="\033[0m"
_red="\033[1;31m"
_green="\033[1;32m"
_yellow="\033[1;33m"
_blue="\033[1;34m"
_magenta="\033[1;35m"
_cyan="\033[1;36m"

printdash() { printf "${_cyan}"; printf "%.s=" {1..30}; printf "${_reset}\n"; }

print_magenta() { printf "${_magenta}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }
print_yellow() { printf "${_yellow}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }
print_green() { printf "${_green}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }
print_blue() { printf "${_blue}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }
print_cyan() { printf "${_cyan}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }
print_red() { printf "${_red}"; printf "*** %s ***" "$*"; printf "${_reset}\n"; }

Encode () {
  log=(-loglevel error -stats)
  meta=(-metadata title="${title}")
  map=(-map 0:v -map 0:a:1)
  vcodec=( -c:v copy)
  acodec=( -c:a aac -b:a 256k -ac 2)
  loud=(loudnorm=I=-14:LRA=12:TP=-1.25)

  case $channels in
    8)
      achan=("pan=stereo|FL=FC+0.30*FL+0.30*BL+0.30*SL+0.30*LFE|FR=FC+0.30*FR+0.30*BR+0.30*SR+0.30*LFE,")
      loudDmix=(-af ${achan}loudnorm=I=-14:LRA=12:TP=-1.25)
      ;;
    6)
      achan=("pan=stereo|FL=FC+0.30*FL+0.30*BL+0.30*LFE|FR=FC+0.30*FR+0.30*BR+0.30*LFE,")
      loudDmix=(-af ${achan}loudnorm=I=-14:LRA=12:TP=-1.25)
     ;;
    *)
      achan=""
      loudDmix=(-af loudnorm=I=-16:LRA=11:TP=-1.5)
      ;;
  esac
  #echo ${log[@]} -i "${input}" ${vcodec[@]} ${loudDmix[@]} ${acodec[@]} "${meta[@]}" "${output}"
  time ffmpeg ${log[@]} -i "${input}" ${vcodec[@]} ${loudDmix[@]} ${acodec[@]} "${output}"

}

path="${PWD}/"
input="$1"
filename="${input%.*}"
extension="${input##*.}"

input="${path}${filename}.${extension}"

IFS='-' read -r part1 part2 part3 _ <<< "$filename"
title="${part1} ${part2} ${part3} AudioFix"
#title=$(echo "${filename}" | awk -F'-' '{printf ("%s %s %s AudioFix",$1,$2,$3)}')

output="${filename}-AF.mp4"
output="${path}audiofix/${output}"

channels=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "${input}" | head -1)
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${input}" | cut -d '.' -f 1)

[ -z "${channels}" ] && { printf "${_red} Error: Failed to get Channels \n"; exit 1; }
[ -z "${duration}" ] && { printf "${_red} Error: Failed to get Duration \n"; exit 1; }

hour=$((duration / 3600))
mins=$(( (duration % 3600) / 60 ))
sec=$((duration % 60))
duration=$(printf "%02d:%02d:%02d" "${hour}" "${mins}" "${sec}")

if [ -d "${path}audiofix" ]; then
  printf "${_red} Directory Exists ${_reset} \n"
else
  mkdir -v "${path}audiofix/"
fi

printdash

print_magenta "Path: ${path}"
print_green "Input: ${input#"$path"}"
print_blue "Duration: ${duration} Channels: ${channels}"
print_green "Output: ${output#"$path"}"
print_blue "Title: ${title} "

printdash
Encode
