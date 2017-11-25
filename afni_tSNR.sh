#!/bin/bash



echo "fange an"

3dTstat -mean -prefix "afni_tSNR_$1" $1 -overwrite

3dTstat -mean -prefix tSNR_output $1 -overwrite


#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
