#!/bin/bash


echo "fange an"
mkdir ./nii


for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}

dcm2niix -ba y -z y -o ../nii/ -f S%s_%d_e%e ./


# in odert of make gtate work is needs to be installed on mac: "brew install coreutils" 

cd ..
done



#touch war_hier.txt

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
