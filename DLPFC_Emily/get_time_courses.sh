#!/bin/bash

   EXTR_1D_TIMESERIES MEAN_BOLD_trial_alpha_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat BOLD_alpha_upper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_rem_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat BOLD_rem_upper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_go_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat BOLD_go_upper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_nogo_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat BOLD_nogo_upper.dat

   EXTR_1D_TIMESERIES MEAN_VASO_trial_alpha_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat VASO_alpha_upper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_rem_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat VASO_rem_upper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_go_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat VASO_go_upper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_nogo_norm.nii upper_layer.nii 0
   mv 1D_time_course.dat VASO_nogo_upper.dat

   EXTR_1D_TIMESERIES MEAN_BOLD_trial_alpha_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat BOLD_alpha_deeper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_rem_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat BOLD_rem_deeper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_go_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat BOLD_go_deeper.dat
   EXTR_1D_TIMESERIES MEAN_BOLD_trial_nogo_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat BOLD_nogo_deeper.dat

   EXTR_1D_TIMESERIES MEAN_VASO_trial_alpha_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat VASO_alpha_deeper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_rem_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat VASO_rem_deeper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_go_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat VASO_go_deeper.dat
   EXTR_1D_TIMESERIES MEAN_VASO_trial_nogo_norm.nii deeper_layer.nii 0
   mv 1D_time_course.dat VASO_nogo_deeper.dat
										
 
#3dDeconvolve -num_stimts 1 -stim_file 1 new_design.txt -input normaliced_BOLD.nii -cbucket output_on_off.nii -overwrite -polort 0 -x1D tmp.design.1D -fitts fitts_on_off.nii
