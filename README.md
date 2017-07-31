# Timelapse_maker
This were made as easy tool to create timelapse from the photos under linux systems.

The ffmpeg and mogrify commands need to be installed on the system.

## make_timelapse.sh

When you run this script in some directory it will search for specific names of folder ( eg. exported ) then it will merge all photos in ( exported ) directory to video and then code this video with x264 codec.

Arguments

-p [path] photo path (default is pwd)
-d [dir_name] working directory standard name (eg. darktable_exported)
-c enable copying of resulting videos to pwd dir
-s skip dir if dir "resized" exist
-f force the removing of already "resized" folder
-r select the resolution of resized image eg 1920x1080 is default
