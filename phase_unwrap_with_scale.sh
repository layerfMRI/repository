#!/bin/bash



echo " expects: phase_unwrap.sh Phase_imput.nii Magnetude.nii Brain_Mask.nii"

3dcalc -a MAGN.nii -prefix MASK.nii  -expr 'step(a-200)' -overwrite

3dcalc -a PHASE.nii -exp 'a*(3.141592)/4096' -prefix scaled_PHASE.nii -overwrite 
#miconv -scale 0.00076718 -noscale $1 "scaled_$1"
 
prelude -a MAGN -p scaled_PHASE.nii -u UNWRAPED.nii -m MASK
rm scaled_PHASE.nii

echo "und tschuess:  expects: phase_unwrap.sh Phase_imput.nii Magnetude.nii Brain_Mask.nii"

 
