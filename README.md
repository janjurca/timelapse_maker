# Timelapse_maker
This were made as easy tool to create timelapse from the photos under linux systems.

The ffmpeg and mogrify commands need to be installed on the system.

## make_timelapse.sh

When you run this script it will look for all images in seleceted directory merge them into video and then code this video with x264 codec.

Arguments
```
 -p [path] photos directory
 -f force the removing of resize folder
 -r resize images, select the resolution of resized image eg 1920x1080  
```
