#!/bin/bash

cnt=0

3dautomask -prefix moma.nii -peels 3 -dilate 2 S*.nii 

for filename in ./S*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[3..5]' Basis_${cnt}a.nii'[3..$]' -overwrite

3dinfo -nt Basis_${cnt}a.nii >> NT.txt

cnt=$(($cnt+1))

done



#export DYLD_FALLBACK_LIBRARY_PATH="/Users/l.huber/repository/moco/:$DYLD_LIBRARY_PATH"
cp /Users/administrator/Git/repository/moco/mocobatch_BOLD_flex.m ./
/Applications/MATLAB_R2022a.app/bin/matlab -nodesktop -nosplash -r "mocobatch_BOLD_flex"

gnuplot "/Users/administrator/Git/repository/moco/gnuplot_moco_BOLD.txt"

rm ./Basis_*.nii
