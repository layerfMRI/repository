#!/bin/bash
 
   3dmaskave -quiet -mask upper_layer.nii MEAN_BOLD_trial_alpha_norm.nii > BOLD_alpha_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_BOLD_trial_rem_norm.nii  > BOLD_rem_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_BOLD_trial_go_norm.nii  > BOLD_go_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_BOLD_trial_nogo_norm.nii > BOLD_nogo_upper.dat
 
   3dmaskave -quiet -mask upper_layer.nii MEAN_VASO_trial_alpha_norm.nii > VASO_alpha_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_VASO_trial_rem_norm.nii > VASO_rem_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_VASO_trial_go_norm.nii > VASO_go_upper.dat
   3dmaskave -quiet -mask upper_layer.nii MEAN_VASO_trial_nogo_norm.nii > VASO_nogo_upper.dat
 
   3dmaskave -quiet -mask deeper_layer.nii MEAN_BOLD_trial_alpha_norm.nii > BOLD_alpha_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_BOLD_trial_rem_norm.nii > BOLD_rem_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_BOLD_trial_go_norm.nii > BOLD_go_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_BOLD_trial_nogo_norm.nii > BOLD_nogo_deeper.dat
 
   3dmaskave -quiet -mask deeper_layer.nii MEAN_VASO_trial_alpha_norm.nii > VASO_alpha_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_VASO_trial_rem_norm.nii > VASO_rem_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_VASO_trial_go_norm.nii > VASO_go_deeper.dat
   3dmaskave -quiet -mask deeper_layer.nii MEAN_VASO_trial_nogo_norm.nii > VASO_nogo_deeper.dat
										
 
#3dDeconvolve -num_stimts 1 -stim_file 1 new_design.txt -input normaliced_BOLD.nii -cbucket output_on_off.nii -overwrite -polort 0 -x1D tmp.design.1D -fitts fitts_on_off.nii
