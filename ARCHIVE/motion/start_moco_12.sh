#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash

echo "fange an"

for filename in ./S*.nii

do

cp $filename ./Basis_a.nii

mv $filename ./Basis_b.nii

done


fslsplit ./Basis_a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_a.nii splited*

rm splited*

fslsplit ./Basis_b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_b.nii splited*

rm splited*
echo "hole SPM motion batch"
cp /Users/huberl/NeuroDebian/repository/motion/twelf_min_mocobatch2run.m ./twelf_min_mocobatch2run.m
/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "twelf_min_mocobatch2run"

gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco.txt"

echo "und tschuess"