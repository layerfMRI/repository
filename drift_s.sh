#!/bin/bash



echo "fange an 160208"

3dTstat -mean -prefix mean_Bild.nii $1 -overwrite
echo "mean done"
3dDetrend -prefix detrended.nii -polort 20  $1 -overwrite
echo "detrend done"
3dcalc -a mean_Bild.nii -b detrended.nii -expr 'a+b' -prefix  detrended_$1 -overwrite -datum short
rm mean_Bild.nii
rm detrended.nii


echo "und tschuess"


