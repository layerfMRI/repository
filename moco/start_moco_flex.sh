#!/bin/bash

cnt=0

3dautomask -prefix moma.nii -peels 3 -dilate 2 S*.nii 

for filename in ./S*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[4..7]' Basis_${cnt}a.nii'[4..$]' -overwrite
cp ./Basis_${cnt}a.nii ./Basis_${cnt}b.nii

3dinfo -nt Basis_${cnt}a.nii >> NT.txt
3dinfo -nt Basis_${cnt}b.nii >> NT.txt
cnt=$(($cnt+1))

done


#export DYLD_FALLBACK_LIBRARY_PATH="/Users/l.huber/repository/moco/:$DYLD_LIBRARY_PATH"
cp /Users/l.huber/repository/moco/mocobatch_VASO_flex.m ./
/Applications/MATLAB_2019b.app/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO_flex"

gnuplot "/Users/l.huber/repository/moco/gnuplot_moco.txt"

rm ./Basis_*.nii
