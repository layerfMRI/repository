#!/bin/bash


for filename in s*.nii
do
echo ${filename%%.*}

mkdir ${filename%%.*}

mv $filename ${filename%%.*}/$filename

done


