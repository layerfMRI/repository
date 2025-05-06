#!/bin/bash

#generating motion mask


echo $1

NumVol=`3dinfo -nv $1`
echo $NumVol
3dTcat -overwrite -prefix npo_$1 $1'[1]'    $1'[0..'`expr $NumVol - 2`']'
3dTcat -overwrite -prefix nmo_$1 $1'[1..$]' $1'['`expr $NumVol - 2`']'
3dCalc -a $1 -b npo_$1 -c nmo_$1 -overwrite -prefix calib_$1 -expr '0.5*a+0.25*b+0.25*c' 
3dCalc -a $1 -b npo_$1 -c nmo_$1 -overwrite -prefix error_$1 -expr 'abs(0.5*a-0.25*b-0.25*c)' 
3dTstat -mean -prefix meanerror_$1 error_$1'[2..'`expr $NumVol - 2`']'

rm nmo_$1
rm npo_$1




echo "done"
