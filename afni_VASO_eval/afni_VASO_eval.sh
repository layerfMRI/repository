#!/bin/bash


echo "starte jetzt"

# Run identifiers listed in the temporal order they were collected

# Run identifiers to use on the file names in the same order as $RunList
mkdir $1

# The directory were I'm processing these data
cd ./$1

# Symbollically link the files from the original data directory to the processing directory
for idx in 0  ; do
   cp ../$1.nii ./$1.nii
done

# The images are improperly listed as in TLRC space so I'm changing that to orig
# (This is an AFNI distinction for files that are in their subject-original space
#    vs aligned to a standardize template)
#
# The true TR is actually 1.5s rather than 1.49900s.
#
# 3drefit can correct both of these things
#   The way this is written, it will change values for the files in the D00_OrigData directory


for filename in `ls *.nii`; do
  echo ${filename}
  3drefit -space ORIG -view orig -TR 1.5 ${filename}
done




# Run motion correction. Athought I originally did this on BOLD and Null together,
# I separated them here since these are the final BOLD time series & I'd need to make
# a distinct run for these data anyway.
#
# All runs are being aligned to the first volume of ValsalvaAscend1.nii
#  The mot.1D file contains the 6 motion parameters. 
# The dfile.1D contains the 6 motion parameters + 3 summary-of-motion parameters


3dTstat -mean -prefix mean_nulled.nii $1.nii'[3..$(2)]' -overwrite
3dTstat -mean -prefix mean_notnulled.nii $1.nii'[2..$(2)]' -overwrite




  3dvolreg -overwrite -prefix BOLD.volreg.nii -base mean_notnulled.nii \
    -dfile BOLD.dfile.1D -1Dfile BOLD.mot.1D $1.nii'[2..$(2)]'
  3dvolreg -overwrite -prefix Null.volreg.nii -base  mean_nulled.nii \
    -dfile Null.dfile.1D -1Dfile Null.mot.1D $1.nii'[3..$(2)]'

rm mean_nulled.nii
rm mean_notnulled.nii

# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes
# I was mainly doing this as a check to make sure motion correction worked reasonably.
# A TSNR calculation should probably be done after non-linear drift removal.




# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume
  3dcalc -prefix tmp.VASO_vol1.nii \
         -a      BOLD.volreg.nii'[1]' \
         -b      Null.volreg.nii'[0]' \
         -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv BOLD.volreg.nii`
  3dcalc -prefix tmp.VASO_othervols.nii \
         -a      BOLD.volreg.nii'[1..'`expr $NumVol - 2`']' \
         -b      BOLD.volreg.nii'[2..$]' \
         -c      Null.volreg.nii'[1..$]' \
         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
   3dTcat -overwrite -prefix VASO.volreg.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers
for filename in `ls *BOLD*.nii *VASO*.nii`; do
  echo ${filename}
  3drefit -TR 3.0 ${filename}
done
 
echo 'add two'
NumVol=`3dinfo -nv BOLD.volreg.nii`
echo 'NumVol of BOLD is' $Numvol
miconv -trange 2-$NumVol -noscale BOLD.volreg.nii sBOLD.nii
miconv -trange 2-$NumVol -noscale VASO.volreg.nii sVASO.nii

miconv -trange 0-1 -noscale sBOLD.nii first_BOLD.nii
miconv -trange 0-1 -noscale sVASO.nii first_VASO.nii

fslmerge -t Bold_no_drift.nii first_BOLD.nii sBOLD.nii
fslmerge -t Anti_BOLD_no_drift.nii first_VASO.nii sVASO.nii

rm first_BOLD.nii
rm first_VASO.nii
rm sBOLD.nii
rm sVASO.nii


  3dTstat  -overwrite -mean -stdev -cvarinv -prefix BOLD.MeanStdCVar.nii \
     BOLD.volreg.nii'[1..$]'
  3dTstat  -overwrite -mean -stdev -cvarinv -prefix Null.MeanStdCVar.nii \
     Null.volreg.nii'[1..$]'

