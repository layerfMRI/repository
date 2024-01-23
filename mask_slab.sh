#!/bin/bash


#3drefit -deoblique ${dset6_deob}
#3drefit -deoblique ${dset7_deob}

# create weight, essentially an "inner" block (smoothed at the
# boundary) to remove influence of differing FOV coverage

3dautomask -prefix moma.nii -peels 3 -dilate 2 $1


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
    -1blur_sigma    2                         \
    -prefix         weight_gauss.nii.gz       \
    _tmp_CCC.nii.gz

rm *_tmp_*


# optional: fixing oblique header and removing outer slice 
3dcalc -b weight_gauss.nii.gz -expr 'b*step(b-80)' -prefix mask.nii -overwrite

rm  weight_gauss.nii.gz moma.nii
