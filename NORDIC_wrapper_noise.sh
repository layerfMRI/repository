#!/bin/bash

echo "fange an"

for filename in S*.nii.gz
do


echo  ${filename}

cp /Users/administrator/Git/repository/NORDIC/NORDIC_wrapper_noise.m ./
cp /Users/administrator/Git/repository/NORDIC/NIFTI_NORDIC.m ./

/Applications/MATLAB_R2024a.app/bin/matlab -nodesktop -nosplash -r  "NORDIC_wrapper_noise ${filename}"

###Remove last noise scan


NumVol=`3dinfo -nv ${filename}`


echo $NumVol

3dcalc -overwrite -prefix NoNoise_${filename}  -a NORDIC_${filename}'[0..'`expr $NumVol - 3`']'  -expr 'a'

echo "und tschuess"

 
done 
