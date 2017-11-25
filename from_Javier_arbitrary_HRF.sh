# CORRECT THE TR IN THE HEADER
#3drefit -TR 3 Bold_no_drift.nii

# GET AN INTRACRANIAL MASK 
#3dAutomask -prefix Bold_no_drift_mask.nii Bold_no_drift.nii'[0..10]' -overwrite

# GET THE DEMEAN MOTION AND DEMEAN AND FIRST DERIVATIVE
1d_tool.py -infile Motion_BOLD.1D -demean -derivative -write Motion_BOLD.demean.der.1D
1d_tool.py -infile Motion_BOLD.1D -demean -write Motion_BOLD.demean.1D

3dDeconvolve -overwrite -jobs 16 -polort a -input Bold_no_drift.nii'[0..229]' \
             -mask Bold_no_drift_mask.nii \
             -num_stimts 13 \
             -TR_times 3 \
             -stim_times 1 '1D: 30 90 150 210 270 330 390 450 510 570 630' 'TENT(0,57,20)' -stim_label 1 Task \
             -stim_base 2   -stim_file 2  Motion_BOLD.demean.1D'[0]'     -stim_label 2 roll  \
             -stim_base 3   -stim_file 3  Motion_BOLD.demean.1D'[1]'     -stim_label 3 pitch \
             -stim_base 4   -stim_file 4  Motion_BOLD.demean.1D'[2]'     -stim_label 4 yaw   \
             -stim_base 5   -stim_file 5  Motion_BOLD.demean.1D'[3]'     -stim_label 5 dS    \
             -stim_base 6   -stim_file 6  Motion_BOLD.demean.1D'[4]'     -stim_label 6 dL    \
             -stim_base 7   -stim_file 7  Motion_BOLD.demean.1D'[5]'     -stim_label 7 dP    \
             -stim_base 8   -stim_file 8  Motion_BOLD.demean.der.1D'[0]' -stim_label 8 roll_d1  \
             -stim_base 9   -stim_file 9  Motion_BOLD.demean.der.1D'[1]' -stim_label 9 pitch_d1 \
             -stim_base 10  -stim_file 10 Motion_BOLD.demean.der.1D'[2]' -stim_label 10 yaw_d1   \
             -stim_base 11  -stim_file 11 Motion_BOLD.demean.der.1D'[3]' -stim_label 11 dS_d1    \
             -stim_base 12  -stim_file 12 Motion_BOLD.demean.der.1D'[4]' -stim_label 12 dL_d1    \
             -stim_base 13  -stim_file 13 Motion_BOLD.demean.der.1D'[5]' -stim_label 13 dP_d1    \
             -tout \
             -x1D MODEL_wm \
             -iresp 1 HRF_wm.nii \
             -bucket STATS_wm.nii



# CORRECT THE TR IN THE HEADER
3drefit -TR 3 Anti_BOLD_no_drift.nii

# GET AN INTRACRANIAL MASK 
#3dAutomask -prefix Bold_no_drift_mask.nii Bold_no_drift.nii'[0..10]' -overwrite

# GET THE DEMEAN MOTION AND DEMEAN AND FIRST DERIVATIVE
1d_tool.py -infile Motion_VASO.1D -demean -derivative -write Motion_VASO.demean.der.1D
1d_tool.py -infile Motion_VASO.1D -demean -write Motion_VASO.demean.1D

3dDeconvolve -overwrite -jobs 16 -polort a -input Anti_BOLD_no_drift.nii'[0..229]' \
             -mask Bold_no_drift_mask.nii \
             -num_stimts 13 \
             -TR_times 3 \
             -stim_times 1 '1D: 30 90 150 210 270 330 390 450 510 570 630' 'TENT(0,57,20)' -stim_label 1 Task \
             -stim_base 2   -stim_file 2  Motion_VASO.demean.1D'[0]'     -stim_label 2 roll  \
             -stim_base 3   -stim_file 3  Motion_VASO.demean.1D'[1]'     -stim_label 3 pitch \
             -stim_base 4   -stim_file 4  Motion_VASO.demean.1D'[2]'     -stim_label 4 yaw   \
             -stim_base 5   -stim_file 5  Motion_VASO.demean.1D'[3]'     -stim_label 5 dS    \
             -stim_base 6   -stim_file 6  Motion_VASO.demean.1D'[4]'     -stim_label 6 dL    \
             -stim_base 7   -stim_file 7  Motion_VASO.demean.1D'[5]'     -stim_label 7 dP    \
             -stim_base 8   -stim_file 8  Motion_VASO.demean.der.1D'[0]' -stim_label 8 roll_d1  \
             -stim_base 9   -stim_file 9  Motion_VASO.demean.der.1D'[1]' -stim_label 9 pitch_d1 \
             -stim_base 10  -stim_file 10 Motion_VASO.demean.der.1D'[2]' -stim_label 10 yaw_d1   \
             -stim_base 11  -stim_file 11 Motion_VASO.demean.der.1D'[3]' -stim_label 11 dS_d1    \
             -stim_base 12  -stim_file 12 Motion_VASO.demean.der.1D'[4]' -stim_label 12 dL_d1    \
             -stim_base 13  -stim_file 13 Motion_VASO.demean.der.1D'[5]' -stim_label 13 dP_d1    \
             -tout \
             -x1D MODEL_wm \
             -iresp 1 HRF_wm.nii \
             -bucket STATS_wm.nii



