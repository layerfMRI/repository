#!/bin/bash

#Temporal filtering


echo "starting with drift correction"
fslmaths $1 -bptf -1 1 filtered_$1

echo "starting with first melodic decomposition"

melodic -i filtered_$1 --nomask --nobet -d 50

cp  filtered_*.ica/melodic_IC.nii ./

fslsplit melodic_IC.nii components -t

echo "Look at the components and take the ones you like in the main folder"
read -n 1 -s -r -p "  Press any key to continue"


/Applications/FSLeyes.app/Contents/MacOS/fsleyes filtered_Bold.ica/mean.nii melodic_IC.nii


read -n 1 -s -r -p "  Press any key to continue"

echo "prepatring network"
3dMean -prefix -overwrite network_$1 components*.nii
fslmaths network_$1 -s 2.5 smoothed_network_$1
fslmaths smoothed_network_$1 -thr 0.3 -Tmin -bin mask -odt char


echo "Look at the mask and change it, if necessary "
echo "e.g. change threshold: fslmaths smoothed_network_ -thr 0.3 -Tmin -bin mask -odt char"
read -n 1 -s -r -p "  Press any key to continue"

fslview filtered_Bold.ica/mean.nii mask.nii


3dcalc -a filtered_$1 -b mask.nii -expr 'a*b' -prefix masked_filtered_$1 -overwrite

echo "running ICA again with 200 components"
melodic -i masked_filtered_$1 --nomask --nobet -d 200

cp  masked_filtered_*.ica/melodic_IC.nii ./ROI_IC.nii

#rm smoothed_network_$1 
#rm network_$1 
