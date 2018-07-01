#!/bin/bash

set -e

RED='\033[0;31m'
NC='\033[0m' # No Color

function print_help {
 printf "Invalid option: $OPTARG \n \
 Help:\n\
 \t -p [path] photos directory\n\
 \t -f force the removing of resize folder\n\
 \t -c FFMPEG  comprimation coefficient 0-51 (default 23), 0 is lossless, 51 is worst \n\
 \t -r resize images, select the resolution of resized image eg 1920x1080, is possible to force resolution 1920x900! by the exclamation  \n\
 "  >&2
}

WORK_DIR=$(pwd)

while getopts :p:c:hfr: opt "$@"; do
  case $opt in
    p) WORK_DIR="$OPTARG" ;;

    f) FORCE=1 ;; #force remove the resize folder

    r) RESIZE=$OPTARG ;; #force remove the resize folder

    h) print_help & exit 0  ;;

    c) CRF=$OPTARG ;;

    \?) print_help & exit 1  ;;
  esac
done

printf "Processing: ${WORK_DIR} "
if test -d resized; then
	if [ ${FORCE-0} -eq 0 ]; then
		echo "Already made. Skipping"
        exit 0
	else
		rm -rf resized
	fi
fi

IMAGE_SOURCE=${WORK_DIR}
if [[ ${RESIZE-"0"} != "0" ]]; then
    mkdir "${WORK_DIR}/resized"
    printf " ${RED}resizing${NC} "
    mogrify -monitor -path "${WORK_DIR}/resized" -resize ${RESIZE-"1920x1080"} *.jpg >> /dev/null  2>> /dev/null # If you want to keep the aspect ratio, remove the exclamation mark (!)
    IMAGE_SOURCE="${WORK_DIR}/resized"
fi

printf " ${RED}making video${NC} "
rm output.avi
ffmpeg -r 24 -pattern_type glob -i "${IMAGE_SOURCE}/*.jpg" -c:v copy output.avi > /dev/null 2>/dev/null
rm output-final.mkv
ffmpeg -i output.avi -c:v libx264 -preset slow -crf ${CRF-23} output-final.mkv > /dev/null
printf " ${RED}Done${NC}\n"
