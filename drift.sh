#!/bin/bash



echo "fange an"

3dTstat -mean -prefix mean_Bild.nii BOLD.nii -overwrite
echo "mean done"
3dDetrend -prefix detrended.nii -polort 3  BOLD.nii -overwrite
echo "detrend done"
3dcalc -a mean_Bild.nii -b detrended.nii -expr 'a+b' -prefix  detrended_BOLD.nii -overwrite
rm mean_Bild.nii
rm detrended.nii


3dTstat -mean -prefix mean_Bild.nii VASO.nii -overwrite
echo "mean done"
3dDetrend -prefix detrended.nii -polort 3  VASO.nii -overwrite
echo "detrend done"
3dcalc -a mean_Bild.nii -b detrended.nii -expr 'a+b' -prefix  detrended_VASO.nii -overwrite
rm mean_Bild.nii -overwrite
rm detrended.nii -overwrite


#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"


