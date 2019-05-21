#!/bin/bash


echo "It starts now"

cp $1 "extract_me.zip"

unzip extract_me.zip

rm extract_me.zip
rm -r _rels
rm [Content_Types].xml
rm -r docProps
mv ./ppt/media ./extracted_images
rm -r ppt
