#!/bin/bash

echo "fange an mit Bas"
#!/bin/bash



fslsplit $1 splited_ 


cp splited_0002.nii splited_0000.nii
cp splited_0003.nii splited_0001.nii



fslmerge -t $1 splited_*

rm splited*




echo "und tschuess"
