#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash



cp ./S*.nii ./Basis_a.nii


fslsplit ./Basis_a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_a.nii splited*
cp Basis_a.nii Basis_b.nii
rm splited*



echo "hole SPM motion batch"
cp /Users/huberl/NeuroDebian/repository/motion/ninothree_mocobatch2run.m ./ninothree_mocobatch2run.m
/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "ninothree_mocobatch2run"

gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco.txt"

echo "und tschuess"
