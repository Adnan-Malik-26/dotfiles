#!/bin/bash 
grim /tmp/shot.png  
ffmpeg -y -i /tmp/shot.png -vf "boxblur=8:2" /tmp/shot_blurred.png
wlogout --protocol layer-shell 

