#!/bin/bash



echo " expects: phase_unwrap.sh Phase_imput.nii Magnetude.nii Brain_Mask.nii"

#3dcalc -a $1 -exp 'a*(3.141592)/4096' -prefix "scaled_$1" -overwrite 
#miconv -scale 0.00076718 -noscale $1 "scaled_$1"
 
prelude -a $2 -p "$1" -u "unwraped_$1" -m $3


echo "und tschuess:  expects: phase_unwrap.sh Phase_imput.nii Magnetude.nii Brain_Mask.nii"

 
