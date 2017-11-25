#!/bin/bash

echo "I started 64 prisma"

mkdir "$1_nii"

cd $1

pwd

find . -name '*.dcm' |
while read filename
do
isisconv -in ./$filename -out ../$1_nii/S_{acquisitionNumber}_{DICOM/CSAImageHeaderInfo/UsedChannelString}.nii
done

cd ../$1_nii/

fslmerge -t C01.nii *X-------------------------------.nii
fslmerge -t C02.nii *-X------------------------------.nii
fslmerge -t C03.nii *--X-----------------------------.nii
fslmerge -t C04.nii *---X----------------------------.nii
fslmerge -t C05.nii *----X---------------------------.nii
fslmerge -t C06.nii *-----X--------------------------.nii
fslmerge -t C07.nii *------X-------------------------.nii
fslmerge -t C08.nii *-------X------------------------.nii
fslmerge -t C09.nii *--------X-----------------------.nii
fslmerge -t C10.nii *---------X----------------------.nii
fslmerge -t C11.nii *----------X---------------------.nii
fslmerge -t C12.nii *-----------X--------------------.nii
fslmerge -t C13.nii *------------X-------------------.nii
fslmerge -t C14.nii *-------------X------------------.nii
fslmerge -t C15.nii *--------------X-----------------.nii
fslmerge -t C16.nii *---------------X----------------.nii
fslmerge -t C17.nii *----------------X---------------.nii
fslmerge -t C18.nii *-----------------X--------------.nii
fslmerge -t C19.nii *------------------X-------------.nii
fslmerge -t C20.nii *-------------------X------------.nii
fslmerge -t C21.nii *--------------------X-----------.nii
fslmerge -t C22.nii *---------------------X----------.nii
fslmerge -t C23.nii *----------------------X---------.nii
fslmerge -t C24.nii *-----------------------X--------.nii
fslmerge -t C25.nii *------------------------X-------.nii
fslmerge -t C26.nii *-------------------------X------.nii
fslmerge -t C27.nii *--------------------------X-----.nii
fslmerge -t C28.nii *---------------------------X----.nii
fslmerge -t C29.nii *----------------------------X---.nii
fslmerge -t C30.nii *-----------------------------X--.nii
fslmerge -t C31.nii *------------------------------X-.nii
fslmerge -t C32.nii *-------------------------------X.nii


find . -name 'S*.nii' |
while read filename
do
rm $filename 
done


#find ./ -type f -name '*.dcm' -exec sh -c 'echo $filename' {} \;

#isisconv -in ./ -out ../S_{DICOM/CSAImageHeaderInfo/UsedChannelString}.nii

#isisdump -in ./ 

#echo $filename
#isisdump -in $filename  |grep UsedChannelString ; 
#done


#echo "fange an"
#mkdir ./nii

#cd ./*

#for dir in ./*/
#do
#dir=${dir%*/}
#cd ./$dir
#echo  ${dir##*/}

#isisconv -in . -out ../../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{UsedChannelString}.nii -wdialect fsl -repn s16bit
#echo  $(gdate +%S.%N)

#cd ..
#done



#touch war_hier.txt

#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
