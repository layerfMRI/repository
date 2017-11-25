#!/bin/bash

echo "fange an"

for filename in ./pS*.nii

do

3dcalc -a $filename'[4..12(2)]' -exp 'a*(3.141592)/4096' -prefix oneTR_Phase.nii -overwrite 

done 



#miconv -trange 4-7 -noscale scaled_Phase.nii oneTR_Phase.nii

prelude -a MEAN_Nulled_Basis_b.nii -p oneTR_Phase.nii -u unwraped_Phase.nii -m MEAN_Nulled_Basis_b.nii

3dTstat -mean -prefix mean_Phase.nii unwraped_Phase.nii -overwrite

PHASE_LOWPASS mean_Phase.nii 50

mv bias_filt.nii Bias_corrected_Phase.nii

echo "und tschuess:  expects: phase_eval.sh "

 
