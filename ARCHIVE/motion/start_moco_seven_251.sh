#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash



cp ./AMPL1.nii ./Basis_0a.nii
cp ./AMPL1.nii ./Basis_0b.nii

cp ./AMPL2.nii ./Basis_1a.nii
cp ./AMPL2.nii ./Basis_1b.nii

cp ./AMPL3.nii ./Basis_2a.nii
cp ./AMPL3.nii ./Basis_2b.nii

cp ./AMPL4.nii ./Basis_3a.nii
cp ./AMPL4.nii ./Basis_3b.nii

cp ./AMPL5.nii ./Basis_4a.nii
cp ./AMPL5.nii ./Basis_4b.nii

cp ./AMPL6.nii ./Basis_5a.nii
cp ./AMPL6.nii ./Basis_5b.nii

cp ./AMPL7.nii ./Basis_6a.nii
cp ./AMPL7.nii ./Basis_6b.nii

fslsplit ./Basis_0a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_0a.nii splited*

rm splited*

fslsplit ./Basis_0b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_0b.nii splited*

rm splited*



fslsplit ./Basis_1a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_1a.nii splited*

rm splited*

fslsplit ./Basis_1b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_1b.nii splited*

rm splited*


fslsplit ./Basis_2a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_2a.nii splited*

rm splited*

fslsplit ./Basis_2b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_2b.nii splited*

rm splited*



fslsplit ./Basis_3a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_3a.nii splited*

rm splited*

fslsplit ./Basis_3b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_3b.nii splited*

rm splited*


fslsplit ./Basis_4a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_4a.nii splited*

rm splited*

fslsplit ./Basis_4b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_4b.nii splited*

rm splited*


fslsplit ./Basis_5a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_5a.nii splited*

rm splited*

fslsplit ./Basis_5b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_5b.nii splited*

rm splited*


fslsplit ./Basis_6a.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_6a.nii splited*

rm splited*

fslsplit ./Basis_6b.nii splited 

cp splited0004.nii splited0000.nii
cp splited0005.nii splited0001.nii
cp splited0006.nii splited0002.nii
cp splited0007.nii splited0003.nii

fslmerge -t Basis_6b.nii splited*

rm splited*

echo "hole SPM motion batch"
cp /Users/huberl/NeuroDebian/repository/motion/seven_eli_mocobatch2run.m ./seven_eli_mocobatch2run.m
/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "seven_eli_mocobatch2run"

gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco_multi.txt"

echo "und tschuess"
