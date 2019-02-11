#!/bin/bash


echo "I average all :Nulled_Basis_*b.nii and   Not_Nulled_Basis_*a.nii for further processing"

3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_*b.nii
3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_*a.nii 

echo "und tschuess"
