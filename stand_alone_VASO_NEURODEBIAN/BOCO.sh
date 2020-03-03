#!/bin/bash


##################################################
#### Temporal upsampling so VASO matches BOLD ####
##################################################

echo "temporal upsampling and shifting happens now"
3dUpsample -overwrite  -datum short -prefix Nulled_intemp.nii -n 2 -input moco_nulled.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp.nii   -n 2 -input moco_notnulled.nii

##for Magentom clasical VASO sequence
NumVol=`3dinfo -nv Nulled_intemp.nii`
3dTcat -overwrite -prefix Nulled_intemp.nii Nulled_intemp.nii'[0]' Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' 

echo "BOLD correction happens now"
LN_BOCO -Nulled Nulled_intemp.nii -BOLD BOLD_intemp.nii

echo "I am correcting for the proper TR in the header"
3drefit -TR 1.5 BOLD_intemp.nii
3drefit -TR 1.5 VASO_LN.nii

echo "calculating Mean and tSNR maps"
3dTstat -mean -prefix mean_nulled.nii moco_nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii moco_notnulled.nii -overwrite
3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii BOLD_intemp.nii'[1..$]'
3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii BOLD_intemp.nii'[1..$]'
3dTstat  -overwrite -mean  -prefix VASO.Mean.nii VASO_LN.nii'[1..$]'
3dTstat  -overwrite -cvarinv -prefix VASO.tSNR.nii VASO_LN.nii'[1..$]'

echo "calculating T1 in EPI space"
3dTcat -prefix combined.nii  moco_nulled.nii moco_notnulled.nii -overwrite 
3dTstat -cvarinv -overwrite  -prefix T1w.nii combined.nii
rm combined.nii 
#3dcalc -a mean_nulled.nii -b mean_notnulled.nii -expr 'abs(b-a)/(a+b)' -prefix T1w.nii -overwrite

echo "curtosis and skew"
#LN_SKEW -timeseries BOLD.nii
#LN_SKEW -timeseries VASO_LN.nii




