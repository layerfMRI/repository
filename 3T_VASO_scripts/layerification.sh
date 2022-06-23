#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


cd layers 

LN2_LAYERS -rim rim.nii  -nr_layers 9 -iter_smooth 500 -incl_borders -equal_counts -equivol
mv rim_layerbins_equivol.nii layers.nii


cd ../..
done


echo "und tschuess"

 
