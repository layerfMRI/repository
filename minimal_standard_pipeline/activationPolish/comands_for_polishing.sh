#!/bin/bash

#################################################
#########  QA of good dataset       #############
#################################################
#we use laynii v2.2.1

LN_SKEW -input slab_fmri.nii


#################################################
#########  original GLM, no cleaing #############
#################################################
#we use AFNI 21.2.00

3dDeconvolve -overwrite -jobs 16 -polort a -input slab_fmri.nii \
             -num_stimts 2 \
             -TR_times 3 \
             -stim_times 1 '1D: 12 60 108' 'UBLOCK(12,1)' -stim_label 1 Task1 \
             -stim_times 2 '1D: 36 84 132' 'UBLOCK(12,1)' -stim_label 2 Task2 \
             -tout \
             -x1D MODEL_wm \
             -bucket STATS.nii
           

#5-12
#3dTstat -mean -overwrite -prefix mean.nii slab_fmri.nii 
#3dcalc -a mean.nii -b STATS.nii'[1]'  -expr 'b/a*100' -prefix beta1_percent.nii -overwrite
#3dcalc -a mean.nii -b STATS.nii'[3]'  -expr 'b/a*100' -prefix beta2_percent.nii -overwrite

#################################################
######### NORDIC  ###############################
######### from here on noise in residuals #######
######### is hard to interpret  #################
#################################################

##  %% \: execute this in Matlab in the folder of the file
## we use v1.1 from https://github.com/SteenMoeller/NORDIC_Raw/releases

                ARG.NORDIC=1;
                RG.noise_volume_last = 0;
                ARG.magnitude_only=1;
                ARG.kernel_size_PCA = [28, 28, 1]; 
                fn_magn_in= 'slab_fmri';
                fn_phase_in=fn_magn_in;
                fn_out=['NORDIC_' fn_magn_in];
                NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG)  
                
# statistics again 
3dDeconvolve -overwrite -jobs 16 -polort a -input NORDIC_slab_fmri.nii \
             -num_stimts 2 \
             -TR_times 3 \
             -stim_times 1 '1D: 12 60 108' 'UBLOCK(12,1)' -stim_label 1 Task1 \
             -stim_times 2 '1D: 36 84 132' 'UBLOCK(12,1)' -stim_label 2 Task2 \
             -tout \
             -x1D MODEL_wm \
             -bucket STATS_postNORDIC.nii

#12-30
#################################################
##### layer smoothing  ##########################
##### from here on the mesoscopic shape #########
##### of activated ROI is hard to interprete ####
#################################################
# we use laynii v2.2.1 from https://github.com/layerfMRI/LAYNII 

LN_LAYER_SMOOTH -input NORDIC_slab_fmri.nii -layer_file layers.nii -FWHM 0.7 

# statistics again 
3dDeconvolve -overwrite -jobs 16 -polort a -input smoothed_NORDIC_slab_fmri.nii \
             -num_stimts 2 \
             -TR_times 3 \
             -stim_times 1 '1D: 12 60 108' 'UBLOCK(12,1)' -stim_label 1 Task1 \
             -stim_times 2 '1D: 36 84 132' 'UBLOCK(12,1)' -stim_label 2 Task2 \
             -tout \
             -x1D MODEL_wm \
             -bucket STATS_postNORDIC_postsmooth.nii
#12-30
#################################################
##### cluster thresholding ######################
##### from here on, the size of the #############
##### activated region is hard to interprete ####
#################################################

3dclust -prefix nice_STATS_postNORDIC_postsmooth.nii -1clip 8 0.9 35 STATS_postNORDIC_postsmooth.nii -overwrite
