#!/bin/bash

declare thresh=($(fslstats $1 -p 2 -p 98))
echo  "first ${thresh[1]}"

thresh_up=$( echo "${thresh[1]}/4" | bc -l)
echo  "second $thresh_up"

fslmaths $1 -thr $thresh_up -Tmin -bin mask -odt char

fslstats $1 -k mask -p 50

fslmaths mask -dilF mask
fslmaths mask -dilF mask
fslmaths mask -dilF mask


3dTstat -mean -prefix mean.nii -overwrite $1 
fslmaths mean.nii -s 2 smoothed_2_mean.nii
fslmaths mean.nii -s 20 smoothed_40_mean.nii
3dcalc -a smoothed_2_mean.nii -b smoothed_40_mean.nii -expr 'a/b' -prefix norm.nii -overwrite
fslmaths norm.nii -thr 0.8 -bin mask_2.nii
fslmaths mask_2.nii -dilF mask_2.nii
fslmaths mask_2.nii -dilF mask_2.nii
fslmaths mask_2.nii -dilF mask_2.nii
fslmaths mask_2.nii -dilF mask_2.nii


3dcalc -a mask.nii -b mask_2.nii -expr "a*b" -prefix mask_final.nii -overwrite



rm smoothed*.nii
rm norm.nii
rm mean.nii