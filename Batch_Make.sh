#!/bin/bash
# Usage # Batch_Make 
path=$PWD
audio=$1
pattern=$2

case $audio in
  D)
    printf 'DVD_Encode.sh \"%s\"\n' *.mp4 > Batch.sh
    ;;
  M)
    printf 'MP3_Encode.sh \"%s\"\n' *.$pattern > Batch.sh
    ;;
  N)
    printf 'Norm_Audio.sh \"%s\"\n' *.mp4 | sort > Batch.sh
    printf 'Norm_Audio.sh \"%s\"\n' *.ts | sort >> Batch.sh
    ;;
  V)
    printf 'Video_Encode.sh \"%s\"\n' *.mp4 > Batch.sh
    printf 'Video_Encode.sh \"%s\"\n' *.ts >> Batch.sh
    ;;
  W)
    printf 'Web_ReEncode.sh \"%s\"\n' *.mp4 | sort > Batch.sh
    printf 'Web_ReEncode.sh \"%s\"\n' *.mkv | sort >> Batch.sh
    printf 'Web_ReEncode.sh \"%s\"\n' *.webm | sort >> Batch.sh
    ;;
  Y)
    printf 'Youtube_Encode.sh \"%s\"\n' *.mp4 | sort > Batch.sh
    printf 'Youtube_Encode.sh \"%s\"\n' *.mkv | sort >> Batch.sh
    printf 'Youtube_Encode.sh \"%s\"\n' *.webm | sort >> Batch.sh
    ;;
  *)
    printf 'Usage: ./Batch_Make.sh ( D || M || N || V || W || Y )\n'
    printf 'Optional: pattern as second like ( mp3 || ogg || flac )\n'
    ;;
esac
