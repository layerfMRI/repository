#!/bin/bash


echo "fange an"


3dAutomask -prefix mask.nii -peels 3 -dilate 2 $1

N4BiasFieldCorrection -d 3 -i $1 -r 1 -s 1 -x mask.nii -o bico_$1

echo "und tschuess"
