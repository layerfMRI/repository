#!/bin/bash

#3dQwarp -plusminus -pmNAMES  PA_bico_UNI_clip_denoised.nii

3dQwarp -plusminus -pmNAMES Rev For                           \
        -pblur 0.05 0.05 -blur -1 -1                          \
        -noweight -minpatch 9                                 \
        -source PA_bico_UNI_clip_denoised.nii                 \
        -base   AP_bico_UNI_clip_denoised.nii                  \
        -prefix blip_warp.nii

#topup --imain=merged.nii --datain=acqparams.txt --config=b02b0.cnf --out=my_topup_results --fout=my_field --iout=my_unwarped_images 
#with 
#0 -1 0 0.062
#0 1 0 0.062
#acqparams.txt

3dNwarpApply    \
        -source AP_bico_UNI_clip_denoised.nii     \
        -master AP_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped.nii \
        -nwarp 'blip_warp_For_WARP.nii' 

3dNwarpApply    \
        -source PA_bico_UNI_clip_denoised.nii     \
        -master PA_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped-3.nii \
        -nwarp 'blip_warp_For_WARP.nii blip_warp_For_WARP.nii blip_warp_For_WARP.nii' 

3dcalc -a blip_warp_For_WARP.nii -expr 'a*3' -prefix warptimes3.nii -overwrite 

3dNwarpApply    \
        -source PA_bico_UNI_clip_denoised.nii     \
        -master PA_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped-3multi.nii \
        -nwarp 'warptimes3.nii' 
        
 3dNwarpApply    \
        -source AP_bico_UNI_clip_denoised.nii     \
        -master AP_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped1.nii \
        -nwarp 'blip_warp_Rev_WARP.nii' 
        
         3dNwarpApply    \
        -source AP_bico_UNI_clip_denoised.nii     \
        -master AP_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped2.nii \
        -overwrite \
        -nwarp 'blip_warp_Rev_WARP.nii blip_warp_Rev_WARP.nii' 

         3dNwarpApply    \
        -source AP_bico_UNI_clip_denoised.nii     \
        -master AP_bico_UNI_clip_denoised.nii         \
        -prefix extrenal_warped3.nii \
        -nwarp 'blip_warp_Rev_WARP.nii blip_warp_Rev_WARP.nii blip_warp_Rev_WARP.nii' 
