#!/bin/bash


echo "fange an"

cp $1 uncorr.nii

3dcalc  -a uncorr.nii -prefix uncorr.nii -expr 'sin(a*(3.141592)/4096)' -overwrite

echo "hole SPM motion batch"
cp /Users/l.huber/repository/bias_field_corr/Bias_phase_script_job.m ./Bias_phase_script_job.m
/Applications/MATLAB_2019b.app/bin/matlab -nodesktop -nosplash -r "Bias_phase_script_job"

3dcalc -a muncorr.nii -prefix muncorr.nii -overwrite -expr 'a' -datum short

mv muncorr.nii bico_$1

rm uncorr.nii

rm c*uncorr.nii

echo "und tschuess"
