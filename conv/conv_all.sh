#!/bin/bash


echo "fange an"
mkdir ./nii

cd ./*

for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}

isisconv -in . -out ../../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_$(gdate +%S.%N)_{coilChannelMask}.nii -wdialect fsl -repn s16bit
echo  $(gdate +%S.%N)

cd ..
done



#touch war_hier.txt

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
