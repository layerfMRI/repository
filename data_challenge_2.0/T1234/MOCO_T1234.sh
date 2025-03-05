#!/bin/bash

#generating motion mask
3dAutomask -prefix moma.nii.gz -peels 3 -dilate 2  S*_TI1*.nii.gz

# calculate mot alignment, with *solid body (6 DOF)*
cnt=100
echo "loop for TI1"

for filename in ./S*_TI1*.nii.gz
do
echo $filename
3dCopy $filename ./Basis_TI1_${cnt}.nii -overwrite
3dTstat -mean -prefix TI1_reference.nii.gz Basis_TI1_${cnt}.nii'[1..2]' 

3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_TI1_${cnt}.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_Basis_TI1_${cnt}.nii                                 \
    -base           TI1_reference.nii.gz                                           \
    -source         Basis_TI1_${cnt}.nii                                      \
    -weight         moma.nii.gz                                    \ 
    -final          wsinc5

cnt=$(($cnt+1))
done 



cnt=100
echo "loop for TI1"

for filename in ./S*_TI2*.nii.gz
do
echo $filename
3dCopy $filename ./Basis_TI2_${cnt}.nii -overwrite
3dTstat -mean -prefix TI2_reference.nii.gz Basis_TI2_${cnt}.nii'[1..2]'

3dAllineate                                                                  \
    -1Dmatrix_save  ALLIN_TI2_${cnt}.aff12.1D                                    \
    -cost           lpa                                                      \
    -prefix         moco_Basis_TI2_${cnt}.nii                                 \
    -base           TI2_reference.nii.gz                                           \
    -source         Basis_TI2_${cnt}.nii                                      \
    -weight         moma.nii.gz                                      \
    -final          wsinc5

cnt=$(($cnt+1))
done 
