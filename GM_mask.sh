#!/bin/bash

echo "fange an"



3dcalc -a MP2RAGE_0.5.nii -b ordered_ICAs.nii -prefix baisian_ICAs.nii   -overwrite -datum short -expr '1/(sqrt(2*3.14145*14000))*exp((-1*(a-2120)*(a-2120))/(2*14000))*10*b'
3dcalc -a MP2RAGE_0.5.nii             -prefix baisian_priors.nii -overwrite -datum short -expr '1/(sqrt(2*3.14145*14000))*exp((-1*(a-2120)*(a-2120))/(2*14000))*10'

echo "und tschuess"

 
