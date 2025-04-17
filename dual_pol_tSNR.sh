#!/bin/bash

#generating motion mask

NumVol=`3dinfo -nv S00_AEPIG_8_test.nii.gz`
echo $NumVol

for filename in moco_S*_AEPIG*.nii.gz
do
echo $filename

NumVol=`3dinfo -nv ${filename}`
echo $NumVol
3dTcat -overwrite -prefix npo_${filename} ${filename}'[1]'    ${filename}'[0..'`expr $NumVol - 2`']'
3dTcat -overwrite -prefix nmo_${filename} ${filename}'[1..$]' ${filename}'['`expr $NumVol - 2`']'
3dCalc -a ${filename} -b npo_${filename} -c nmo_${filename} -overwrite -prefix calib_${filename} -expr '0.5*a+0.25*b+0.25*c' 
3dCalc -a ${filename} -b npo_${filename} -c nmo_${filename} -overwrite -prefix error_${filename} -expr 'abs(0.5*a-0.25*b-0.25*c)' 
3dTstat -mean -prefix meanerror_${filename} error_${filename}'[2..'`expr $NumVol - 2`']'

rm nmo_${filename}
rm npo_${filename}

done 


for filename in moco_S*_AEPIG*.nii.gz
do
echo $filename
oddeven.sh ${filename}

done 

echo "done"
