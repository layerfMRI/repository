#!/bin/bash

echo "fange an"

3dcalc -prefix "sBasis_a.nii" -a  "Basis_a.nii"'[4..$]'  -expr 'a' -overwrite
3dcalc -prefix "first_Basis_a.nii" -a  "sBasis_a.nii"'[0..3]'  -expr 'a' -overwrite

fslmerge -t Basis_a.nii "first_Basis_a.nii" "sBasis_a.nii"

rm "sBasis_a.nii"
rm "first_Basis_a.nii"

3dcalc -prefix "sBasis_b.nii" -a  "Basis_b.nii"'[4..$]'  -expr 'a' -overwrite
3dcalc -prefix "first_Basis_b.nii" -a  "sBasis_b.nii"'[0..3]'  -expr 'a' -overwrite

fslmerge -t Basis_b.nii "first_Basis_b.nii" "sBasis_b.nii"

rm "sBasis_b.nii"
rm "first_Basis_b.nii"

echo "und tschuess"

 
