#!/bin/bash


echo "It starts now afni_VASO_boco.sh filename_nulled.nii filename_BOL.nii"


# Calculate VASO!

#afni_RENZO_VASO_calc.sh Nulledimage NotNulled_image

  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv $2`
 3dcalc -prefix  VASO.nii \
         -a      $2'[0..'`expr $NumVol - 2`']' \
         -b      $2'[1..'`expr $NumVol - 1`']' \
         -c      $1'[0..'`expr $NumVol - 2`']' \
         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
 #  3dTcat -overwrite -prefix VASO.volreg.nii  tmp.VASO_othervols.nii tmp.VASO_volend.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
#srm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers


  3drefit -TR 3.0 VASO.nii
  3drefit -TR 3.0 $2
 
#echo ' remove last time point in BOLD'
NumVol=`3dinfo -nv $2`
echo "NumVol of BOLD is '$Numvol'  "
3dcalc -prefix BOLD.nii \
         -a      $2'[0..'`expr $NumVol - 2`']' \
         -expr 'a' -overwrite


#echo ' remove last time point in BOLD'


  3dTstat  -overwrite -mean -prefix MEAN_BOLD.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_BOLD.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix MEAN_VASO.nii \
     VASO.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_VASO..nii \
     VASO.nii'[1..$]'

  3dTstat  -overwrite -mean  -prefix MEAN_Nulled.nii \
     $2'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_Nulled.nii \
     $2'[1..$]'



3dcalc -prefix T1_like.nii \
        -a     MEAN_BOLD.nii \
	-b     MEAN_Nulled.nii \
         -expr '(a+b)/(a-b)' -overwrite

  
#3dDeconvolve -overwrite -jobs 16 -polort a -input "BOLD.volreg.nii" \
#             -num_stimts 1 \
#             -TR_times 3 \
#             -stim_times 1 '1D: 30 90 150 210 270 330 390 450 510 570 630' 'TENT(0,57,20)' -stim_label 1 Task \
#             -tout \
#             -x1D MODEL_wm \
#             -iresp 1 HRF_wm_BOLD.volreg.nii \
#             -bucket STATS_wm_BOLD.volreg.nii

#3dDeconvolve -overwrite -jobs 16 -polort a -input "VASO.volreg.nii" \
#             -num_stimts 1 \
##             -TR_times 3 \
#            -stim_times 1 '1D: 30 90 150 210 270 330 390 450 510 570 630' 'TENT(0,57,20)' -stim_label 1 Task \
#             -tout \
#             -x1D MODEL_wm \
#             -iresp 1 HRF_wm_VASO.volreg.nii \
#             -bucket STATS_wm_VASO.volreg.nii



