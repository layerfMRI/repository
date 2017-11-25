#!/bin/bash


echo "fange an"

3dWarp -card2oblique $1 -prefix obliqued.nii $2 -overwrite
3dresample -master $1 -inset obliqued.nii -rmode Li -prefix "regridded_$2" -overwrite

rm obliqued.nii

echo "MAFI2EPI.sh MEAN_EPI.nii XB1.nii"
