#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}

isisconv -in . -out ./S{DICOM/CSAImageHeaderInfo/ICE_Dims}.nii -wdialect fsl -repn s16bit
fslmerge -t nulled.nii    S1_1_1_1_*
fslmerge -t notnulled.nii S1_1_1_2_*
rm S1_1_1*.nii

#MOCO_Kronbichler.sh 
#BOCO.sh 

cd ..
done



#touch war_hier.txt
#isisconv -in . -out ./S{DICOM/CSAImageHeaderInfo/ICE_Dims}.nii -wdialect fsl -repn s16bit
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
