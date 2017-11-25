#!/bin/bash

#I DON'T THINK THIS WORKS VERY WELL. 
#THE COMPONENTS ARE EITHER DECOMPOSED FROM THE START OF THEY ARE NOT DECOMPOSED AT ALL

cp $1 timeseries.nii

fslsplit melodic_IC.nii ICc -t

3dMean -prefix -overwrite network.nii ICc0000.nii ICc0001.nii ICc0002.nii ICc0003.nii 

#automatically mask out everything outside the Ics

fslmaths network.nii -s 1 smoothed_network.nii

declare thresh=($(fslstats network.nii -p 20 -p 90))
echo  "first ${thresh[1]}"

thresh_up=$( echo "${thresh[1]}" | bc -l)
echo  "second $thresh_up"

fslmaths smoothed_network.nii -thr $thresh_up -Tmin -bin mask -odt char

3dcalc -a mask.nii -b timeseries.nii -expr 'a*b' -prefix 'locally_densoised.nii' -overwrite

melodic -i 'locally_densoised.nii' --nomask --nobet -d 30
