#!/bin/bash

echo "fange an"

3dTstat -mean -prefix "odd_mean$1" $1'[4..$(2)]' -overwrite
3dTstat -mean -prefix "even_mean$1" $1'[5..$(2)]' -overwrite

3dcalc -a "odd_mean$1" -b "even_mean$1" -expr 'a-b' -prefix "Diff_odd_even_$1" -overwrite
3dcalc -a "odd_mean$1" -b "even_mean$1" -expr '(a+b)/2.' -prefix "mean_odd_even_$1" -overwrite

LOCAL_ENTROPY "Diff_odd_even_$1" 3 
LOCAL_ENTROPY "mean_odd_even_$1" 3

 3dcalc -a "LocalMean_mean_odd_even_$1" -b "LocalSTD_Diff_odd_even_$1" -expr 'a/b' -prefix "SNR0_$1" -overwrite


rm odd*.nii
rm mean*.nii
rm Local*.nii
rm Diff*.nii
rm even*.nii


#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
