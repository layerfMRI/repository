#!/bin/bash


echo "It starts now"

  
3dDeconvolve -overwrite -jobs 16 -polort a -input $1 \
             -num_stimts 1 \
             -TR_times 3 \
             -stim_times 1 '1D: 0 60 120 180 240 300 360 420 480 540 600 660 720 780' 'UBLOCK(30,1)' -stim_label 1 Task \
             -tout \
             -x1D MODEL_wm \
             -iresp 1 HRF_$1 \
             -bucket STATS_$1

echo "GLM done" 



3dcalc -a HRF_$1'[1]'  -expr 'a' -prefix 1_HRF_$1 -overwrite 
3dcalc -a HRF_$1'[1]'  -expr '-1*a' -prefix 1_HRF_NEG_$1 -overwrite 


3dcalc -a STATS_$1'[0]'  -expr 'a' -prefix 0_STATS_$1 -overwrite 
3dcalc -a STATS_$1'[1]'  -expr '-1*a' -prefix 1_STATS_NEG_$1 -overwrite 
3dcalc -a STATS_$1'[2]'  -expr '-1*a' -prefix 2_STATS_NEG_$1 -overwrite 
3dcalc -a STATS_$1'[2]'  -expr 'a' -prefix 2_STATS_$1 -overwrite 