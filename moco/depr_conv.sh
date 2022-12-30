#!/bin/bash


echo "fange an"
mkdir ./nii

cd ./*


isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}.nii -wdialect fsl -repn s16bit

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

# in odert of make gtate work is needs to be installed on mac: "brew install coreutils" 


cd ../


#touch war_hier.txt

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
