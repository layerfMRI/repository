#!/bin/bash



echo "fange an"

micalc -if $1 -stdev mi_stdev.nii 
micalc -if $1 -mean mean_Bild.nii
3dcalc -a mean_Bild.nii -b mi_stdev.nii -exp "a/b" -prefic "micalc_tSNR_$1" -overwrite 

rm mi_stdev.nii 
rm mean_Bild.nii
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
