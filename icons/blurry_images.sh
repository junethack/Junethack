#!/bin/bash

function light_me {
  original_image=$1
  light_image="$(basename $1 .png)_light.png"

  if [ ! -e "$light_image" ]
  then
    echo $original_image
    composite -blur 2x2 -blend 25 $original_image -size 54x54 xc:'#FFFFFF' -alpha Set "$light_image"
  fi
}

for FILE in $(find . -maxdepth 1 -type f -name '*.png' ! -name '*_light.png')
do
  light_me $FILE
done
