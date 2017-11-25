#!/bin/bash

echo "fange an"

mkdir excluded_networks

cd $1
cd *.ica 
cd report 

cp *thresh.png ../../../excluded_networks


cd ../

cp melodic_IC.nii ../../
cp melodic_mix ../../


#fsl_regfilt -i $1 -o denoised_$1 -d melodic_mix -f "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59"

echo "und tschuess"

 
