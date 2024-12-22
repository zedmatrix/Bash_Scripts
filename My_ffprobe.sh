#!/bin/bash
_reset="\033[0m"
_cyan="\033[1;36m"
printdash() { printf "${_cyan}"; printf "%.s=" {1..30}; printf "${_reset}\n"; }

[ -z "$1" ] && { echo "Error: Need Input File."; exit 1; }
input="$1"

GetFormat() {
    # Simple Formatting -show_format
    entries=$(ffprobe -hide_banner -loglevel error -show_error -print_format json -show_format "$input")
    json_output="${entries[@]}"
    filename=$(echo "$json_output" | jq -r '.format.filename')
    streams=$(echo "$json_output" | jq -r '.format.nb_streams')
}

GetStreams() {
    # Stream Formatting codec_long_name, width, height, duration_ts, duration, sample_aspect_ratio, display_aspect_ratio
    entries=$(ffprobe -hide_banner -loglevel fatal -show_error -select_streams 0 -show_entries streams -print_format json "$input")
    json_output="${entries[@]}"
#     vcodec=$(echo "$json_output" | jq -r '.streams[0].codec_long_name')
#     duration=$(echo "$json_output" | jq -r '.streams[0].duration' | cut -d '.' -f 1)
#     width=$(echo "$json_output" | jq -r '.streams[0].width')
#     height=$(echo "$json_output" | jq -r '.streams[0].height')
#     SAR=$(echo "$json_output" | jq -r '.streams[0].sample_aspect_ratio')
#     DAR=$(echo "$json_output" | jq -r '.streams[0].display_aspect_ratio')
}

GetAudio() {
    entries=$(ffprobe -hide_banner -loglevel fatal -show_error -select_streams a:0 -show_entries streams -print_format json "$input")
    json_output="${entries[@]}"
    acodec=$(echo "$json_output" | jq -r '.streams[0].codec_long_name')
    aduration=$(echo "$json_output" | jq -r '.streams[0].duration' | cut -d '.' -f 1)
    sample_rate=$(echo "$json_output" | jq -r '.streams[0].sample_rate')
    channels=$(echo "$json_output" | jq -r '.streams[0].channels')
    sample_rate=$((sample_rate / 1000))
}

GetVideo() {
    entries=$(ffprobe -hide_banner -loglevel fatal -show_error -select_streams v:0 -show_entries streams -print_format json "$input")
    json_output="${entries[@]}"
    vcodec=$(echo "$json_output" | jq -r '.streams[0].codec_long_name')
    vduration=$(echo "$json_output" | jq -r '.streams[0].duration' | cut -d '.' -f 1)
    width=$(echo "$json_output" | jq -r '.streams[0].width')
    height=$(echo "$json_output" | jq -r '.streams[0].height')
    SAR=$(echo "$json_output" | jq -r '.streams[0].sample_aspect_ratio')
    DAR=$(echo "$json_output" | jq -r '.streams[0].display_aspect_ratio')
#     echo $json_output | jq -C
#     printdash
}

GetVideo
hour=$((vduration / 3600))
mins=$(((vduration % 3600) / 60 ))
sec=$((vduration % 60))
vduration=$(printf "%02d:%02d:%02d" ${hour} ${mins} ${sec} )

GetAudio
hour=$((aduration / 3600))
mins=$(((aduration % 3600) / 60 ))
sec=$((aduration % 60))
aduration=$(printf "%02d:%02d:%02d" ${hour} ${mins} ${sec} )

GetFormat
#GetStreams


printdash
# Output the extracted values
echo "Filename: $filename"
echo "Video: $vcodec"
echo "Resolution: $width x $height"
echo "Aspect Ratio: ${SAR/:/\/} and ${DAR/:/\/}"
echo "Audio: $acodec $sample_rate Khz with $channels channels"
echo "Streams: $streams"
echo "Duration: $vduration / $aduration"
printdash
