#!/bin/bash


3dDeconvolve -overwrite -jobs 16 -polort a -input "$1"'[0..229]' \
             -num_stimts 1 \
             -TR_times 3 \
             -stim_times 1 '1D: 30 90 150 210 270 330 390 450 510 570 630' 'TENT(0,57,20)' -stim_label 1 Task \
             -tout \
             -x1D MODEL_wm \
             -iresp 1 HRF_wm$1 \
             -bucket STATS_wm$1
