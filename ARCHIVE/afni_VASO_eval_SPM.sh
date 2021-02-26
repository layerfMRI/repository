#!/bin/bash


echo "It starts now:    I expect two files Not_Nulled_Basis_a.nii and Nulled_Basis_b.nii that are motion corrected with SPM"
 


NumVol=`3dinfo -nv Nulled_Basis_b.nii`
3dcalc -a Nulled_Basis_b.nii'[3..$]' -b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 1`']' -expr 'a+b' -prefix combined.nii -overwrite
3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii

3dcalc -a Nulled_Basis_b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
3dcalc -a Not_Nulled_Basis_a.nii'[2..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

3drefit -space ORIG -view orig -TR 3 BOLD.nii
3drefit -space ORIG -view orig -TR 3 Nulled.nii

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite


# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes
# I was mainly doing this as a check to make sure motion correction worked reasonably.
# A TSNR calculation should probably be done after non-linear drift removal.

# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume
  3dcalc -prefix tmp.VASO_vol1.nii \
         -a      BOLD.nii'[1]' \
         -b      Nulled.nii'[0]' \
         -expr 'b/a' -overwrite
         
  3dcalc -prefix tmp.VASO_vollast.nii \
         -a      BOLD.nii'[$]' \
         -b      Nulled.nii'[$]' \
         -expr 'b/a' -overwrite


  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv BOLD.nii`
  
  ### This is how i did it until Aug 1st 2018. 
  3dcalc -prefix tmp.VASO_othervols.nii \
         -a      BOLD.nii'[0..'`expr $NumVol - 2`']' \
         -b      BOLD.nii'[1..$]' \
         -c      Nulled.nii'[1..$]' \
         -expr 'c*2/(a+b)' -overwrite
  
  
  ### This is how i do it since Aug 1st 2018. 
   #  3dcalc -prefix tmp.VASO_othervols.nii \
   #      -a      BOLD.nii'[2..$]' \
   #      -b      BOLD.nii'[1..'`expr $NumVol - 2`']' \
   #      -c      Nulled.nii'[1..'`expr $NumVol - 2`']' \
   #      -d      Nulled.nii'[0..'`expr $NumVol - 3`']' \
   #      -expr '(0.5*c+0.5*d)/(1.0*a+0.0*b)' -overwrite      
 
   ### This is how is semms best in noisy V1 data. 
   #  3dcalc -prefix tmp.VASO_othervols.nii \
   #      -a      BOLD.nii'[2..$]' \
   #      -b      BOLD.nii'[1..'`expr $NumVol - 2`']' \
   #      -c      Nulled.nii'[1..'`expr $NumVol - 2`']' \
   #      -d      Nulled.nii'[0..'`expr $NumVol - 3`']' \
   #      -expr '(0.5*c+0.5*d)/(1.0*a+0.0*b)' -overwrite  
 
   # concatinate the first VASO volume with the rest of the sequence
   3dTcat -overwrite -prefix VASO.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii tmp.VASO_vollast.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii tmp.VASO_vollast.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers

 
#echo ' remove last time point in BOLD'
#NumVol=`3dinfo -nv BOLD.nii`
#echo "NumVol of BOLD is '$Numvol'  "
#3dcalc -prefix BOLD.nii \
#         -a      BOLD.nii'[1..'`expr $NumVol - 1`']' \
#         -expr 'a' -overwrite

  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
     BOLD.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
     VASO.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
     VASO.nii'[1..$]'



