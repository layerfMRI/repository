#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


mkdir AV
cd  AV 
3dMean -overwrite -prefix Nulled_Basis_b.nii ../M1/Nulled_Basis_b.nii'[0..421]' ../M2/Nulled_Basis_b.nii'[0..421]'
3dMean -overwrite -prefix Not_Nulled_Basis_a.nii ../M1/Not_Nulled_Basis_a.nii'[0..420]' ../M2/Not_Nulled_Basis_a.nii'[0..420]'
afni_VASO_flex_Korea.sh 
cd ..



cd ..
done


echo "und tschuess"

 
