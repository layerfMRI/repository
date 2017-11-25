#!/bin/bash

echo "fange an"



3dcalc -a $1 -exp 'a*(3.141592)/4096' -prefix oneTR_Phase.nii -overwrite 



#miconv -trange 4-7 -noscale scaled_Phase.nii oneTR_Phase.nii

prelude -a $2 -p oneTR_Phase.nii -u unwraped_Phase.nii -m $2

3dTstat -mean -prefix mean_Phase.nii unwraped_Phase.nii -overwrite

PHASE_LOWPASS mean_Phase.nii 50

mv bias_filt.nii Bias_corrected_Phase.nii

echo "und tschuess:  expects: phase_eval.sh phase.niii ampl.nii "

 
