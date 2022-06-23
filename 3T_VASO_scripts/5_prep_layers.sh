#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


#mkdir layers 

cd layers
#cp ../AV/T1_weighted_denoised.nii layersT1.nii 
cp ../AV/VASO_LN+.feat/stats/cope3.nii VASO.nii
cp ../AV/BOLD_intemp.feat/stats/cope4.nii BOLD.nii

#ResampleImage 3 layersT1.nii sc_layersT1.nii  0.25x0.25x0.25 0 3[‵l‵] 6
ResampleImage 3 VASO.nii sc_VASO.nii  0.25x0.25x0.25 0 3['l'] 6
ResampleImage 3 BOLD.nii sc_BOLD.nii  0.25x0.25x0.25 0 3['l'] 6

#short_me.sh  sc_layersT1.nii 
short_me.sh  sc_VASO.nii 
short_me.sh  sc_BOLD.nii 


cd ../../

done


echo "und tschuess"

 
