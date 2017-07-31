#!/bin/bash

function print_help {
 printf "Invalid option: -$OPTARG \nHelp:\n\t -p [path] photo path\n\t -d [dir_name] working directory standart id darktable_exported\n\t -c enable copying of results to root dir\n\t -s skip dir if dir resized exist\n\t -f force the removing of resize folder\n\t -r select the resolution of resized image eg 1920x1080 is default  \n"  >&2
}

PWD_DIR=$(pwd)
COPY=0
SKIP=0
FORCE=0
while getopts :p:d:cshfr: opt $@; do
  case $opt in
    p) PHOTO_DIR=$OPTARG ;; # the root path where to find dirs with exported photos

    d) WORK_DIR=$OPTARG ;;

    c) COPY=1 ;; #rename and copy the output file movies to root dir

    s) SKIP=1 ;; #skip the dir if folder resized exists

    f) FORCE=1 ;; #force remove the resize folder

    r) RESOLUTION=$OPTARG ;; #select the resolution of resized image

    h) print_help & exit 0  ;;

    \?) print_help & exit 1  ;;
  esac
done

DIRS=$(find ${PHOTO_DIR-$PWD_DIR} -type d | grep ${WORK_DIR-darktable_exported}$)


for dir in $DIRS 
do
	cd $dir
	echo "Entering $dir"
	if test -d resized; then
		echo "Directory resized exists in $dir"
		if [ $SKIP -eq 1 ]; then
			echo "skipping directory"
			continue
		else
			if [ $FORCE -eq 0 ]; then
				echo "Remove it and continue or stop the process? [y/n]"
				read bool
				if [ $bool = "y" ]; then
					rm -rf resized
				else 
					continue
				fi	
			else
				rm -rf resized
			fi
		fi	
	fi

	mkdir resized
	echo "Resizing in $dir"
	mogrify -monitor -path resized -resize ${RESOLUTION-"1920x1080"} *.jpg >> $PWD_DIR/log  2>> $PWD_DIR/err # If you want to keep the aspect ratio, remove the exclamation mark (!)
	cd resized
	echo "Making video"
	ffmpeg -r 24 -pattern_type glob -i '*.jpg' -c:v copy output.avi >> $PWD_DIR/log 2>> $PWD_DIR/err

	ffmpeg -i output.avi -c:v libx264 -preset slow -crf 22 output-final.mkv >> $PWD_DIR/log 2>> $PWD_DIR/err
	if [ $COPY -eq 1 ]; then
		echo "Copying from $dir to $PWD_DIR"
		NAME=$(echo $dir | awk -F'/' '{ for (i = (NF-2); i <NF; i++){printf("%s",$i); if (i != (NF-1)){ printf("-")}} printf("\n")}')
		cp output-final.mkv $PWD_DIR/$NAME.mkv
	fi
	echo "$dir is done!"
done

