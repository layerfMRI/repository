#!/bin/bash

echo "fange an"

3dTstat -mean -prefix mean_Bild$1 $1 -overwrite
fslmaths $1 -bptf -1 1 filtered_$1
3dcalc -a mean_Bild$1 -b filtered_$1 -expr 'a+b' -prefix  fsl_filtered_$1 -overwrite
rm filtered_$1

#3dTstat -mean -prefix mean_Bild.nii Anti_BOLD_no_drift.nii -overwrite
#/usr/share/fsl/5.0/bin/fslmaths Anti_BOLD_no_drift.nii -bptf 20 1 filtered_Anti_BOLD_no_drift.nii
#3dcalc -a mean_Bild.nii -b filtered_Anti_BOLD_no_drift.nii -expr 'a+b' -prefix  fsl_filtered_VASO.nii -overwrite

#rm filtered_Anti_BOLD_no_drift.nii

rm  mean_Bild$1

echo "und tschuess"

 
