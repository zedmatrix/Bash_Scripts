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

1080 () {
  #crop=(crop=1920-70:1080-32:35:16)
  aspect="16/9"
  scale=(scale=1920:1080:flags=lanczos,setsar=${aspect},setdar=${aspect})
}

720 () {
  #crop=(crop=1280-60:720-30:30:15)
  scale=(scale=1280:720:flags=lanczos,setsar=16/9,setdar=16/9)
}
# Function Encode Requires $input $output $title
Encode () {
  log=(-loglevel error -stats)
  1080
  vcodec=(-c:v hevc_nvenc -profile:v main)
  vbv=( -b:v 8M -maxrate 10M -bufsize 2M -r 60000/1001)
  denoise=(hqdn3d=2:1:2:2)
  deint=(bwdif)
  acodec=(-c:a aac -b:a 192k -ac 2)
  loud=(loudnorm=I=-10:LRA=12:TP=-1.0)
  meta=(-metadata title="${title}")

  print_red ${scale[@]}

  time ffmpeg "${log[@]}" -i "${input}" \
  -vf "${deint[@]},${denoise[@]},${scale[@]}" ${vbv[@]} ${vcodec[@]} \
  -af ${loud[@]} ${acodec[@]} "${meta[@]}" "${output}"

  #echo "${log[@]}" -i "${input}" -vf "${crop[@]},${scale[@]}" ${vcodec[@]} ${vbv[@]} -af ${loud[@]} ${acodec[@]} ${meta[@]} "${output}"
}
String () {
  channels=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$input" | head -1)
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input" | cut -d '.' -f 1)

  hour=$((duration / 3600))
  mins=$(( (duration % 3600) / 60 ))
  sec=$((duration % 60))
  duration=$(printf "%02d:%02d:%02d" ${hour} ${mins} ${sec} )

  IFS='-' read -r part1 part2 part3 _ <<< "$filename"
  fields="${part1} ${part2} ${part3} Upscale"
  #fields=$(echo "${filename}" | awk -F'-' '{printf ("%s %s %s",$1,$2,$3)}')
  #fields=$(echo "${fields}" | sed -e 's/_Edit.mp4//')
  #output=$(echo "${fields}" | sed -r -e 's/([ ])([0-9])/\1- \2/ ; s/_// ; s/_// ; s/_/- /3')
  title=$(echo "${fields} FFmpeg Hevc1080p" | sed -e 's/_//g')
  input="${path}/${filename}.${extension}"
  output=$(echo "${filename}" | sed 's/ \[[^]]*\]//')
  output="${path}/recode/${output}-UpScaled.mp4"
}

printdash
path="${PWD}"
input="$1"
filename="${input%.*}"
extension="${input##*.}"

if [ -d "${path}/recode" ]; then
  print_red " EXISTS "
else
  mkdir -v "${path}/recode"
fi

String

print_magenta "Path: ${path}"
print_green "Input: ${input#"$path"}"
print_blue "Duration: ${duration} Channels: ${channels}"
print_green "Output: ${output#"$path"}"
print_blue "Title: ${title} "

printdash
Encode
