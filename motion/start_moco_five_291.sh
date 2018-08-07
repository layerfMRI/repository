#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash



cp ./AMPL0.nii ./Basis_0a.nii
cp ./AMPL0.nii ./Basis_0b.nii

cp ./AMPL1.nii ./Basis_1a.nii
cp ./AMPL1.nii ./Basis_1b.nii

cp ./AMPL2.nii ./Basis_2a.nii
cp ./AMPL2.nii ./Basis_2b.nii

cp ./AMPL3.nii ./Basis_3a.nii
cp ./AMPL3.nii ./Basis_3b.nii

cp ./AMPL4.nii ./Basis_4a.nii
cp ./AMPL4.nii ./Basis_4b.nii



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


echo "hole SPM motion batch"
cp /Users/huberl/NeuroDebian/repository/motion/five_twonineone_mocobatch2run.m ./five_twonineone_mocobatch2run.m
/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "five_twonineone_mocobatch2run"

gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco_multi.txt"


3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_0a.nii Not_Nulled_Basis_2a.nii Not_Nulled_Basis_4a.nii 
3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_0b.nii Nulled_Basis_2b.nii Nulled_Basis_4b.nii 


afni_VASO_eval_SPM.sh

echo "und tschuess"
