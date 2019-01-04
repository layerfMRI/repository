#!/bin/bash

mkdir gonogo
mkdir alpha 

3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_0b.nii Nulled_Basis_2b.nii Nulled_Basis_4b.nii -overwrite 
3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_0a.nii Not_Nulled_Basis_2a.nii Not_Nulled_Basis_4a.nii -overwrite 

mv Nulled_Basis_b.nii ./alpha/Nulled_Basis_b.nii
mv Not_Nulled_Basis_a.nii ./alpha/Not_Nulled_Basis_a.nii

3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_1b.nii Nulled_Basis_3b.nii -overwrite 
3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_1a.nii Not_Nulled_Basis_3a.nii  -overwrite 

3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_1b.nii Nulled_Basis_3b.nii Nulled_Basis_5b.nii -overwrite 
3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_1a.nii Not_Nulled_Basis_3a.nii Not_Nulled_Basis_5a.nii -overwrite 

mv Nulled_Basis_b.nii ./gonogo/Nulled_Basis_b.nii
mv Not_Nulled_Basis_a.nii ./gonogo/Not_Nulled_Basis_a.nii

cd alpha 
afni_VASO_flex.sh
cd ../gonogo
afni_VASO_flex.sh

3dcalc -a VASO_LN.nii'[0..$(2)]' -prefix VASO.nii -datum short -overwrite -expr 'a*100'
3drefit -TR 4 VASO.nii 
3drefit -TR 4 BOLD.nii 
