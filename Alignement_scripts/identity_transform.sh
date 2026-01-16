#!/bin/bash




antsApplyTransforms -d 3 -i inout.nii -o identity_output.nii -r reference.nii -t identity_matrix.txt


#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
