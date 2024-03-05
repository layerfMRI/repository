#!/bin/bash

echo "fange an"

for filename in S*.nii
do

echo  ${filename}

cp /Users/administrator/Git/repository/NORDIC/NORDIC_wrapper.m ./
cp /Users/administrator/Git/repository/NORDIC/NIFTI_NORDIC.m ./


/Applications/MATLAB_R2023a.app/bin/matlab  -nodesktop -nosplash -r  "NORDIC_wrapper ${filename}"


echo "und tschuess:  expects: phase_eval.sh "

 
done 
