#!/bin/bash

#averaging across time points to correct for Fuzzy Ripples
3dTstat -mean -prefix INV1_AP.nii.gz -overwrite moco_Basis_TI1_100.nii
3dTstat -mean -prefix INV1_PA.nii.gz -overwrite moco_Basis_TI1_101.nii

3dTstat -mean -prefix INV2_AP.nii.gz -overwrite moco_Basis_TI2_100.nii
3dTstat -mean -prefix INV2_PA.nii.gz -overwrite moco_Basis_TI2_101.nii

#Taking the ratio of inversion times to corret for Rx bias fields, proton density, and T2*
3dcalc -a INV1_AP.nii.gz -b INV2_AP.nii.gz -expr 'min(a/b,1)' -overwrite -prefix UNI_AP.nii
3dcalc -a INV1_PA.nii.gz -b INV2_PA.nii.gz -expr 'min(a/b,1)' -overwrite -prefix UNI_PA.nii

#removal of noise outside the brain
LN_MP2RAGE_DNOISE -INV1 INV1_AP.nii.gz -INV2 INV2_AP.nii.gz -UNI UNI_AP.nii.gz -beta 20 -output UNI_AP_denoised.nii
LN_MP2RAGE_DNOISE -INV1 INV1_PA.nii.gz -INV2 INV2_PA.nii.gz -UNI UNI_PA.nii.gz -beta 20 -output UNI_PA_denoised.nii

#Biad field correction in SPM
/Applications/MATLAB_R2024a.app/bin/matlab -nodesktop -nosplash -r "Bias_field_script_job"

#Distortion estimation
3dQwarp -plusminus -pmNAMES Rev For                           \
        -pblur 0.05 0.05 -blur -1 -1                          \
        -noweight -minpatch 9                                 \
        -source mUNI_PA_denoised.nii                 \
        -base   mUNI_AP_denoised.nii                  \
        -prefix blip_warp.nii
        
#lets look at the distortion field in the phase encoding direction just for QA
3dcalc -a blip_warp_For_WARP.nii'[1]' -prefix warpfield_phaseencode.nii -expr 'a' -overwrite

3dmean -prefix unwarpedmean.nii -overwrite blip_warp_For.nii blip_warp_Rev.nii

#Echo spacing of T1234 is 1.29ms, segmentation and inplane GRAPPA is 14. This makes the effective echos pacing (relevant for distortions) 0.09214 ms
#Echo spacing of fucntional protocol is 1.12ms, segmentation and iplane GRAPPA is 4. This makes the effective echo spacing 0.28.       

#Estimation of the distortion field of fucntional data
3dcalc -a blip_warp_For_WARP.nii -expr 'a*((-1)*0.28/0.09214)' -prefix warptofunctional.nii -overwrite 

#Applying the distortion field
3dNwarpApply    \
        -source unwarpedmean.nii     \
        -master unwarpedmean.nii         \
        -prefix mached2fucntional.nii \
        -nwarp 'warptofunctional.nii' \
        -overwrite

