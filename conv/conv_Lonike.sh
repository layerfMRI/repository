#!/bin/bash


echo "fange an"




dir=${PWD##*/}

#isisconv can be installed here https://layerfmri.com/2018/11/29/installing-isisconv/
isisconv -in . -out ./S_{DICOM/AcquisitionNumber}_{DICOM/CSAImageHeaderInfo/ICE_Dims}.nii -wdialect fsl -repn s16bit
#rname is a bash command: brew install rename, or sudo-apt get install rename.
rename -e 's/\d+/sprintf("%03d",$&)/e' -- *.nii
fslmerge -t combined.nii S*.nii

mv combined.nii ../${dir##*/}_combined.nii
#fslmerge -t notnulled.nii S*_1_1_1_2_*.nii
#rm S*_1_1_1_2_*.nii 
#fslmerge -t nulled.nii  S*_1_1_1_1_*.nii
rm S*_1_1_1*.nii


##################################################################################### 
#### combining odd and even images that are stored in seperate files a la zipper ####
#####################################################################################
## 0 2 4 6 8 ...
#fslsplit nulled e_
## 1 3 5 7 9 ...
#fslsplit notnulled o_

#la=`imglob -extension [eo]_*`
#lb=`ls -1 $la | sort -t _ -k 2`
#fslmerge -t combined.nii $lb

#rm e_*.nii
#rm o_*.nii


#MOCO_Kronbichler.sh 
#BOCO.sh 







#touch war_hier.txt
#isisconv -in . -out ./S{DICOM/CSAImageHeaderInfo/ICE_Dims}_{DICOM/AcquisitionNumber}.nii -wdialect fsl -repn s16bit
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
