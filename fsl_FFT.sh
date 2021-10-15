#!/bin/bash


fslpspec "$1" "fslFFT_$1"

3dTstat -mean -prefix "mean_fslFFT_$1" -overwrite "fslFFT_$1" 

#miconv -trange 6-6 -noscale "fslFFT_$1" "tapping_freq_$1"

3dcalc -a "mean_fslFFT_$1" -b "fslFFT_$1" -expr 'b/a' -prefix "normaliced_freq_$1" -overwrite

echo " the units are: #TRs/(periode) "
echo " e.g. if you  have 12 trials, the corresponding activity will be at the 11th position (starting counting from 0) "
echo " the frequncy is of every TR can be calculates as :  volumen number /( TR in seconds * number of TRs )" 