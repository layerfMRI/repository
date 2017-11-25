#!/bin/bash


echo "It starts now"


#mkdir $1

# The directory were I'm processing these data
#cd ./$1

# copy paste the files from the original data directory to the processing directory
#for idx in 0  ; do
#   cp ../$1.nii ./$1.nii
#done

# The images are improperly listed as in TLRC space so I'm changing that to orig
# (This is an AFNI distinction for files that are in their subject-original space
#    vs aligned to a standardize template)
#
# The true TR is actually 1.5s rather than 1.49900s.
#
# 3drefit can correct both of these things
#   The way this is written, it will change values for the files in the D00_OrigData directory

#for filename in `ls *.nii`; do
#  echo ${filename}
#  3drefit -space ORIG -view orig -TR 1.5 ${filename}
#done

# All runs are being aligned to the first volume of ValsalvaAscend1.nii
#  The mot.1D file contains the 6 motion parameters. 
# The dfile.1D contains the 6 motion parameters + 3 summary-of-motion parameters

3dTstat -mean -prefix mean_nulled.nii $1'[1..$(2)]' -overwrite
3dTstat -mean -prefix mean_notnulled.nii $1'[0..$(2)]' -overwrite


# Run motion correction. Athought I originally did this on BOLD and Null together,
# I separated them here since these are the final BOLD time series & I'd need to make
# a distinct run for these data anyway.

NumVol=`3dinfo -nv $1`
echo "NumVol of BOLD is '$NumVol' "


3dcalc -overwrite -prefix Nulled.nii -a $1'[1..'`expr $NumVol - 2`'(2)]' -expr 'a'
3dcalc -overwrite -prefix NotNulled.nii -a $1'[0..'`expr $NumVol - 3`'(2)]' -expr 'a'


#renzo  learn how to do moc with motionmask
3dvolreg -overwrite -prefix BOLD.volreg.nii -base mean_notnulled.nii -1Dmatrix_save BOLDmatri -dfile BOLD.dfile.1D -1Dfile BOLD.mot.1D  -quitic NotNulled.nii
3dAllineate -1Dmatrix_apply BOLDmatri.aff12.1D -warp shift_rotate -final quintic -prefix BOLD_allineated.nii NotNulled.nii -overwrite

3dvolreg -overwrite -prefix VASO.volreg.nii -base mean_nulled.nii  -1Dmatrix_save Nulledmatri -dfile Nulled.dfile.1D -1Dfile Nulled.mot.1D -quitic Nulled.nii
3dAllineate -1Dmatrix_apply Nulledmatri.aff12.1D -warp shift_rotate -final quintic -prefix Nulled_allineated.nii Nulled.nii -overwrite


rm mean_nulled.nii
rm mean_notnulled.nii

# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes
# I was mainly doing this as a check to make sure motion correction worked reasonably.
# A TSNR calculation should probably be done after non-linear drift removal.

# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume

  NumVol=`3dinfo -nv BOLD_allineated.nii`
  3dcalc -prefix tmp.VASO_vol1.nii \
         -a      BOLD_allineated.nii'[0]' \
         -b      Nulled_allineated.nii'[0]' \
         -expr 'b/a' -overwrite

  3dcalc -prefix tmp.VASO_volend.nii \
         -a      BOLD_allineated.nii'['`expr $NumVol - 1`']' \
         -b      Nulled_allineated.nii'['`expr $NumVol - 1`']' \
         -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv BOLD_allineated.nii`
 3dcalc -prefix  VASO_allineated.nii \
         -a      BOLD_allineated.nii'[0..'`expr $NumVol - 2`']' \
         -b      BOLD_allineated.nii'[1..'`expr $NumVol - 1`']' \
         -c      Nulled_allineated.nii'[0..'`expr $NumVol - 2`']' \
         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
 #  3dTcat -overwrite -prefix VASO.volreg.nii  tmp.VASO_othervols.nii tmp.VASO_volend.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
#srm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers


  3drefit -TR 3.0 VASO_allineated.nii
  3drefit -TR 3.0 BOLD_allineated.nii 
 
#echo ' remove last time point in BOLD'
NumVol=`3dinfo -nv BOLD.volreg.nii`
echo "NumVol of BOLD is '$Numvol'  "
3dcalc -prefix BOLD_allineated.nii \
         -a      BOLD_allineated.nii'[0..'`expr $NumVol - 2`']' \
         -expr 'a' -overwrite


#echo ' remove last time point in BOLD'


  3dTstat  -overwrite -mean -prefix MEAN_BOLD.nii \
     BOLD_allineated.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_BOLD.nii \
     BOLD_allineated.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix MEAN_VASO.nii \
     VASO_allineated.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_VASO..nii \
     VASO_allineated.nii'[1..$]'

  3dTstat  -overwrite -mean  -prefix MEAN_Nulled.nii \
     Nulled_allineated.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_Nulled.nii \
     Nulled_allineated.nii'[1..$]'



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



