#!/bin/bash

#12
#3drefit -deoblique ${dset6_deob}
#3drefit -deoblique ${dset7_deob}

# create weight, essentially an "inner" block (smoothed at the
# boundary) to remove influence of differing FOV coverage

3dautomask -prefix moma.nii.gz -peels 3 -dilate 2 *_bold*.nii.gz


3dZeropad -A -4 -P -4 -I -4 -S -4 -R -4 -L -4 \
    -overwrite                                \
    -prefix _tmp_AAA.nii.gz                   \
      moma.nii.gz

3dcalc                           \
    -overwrite                   \
    -a           _tmp_AAA.nii.gz \
    -expr        '100*a'           \
    -prefix      _tmp_BBB.nii.gz \
    -datum       short

3dZeropad                                     \
    -overwrite                                \
    -master         moma.nii.gz      \
    -prefix         _tmp_CCC.nii.gz           \
    _tmp_BBB.nii.gz 

3dmerge                                       \
    -overwrite                                \
    -1blur_sigma    3                         \
    -prefix         weight_gauss.nii.gz       \
    _tmp_CCC.nii.gz

rm *_tmp_*

3dcalc -overwrite -b weight_gauss.nii.gz -expr 'step(b-85)' -prefix moma.nii.gz


# calculate mot alignment, with *solid body (6 DOF)*
cnt=100
echo "starting file loop nulled"

for filename in ./S*_cbv*.nii.gz
do
echo $filename
3dCopy $filename ./Basis_cbv_${cnt}.nii -overwrite
#3dTcat -prefix Basis_cbv_${cnt}.nii Basis_cbv_${cnt}.nii'[2..3]' Basis_cbv_${cnt}.nii'[2..$]' -overwrite
3dTstat -prefix n_reference.nii.gz Basis_cbv_${cnt}.nii'[1..3]'


set ttt = 020
3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_cbv_${cnt}.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_Basis_cbv_${cnt}.nii                                 \
    -base           n_reference.nii.gz                                           \
    -source         Basis_cbv_${cnt}.nii                                      \
    -weight         moma.nii.gz                                    \ 
    -warp           shift_rotate                                             \ 
    -final          wsinc5
# remove the -warp line to make it an affine transformation. 

cnt=$(($cnt+1))

done 



cnt=100
echo "starting file loop notnulled"

for filename in ./S*_bold*.nii.gz
do
echo $filename
3dCopy $filename ./Basis_bold_${cnt}.nii -overwrite
#3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite
3dTstat -prefix nn_reference.nii.gz Basis_bold_${cnt}.nii'[1..3]'


set ttt = 020
3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_bold_${cnt}.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_Basis_bold_${cnt}.nii                                 \
    -base           nn_reference.nii.gz                                           \
    -source         Basis_bold_${cnt}.nii                                      \
    -weight         moma.nii.gz                                      \
    -warp           shift_rotate                                             \
    -final          wsinc5
# remove the -warp line to make it an affine transformation. 

cnt=$(($cnt+1))

done 

# calculate mot alignment, with *full aff (12 DOF)*
#set ttt = 021
#3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_${ttt}.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         allin_dset_${ttt}.nii.gz                                 \
    -base           "${dset6_deob}[5]"                                       \
    -source         "${dset7_deob}[0..10]"                                   \
    -weight         weight_gauss.nii.gz                                      \
    -final          wsinc5

# and navigate underlay to brick 5 to judge alignment
#afni "${dset6_deob}" "${dset7_deob}" allin_dset_*.nii.gz 



