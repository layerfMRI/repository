#!/bin/bash


3dDeconvolve -num_stimts 1 -stim_file 1 $2 -input $1 -bucket output.nii -overwrite -polort 0 

3dcalc -a output.nii'[1]' -expr 'a' -prefix "coeff_$1" -overwrite

3dcalc -a "coeff_$1" -expr 'sqrt(a)' -prefix "sqrt_coeff_$1" -overwrite

echo "I expect GLM_w_1dim.sh 4d_file.nii 1d_file.txt "
 
#3dDeconvolve -num_stimts 1 -stim_file 1 new_design.txt -input normaliced_BOLD.nii -cbucket output_on_off.nii -overwrite -polort 0 -x1D tmp.design.1D -fitts fitts_on_off.nii
