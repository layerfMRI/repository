#!/bin/sh


afni_VASO_flex.sh 
3dcalc -a mean_nulled.nii -b mean_notnulled.nii -expr '(b-a)/(a)' -prefix ratio.nii
start_bias_field.sh ratio.nii
denoise_me.sh bico_ratio.nii
3dmask_tool -input moma.nii -prefix mask.nii -overwrite -dilate_input -1
3dcalc -a mask.nii -b bico_ratio.nii -c denoised_bico_ratio.nii -expr 'a*(b+c)' -datum float  -prefix maskedVASOmean.nii -overwrite
3dcalc -a mask.nii -b bico_ratio.nii -c denoised_bico_ratio.nii -expr '(b+c)' -prefix VASOmean.nii -overwrite -datum float
