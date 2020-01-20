#!/bin/bash


echo "It starts now:    I expect two files Not_Nulled_Basis_a.nii and Nulled_Basis_b.nii that are motion corrected with SPM"


#3dmean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_*a.nii 
#3dmean -prefix Nulled_Basis_b.nii Nulled_Basis_*b.nii

#3dTcat -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_*a.nii 
#3dTcat -prefix Nulled_Basis_b.nii Nulled_Basis_*b.nii


NumVol=`3dinfo -nv Nulled_Basis_b.nii`
3dcalc -a Nulled_Basis_b.nii'[3..'`expr $NumVol - 2`']' -b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 2`']' -expr 'a+b' -prefix combined.nii -overwrite
3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii

3dcalc -a Nulled_Basis_b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
3dcalc -a Not_Nulled_Basis_a.nii'[0..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

3drefit -space ORIG -view orig -TR 5 BOLD.nii
3drefit -space ORIG -view orig -TR 5 Nulled.nii

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite

3dUpsample -overwrite  -prefix Nulled_intemp.nii -n 2 -input Nulled.nii
3dUpsample -overwrite  -prefix BOLD_intemp.nii   -n 2 -input   BOLD.nii

NumVol=`3dinfo -nv BOLD_intemp.nii`

3dTcat -overwrite -prefix Nulled_intemp.nii Nulled_intemp.nii'[0]' Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' 

## you only ned this is the first image is a VASO image
#  3dcalc -prefix tmp.VASO_vol1.nii \
#         -a      Nulled_intemp.nii'[0]' \
#         -b      BOLD_intemp.nii'[0]' \
#         -expr '(a/b-step(a/b-2)*(a/b-1))*step(a/b)' -overwrite
         
#  3dcalc -prefix tmp.VASO_vollast.nii \
#         -b      Nulled_intemp.nii'[$]' \
#         -a      BOLD_intemp.nii'[$]' \
#         -expr 'b/a' -overwrite



#  3dcalc -prefix tmp.VASO_othervols.nii \
#         -b      BOLD_intemp.nii'[1..$]' \
#         -a      Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' \
#         -expr '(a/b-step(a/b-2)*(a/b-1))*step(a/b)' -overwrite
  
# 3dTcat -overwrite -prefix VASO_intemp.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii 
#rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii tmp.VASO_vollast.nii

mv Nulled_intemp.nii temp.nii 
mv BOLD_intemp.nii Nulled_intemp.nii
mv temp.nii  BOLD_intemp.nii
rm temp.nii


mv Nulled.nii temp.nii 
mv BOLD.nii Nulled.nii
mv temp.nii  BOLD.nii
rm temp.nii

LN_BOCO -Nulled Nulled_intemp.nii -BOLD BOLD_intemp.nii 

  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
     VASO_LN.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
     VASO_LN.nii'[1..$]'



3drefit -TR 1 BOLD_intemp.nii
3drefit -TR 1 VASO_LN.nii

LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5

start_bias_field.sh dnoised_T1_weighted.nii

LN_SKEW -timeseries BOLD.nii
LN_SKEW -timeseries VASO_LN.nii


echo "und tschuess"
