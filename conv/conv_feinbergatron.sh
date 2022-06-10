#!/bin/bash


echo "fange an"
mkdir ./nii


for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}

Dimon -quiet -sort_by_acq_time -infile_pattern "*.IMA" -dicom_org -gert_create_dataset -gert_to3d_prefix testMosaic.nii

mv testMosaic.nii ../nii/$dir.nii

cd ..
done

echo "und tschuess"

 
