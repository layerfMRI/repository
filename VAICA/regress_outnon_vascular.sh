#!/bin/bash

echo "fange an"

#mkdir excluded_networks
#cd *.ica 
#cd *.ica 
#cd report 

#mv *thresh.png ../../../excluded_networks

#cd ../../

fsl_regfilt -i $1 -o denoised_$1 -d melodic_mix -f "$2"

echo "und tschuess"

 
