#!/bin/bash


3dautomask -prefix moma.nii -peels 3 -dilate 2 S*_bold*.nii.gz

#just in case there is already a proken file from previous unsuccessfull attempts.
rm NT.txt

cnt=1

cnt=1
for filename in ./S*_bold*.nii.gz
do
echo $filename
3dCopy $filename ./Basis_bold_${cnt}.nii -overwrite
3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite
3dinfo -nt Basis_bold_${cnt}.nii >> NT.txt
cnt=$(($cnt+1))
done

cp /Users/administrator/Git/repository/moco/mocobatch_bold.m ./


/Applications/MATLAB_R2023a.app/bin/matlab  -nodesktop -nosplash -r "mocobatch_bold"
gnuplot "/Users/administrator/Git/repository/moco/gnuplot_moco_bold.txt"

rm ./Basis_*.nii ./Basis_*.mat
