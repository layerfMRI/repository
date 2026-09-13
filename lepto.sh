

LN2_RECIPROCAL -input template_template0.nii.gz 
3dmask_tool -input mask.nii.gz -dilate_input 28 -30 -prefix mask1.nii.gz -overwrite
3dCalc -a mask1.nii.gz -b template_template0_recip.nii.gz -expr 'a*b' -prefix masked_reci.nii.gz -overwrite
LN2_SNAPCAST -input masked_reci.nii.gz