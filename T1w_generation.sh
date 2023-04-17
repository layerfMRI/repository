#!/bin/bash


# This is for Jason to generate T1 reference image. 
 
for filename in ./*_S00*.nii.gz
do
echo $filename


3dAutomask -prefix mask.nii -peels 3 -dilate 2  $filename

3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_cbv_S00.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_TI1.nii                                 \
    -base           $filename'[3..3]'                                           \
    -source          $filename                                      \
    -weight         mask.nii                                    \ 
    -warp           shift_rotate                                             \ 
    -final          wsinc5

done 

for filename in ./*_S02*.nii.gz
do
echo $filename

3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_cbv_S02.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_TI2.nii                                 \
    -base           $filename'[3..3]'                                           \
    -source          $filename                                      \
    -weight         mask.nii                                    \ 
    -warp           shift_rotate                                             \ 
    -final          wsinc5

done 


3dTstat -mean -prefix TI1.nii moco_TI1.nii'[2..$]'
3dTstat -mean -prefix TI2.nii moco_TI2.nii'[2..$]'

3dcalc -a Ti1.nii -b Ti2.nii -overwrite -prefix ratio.nii -expr 'a/b'

#Clean division by zero 

3dcalc -a ratio.nii -prefix ratio.nii  -overwrite  -expr 'max(0,min(1,a))'


#the following is an ANts command. Its a diffusion filter, I think there is a pendant oin AFNI with 3danisosmooth, but I do not know how to use it 
DenoiseImage -d 3 -n Rician -i ratio.nii -o denoised_ratio.nii 
