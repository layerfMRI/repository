#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


cd AV

3dcalc -a ../M1/BOLD_intemp.feat/cluster_mask_zstat3.nii -b ../M2/BOLD_intemp.feat/cluster_mask_zstat3.nii -expr 'step(a+b)' -overwrite -prefix bin_rightROIslim.nii
3dmask_tool -overwrite -input bin_rightROIslim.nii -prefix bin_rightROIthick.nii -dilate_input 1

3dcalc -a ../M1/BOLD_intemp.feat/cluster_mask_zstat4.nii -b ../M2/BOLD_intemp.feat/cluster_mask_zstat4.nii -expr 'step(a+b)' -overwrite -prefix bin_leftROIslim.nii
3dmask_tool -overwrite -input bin_leftROIslim.nii -prefix bin_leftROIthick.nii -dilate_input 1

3dcalc -a bin_rightROIthick.nii -b VASO_LN.feat/stats/zstat4.nii -c c4uncorr.nii -d c5uncorr.nii -expr 'a*b*(1-step(c-0.5))*(1-step(d-0.5))' -overwrite -prefix VASOstatright.nii
3dcalc -a bin_leftROIthick.nii  -b VASO_LN.feat/stats/zstat3.nii -c c4uncorr.nii -d c5uncorr.nii -expr 'a*b*(1-step(c-0.5))*(1-step(d-0.5))' -overwrite -prefix VASOstatleft.nii

3dclust -1noneg -overwrite -prefix clust_VASIstatright.nii -1clip 1.4 1.2 200 VASOstatright.nii
3dclust -1noneg -overwrite -prefix clust_VASIstatleft.nii  -1clip 1.4 1.2 200 VASOstatleft.nii


cd ../../


done


echo "und tschuess"

 
