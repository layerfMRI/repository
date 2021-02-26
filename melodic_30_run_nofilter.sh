#!/bin/bash

#This does the drift correction and a subsequence melodic into 30 ICs


# FILTERING, if you want
#3dTstat -mean -prefix mean_Bild_$1 $1 -overwrite
#fslmaths $1 -bptf 20 4 filtered_$1
#3dcalc -a mean_Bild_$1 -b filtered_$1 -expr 'a+b' -prefix  fsl_filtered_$1 -overwrite
#rm filtered_$1
#melodic -i $1 --nomask --nobet -d 30

melodic -i $1 --nomask --nobet -d 30
