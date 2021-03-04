#!/bin/bash


echo "It starts now"


#Remove non-steady_state of first time stepts
3dcalc  -prefix ene.nii -a $1'[0..3]' -overwrite -expr 'a' -overwrite
3dcalc  -prefix mene.nii -a $1'[4..7]' -overwrite -expr 'a' -overwrite
3dcalc  -prefix mu.nii -a $1'[4..$]' -overwrite -expr 'a' -overwrite

3dTcat -overwrite -prefix Basis.nii  mene.nii mene.nii mu.nii

rm ene.nii
rm mene.nii
rm mu.nii


3dTstat -mean -prefix mean_nulled.nii Basis.nii'[1..$(2)]' -overwrite
3dTstat -mean -prefix mean_notnulled.nii Basis.nii'[0..$(2)]' -overwrite


# Run motion correction. Athought I originally did this on BOLD and Null together,
# I separated them here since these are the final BOLD time series & I'd need to make
# a distinct run for these data anyway.

NumVol=`3dinfo -nv Basis.nii`
echo "NumVol of BOLD is '$NumVol' "


3dcalc -overwrite -prefix Nulled.nii -a Basis.nii'[1..'`expr $NumVol - 2`'(2)]' -expr 'a'
3dcalc -overwrite -prefix NotNulled.nii -a Basis.nii'[0..'`expr $NumVol - 3`'(2)]' -expr 'a'


#renzo  learn how to do moc with motionmask
3dvolreg -overwrite -prefix BOLD.volreg.nii -base mean_notnulled.nii -1Dmatrix_save BOLDmatri -dfile BOLD.dfile.1D -1Dfile BOLD.mot.1D  -quitic NotNulled.nii

3dvolreg -overwrite -prefix Nulled.volreg.nii -base mean_nulled.nii  -1Dmatrix_save Nulledmatri -dfile Nulled.dfile.1D -1Dfile Nulled.mot.1D -quitic Nulled.nii

rm mean_nulled.nii
rm mean_notnulled.nii


gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco_afni.txt"





echo "Calculate VASO!"


# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume

  NumVol=`3dinfo -nv BOLD.volreg.nii`
  3dcalc -prefix tmp.VASO_vol1.nii \
         -a      BOLD.volreg.nii'[0]' \
         -b      Nulled.volreg.nii'[0]' \
         -expr 'b/a' -overwrite

 # 3dcalc -prefix tmp.VASO_volend.nii \
 #        -a      BOLD.volreg.nii'['`expr $NumVol - 1`']' \
 #        -b      Nulled.volreg.nii'['`expr $NumVol - 1`']' \
 #        -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv BOLD.volreg.nii`
 3dcalc -prefix  VASO.volreg.nii \
         -a      BOLD.volreg.nii'[0..'`expr $NumVol - 2`']' \
         -b      BOLD.volreg.nii'[1..'`expr $NumVol - 1`']' \
         -c      Nulled.volreg.nii'[0..'`expr $NumVol - 2`']' \
         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
 #  3dTcat -overwrite -prefix VASO.volreg.nii  tmp.VASO_othervols.nii tmp.VASO_volend.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
#srm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers


  3drefit -TR 3.0 VASO.volreg.nii
  3drefit -TR 3.0 BOLD.volreg.nii
 
#echo ' remove last time point in BOLD'
NumVol=`3dinfo -nv BOLD.volreg.nii `
echo "NumVol of BOLD is '$Numvol'  "
3dcalc -prefix BOLD.volreg.nii \
         -a      BOLD.volreg.nii'[0..'`expr $NumVol - 2`']' \
         -expr 'a' -overwrite


#echo ' remove last time point in BOLD'


  3dTstat  -overwrite -mean -prefix MEAN_BOLD.nii \
     BOLD.volreg.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_BOLD.nii \
     BOLD.volreg.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix MEAN_VASO.nii \
     VASO.volreg.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_VASO..nii \
     VASO.volreg.nii'[1..$]'

  3dTstat  -overwrite -mean  -prefix MEAN_Nulled.nii \
     Nulled.volreg.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix tSNR_Nulled.nii \
     Nulled.volreg.nii'[1..$]'



3dcalc -prefix T1_like.nii \
        -a     MEAN_BOLD.nii \
	-b     MEAN_Nulled.nii \
         -expr '(a+b)/(a-b)' -overwrite

