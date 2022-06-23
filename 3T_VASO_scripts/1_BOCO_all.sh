#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


mkdir M1
mv Not_Nulled_Basis_0a.nii M1/Not_Nulled_Basis_a.nii
mv Nulled_Basis_0b.nii M1/Nulled_Basis_b.nii
cd M1 
afni_VASO_flex_Korea.sh 
cd ..

mkdir M2
mv Not_Nulled_Basis_1a.nii M2/Not_Nulled_Basis_a.nii
mv Nulled_Basis_1b.nii M2/Nulled_Basis_b.nii
cd M2 
afni_VASO_flex_Korea.sh 
cd ..


cd ..
done


echo "und tschuess"

 
