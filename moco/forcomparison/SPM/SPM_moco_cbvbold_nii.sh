#!/bin/bash


#just in case there is already a proken file from previous unsuccessfull attempts.
rm NT.txt

cnt=1
for filename in ./S*_cbv*.nii
do
echo $filename
3dCopy $filename ./Basis_cbv_${cnt}.nii -overwrite
3dTcat -prefix Basis_cbv_${cnt}.nii Basis_cbv_${cnt}.nii'[2..3]' Basis_cbv_${cnt}.nii'[2..$]' -overwrite
3dinfo -nt Basis_cbv_${cnt}.nii >> NT.txt
cnt=$(($cnt+1))
done

cnt=1
for filename in ./S*_bold*.nii
do
echo $filename
3dCopy $filename ./Basis_bold_${cnt}.nii -overwrite
3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite
3dinfo -nt Basis_bold_${cnt}.nii >> NT.txt
cnt=$(($cnt+1))
done


/Applications/MATLAB_R2022a.app/bin/matlab  -nodesktop -nosplash -r "mocobatch_cbvbold"
gnuplot "/Users/administrator/Git/repository/moco/gnuplot_moco_cbvbold.txt"

rm ./Basis_*.nii ./Basis_*.mat
