#!/bin/bash


antsApplyTransforms --interpolation BSpline[5] -d 3 -i $1 -o warped_$1 -r $2 -t initial_matrix.txt

#for file in *zstat*.nii
#do
# antsApplyTransforms --interpolation BSpline[5] -d 3 -i $file -o warped_$file -r reference.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
#done


