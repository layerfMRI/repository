#!/bin/bash


echo "fange an"
mkdir ./nii


for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}

dcm2niix -ba y -z y -o ../nii/ -f S%s_%d_e%e ./

cd ..
done


echo "und tschuess"

 
