#!/bin/bash

cp mean_nulled.nii.gz INV1.nii.gz
cp mean_notnulled.nii.gz INV2.nii.gz
cp VASO.Mean.nii.gz UNI.nii.gz 
3dcalc -a UNI.nii.gz -expr 'min(a,1)' -prefix UNI_clip.nii.gz 

LN_MP2RAGE_DNOISE -INV1 INV1.nii.gz -INV2 INV2.nii.gz -UNI UNI_clip.nii.gz -beta 20

3dcopy UNI_clip_denoised.nii.gz UNI_clip_denoised.nii

start_bias_field.sh UNI_clip_denoised.nii
