#!/bin/bash


echo "fange an"

cp $1 uncorr.nii

echo "get SPM bias field batch"
cp /Users/administrator/Git/repository/bias_field_corr/Bias_field_script_job.m ./Bias_field_script_job.m
/Applications/MATLAB_R2023a.app/bin/matlab -nodesktop -nosplash -r "Bias_field_script_job"

3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short

mv muncorr.nii bico_$1

rm uncorr.nii

#rm c*uncorr.nii

echo "und tschuess"
