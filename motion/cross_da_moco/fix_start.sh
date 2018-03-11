#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash



fslsplit $1 splited_ 

cp splited_0006.nii splited_0000.nii
cp splited_0007.nii splited_0001.nii
cp splited_0006.nii splited_0002.nii
cp splited_0007.nii splited_0003.nii


fslmerge -t $1 splited_*

rm splited_*

echo "und tschuess"
