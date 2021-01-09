#!/bin/bash

images=$(find static/posts -type f \( -iname \*.jpeg -o  -iname \*.jpg -o -iname \*.png \))

total=$(echo "$images" | wc -l)
num=0

echo "There are $total files to be converted."

for f in $images
do
    ((num++))
    echo "Converting $f, $num / $total"   
    #filename=$(basename -- $f | sed 's/\.[^.]*$//')
    dest="${f/posts/posts-optimized}"
    parentdir="$(dirname "$dest")"
    mkdir -p $parentdir
    convert "./$f" -blur 13x20 -filter LanczosRadius -resize 105%x105% \( "$f" -gravity center +repage \) -composite -compose screen "$dest"
    convert "$dest" -resize 700\> "$dest"
#    clear

done
