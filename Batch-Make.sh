path=$PWD
audio=$1
pattern=$2

case $audio in
  U)
    printf 'Upscale_Encode.sh \"%s\"\n' *.mp4 > Batch.sh
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
  P)
    printf 'Norm_Audio.sh \"%s\"\n' "$pattern"*.mp4 > Batch.sh
    ;;
  W)
    printf 'Web_ReEncode.sh \"%s\"\n' *.mp4 | sort > Batch.sh
    ;;
  Y)
    printf 'Youtube_Encode.sh \"%s\"\n' *.mp4 | sort > Batch.sh
    ;;
  *)
    printf 'Audio_ReEncode.sh \"%s\"\n' *.mp4 > Batch.sh
    ;;
esac
