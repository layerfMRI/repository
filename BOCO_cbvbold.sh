#!/bin/bash


echo "It starts now:    I expect two files moco_Basis_bold.nii and moco_Basis_cbv.nii that are motion corrected with SPM"

# In case you have mutiple runs with identical taks timing, you can average them here. 
3dmean -overwrite -prefix moco_Basis_bold.nii.gz moco_Basis_bold_*.nii 
3dmean -overwrite -prefix moco_Basis_cbv.nii.gz moco_Basis_cbv_*.nii 

# create T1_weighted from combination
3dTcat -prefix combined.nii.gz -overwrite moco_Basis_bold.nii moco_Basis_cbv.nii
3dTstat -cvarinv -prefix T1_weighted.nii.gz -overwrite combined.nii.gz 
rm combined.nii.gz

# also renamed to Nulled and BOLD (see above)
mv moco_Basis_cbv.nii.gz Nulled.nii.gz
mv moco_Basis_bold.nii.gz BOLD.nii.gz

# mean images
3dTstat -mean -prefix mean_nulled.nii.gz Nulled.nii.gz -overwrite
3dTstat -mean -prefix mean_notnulled.nii.gz BOLD.nii.gz -overwrite
3dcalc -overwrite -a mean_nulled.nii.gz -b mean_notnulled.nii.gz -prefix T1_weighted1.nii.gz -expr 'within(((a-b)/(a+b)+1),0,1.2)*(a-b)/(a+b)' 

# upsample in time for BOCO
3dUpsample -overwrite -datum short -prefix Nulled_intemp.nii.gz -n 2 -input Nulled.nii.gz
3dUpsample -overwrite -datum short -prefix BOLD_intemp.nii.gz -n 2 -input BOLD.nii.gz

# remove Shift BOLD so that itmatches the timing with VASO 
NumVol=`3dinfo -nv BOLD_intemp.nii.gz`
echo $NumVol
3dTcat -overwrite -prefix BOLD_intemp.nii.gz BOLD_intemp.nii.gz'[0]' BOLD_intemp.nii.gz'[0..'`expr $NumVol - 2`']'

# perform BOCO with VASO image first
LN_BOCO -Nulled Nulled_intemp.nii.gz -BOLD  BOLD_intemp.nii.gz 
3dCopy VASO_LN.nii VASO_intemp.nii.gz
rm VASO_LN.nii 

# quality stats
3dTstat -overwrite -mean -prefix BOLD.Mean.nii.gz \ BOLD_intemp.nii.gz'[1..$]'
3dTstat -overwrite -cvarinv -prefix BOLD.tSNR.nii.gz \ BOLD_intemp.nii.gz'[1..$]'
3dTstat -overwrite -mean -prefix VASO.Mean.nii.gz \ VASO_intemp.nii.gz'[1..$]'
3dTstat -overwrite -cvarinv -prefix VASO.tSNR.nii.gz \ VASO_intemp.nii.gz'[1..$]'

# adjust TR in header
3drefit -TR 2.571 BOLD_intemp.nii.gz
3drefit -TR 2.571 VASO_intemp.nii.gz

# downsample VASO in time and adjust TR in header
3dcalc -a VASO_intemp.nii'[0..$(2)]' -expr 'a' -prefix VASO.nii.gz -overwrite
3drefit -TR 5.142 VASO_intemp.nii.gz

# denoising of T1 outside
LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii.gz -INV2 mean_notnulled.nii.gz -UNI T1_weighted.nii.gz -beta 5
LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii.gz -INV2 mean_notnulled.nii.gz -UNI VASO.Mean.nii.gz -beta 1.5

# does not work but should not matter for VASO
# source /data/neurokog/nsi/LAYTOM22/scripts/LAY/start_bias_field.sh T1_weighted_denoised.nii

# more stats
LN_SKEW -input BOLD.nii.gz
LN_SKEW -input VASO.nii.gz

echo "und tschuess"
