#!/bin/bash


#3drefit -deoblique ${dset6_deob}
#3drefit -deoblique ${dset7_deob}

# create weight, essentially an "inner" block (smoothed at the
# boundary) to remove influence of differing FOV coverage

3dautomask -prefix moma.nii -peels 3 -dilate 2 S*.nii.gz


3dZeropad -A -4 -P -4 -I -4 -S -4 -R -4 -L -4 \
    -overwrite                                \
    -prefix _tmp_AAA.nii.gz                   \
      moma.nii

3dcalc                           \
    -overwrite                   \
    -a           _tmp_AAA.nii.gz \
    -expr        '100*a'           \
    -prefix      _tmp_BBB.nii.gz \
    -datum       short

3dZeropad                                     \
    -overwrite                                \
    -master         moma.nii       \
    -prefix         _tmp_CCC.nii.gz           \
    _tmp_BBB.nii.gz 

3dmerge                                       \
    -overwrite                                \
    -1blur_sigma    3                         \
    -prefix         weight_gauss.nii.gz       \
    _tmp_CCC.nii.gz

rm *_tmp_*


# optional: fixing oblique header and removing outer slice 
3dcalc -overwrite -b weight_gauss.nii.gz -expr 'step(b-55)' -prefix moma.nii


# calculate mot alignment, with *solid body (6 DOF)*
cnt=100
echo "starting file loop nulled"

for filename in S*.nii.gz
do
echo $filename
#3dCopy $filename ./Basis_${cnt}.nii -overwrite
3dMean -prefix n_reference.nii $filename'[2..3]'


set ttt = 020
3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_$filename.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_${filename}                                 \
    -base           n_reference.nii                                           \
    -source         ${filename}                                     \
    -weight         moma.nii                                   \ 
    -overwrite						\
    -final          wsinc5							
#    -warp           shift_rotate                                             \ 
# remove the -warp line to make it an affine transformation. 

cnt=$(($cnt+1))

done 




