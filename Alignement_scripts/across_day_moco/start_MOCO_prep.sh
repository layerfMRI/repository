#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash

fslcpgeom ref_notnulled.nii moma.nii

fslsplit $1 splited_ 


cp ref_notnulled.nii splited_0000.nii
cp ref_nulled.nii    splited_0001.nii
cp ref_notnulled.nii splited_0002.nii
cp ref_nulled.nii    splited_0003.nii
cp ref_notnulled.nii splited_0004.nii
cp ref_nulled.nii    splited_0005.nii
cp ref_notnulled.nii splited_0006.nii
cp ref_nulled.nii    splited_0007.nii

fslmerge -t Basis_a.nii splited_*
cp Basis_a.nii Basis_b.nii

rm splited*


/Applications/MATLAB_R2016a.app/bin/matlab -nodesktop -nosplash -r "ninothree_mocobatch2run"

gnuplot "/Users/huberl/NeuroDebian/repository/motion/gnuplot_moco.txt"


echo "und tschuess"
