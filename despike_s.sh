#!/bin/bash



echo "fange an"

3dDespike $1
3dAFNItoNIFTI despike+orig.HEAD -overwrite
mv despike.nii "despiked_$1"
rm despike+orig*

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
