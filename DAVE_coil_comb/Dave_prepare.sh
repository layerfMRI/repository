#!/bin/bash

echo "fange an"

mv $1 "Dave_output_N.nii"


fslcpgeom  "SOS.nii" "Dave_output_N.nii"

3dTstat -mean -prefix "MEAN_SOS.nii" -overwrite  "SOS.nii"

3dTstat -mean -prefix "MEAN_Dave_N.nii" -overwrite  "Dave_output_N.nii"
 

3dcalc -a "Dave_output_N.nii" -b "MEAN_SOS.nii" -c "MEAN_Dave_N.nii"  -expr 'a*b/c' -overwrite -prefix "Sc_Dave_N.nii" 


mkdir N_opti


mv "Sc_Dave_N.nii"  ./N_opti

rm "MEAN_SOS.nii"

rm "MEAN_Dave_N.nii"

#3dcalc -a "sc_Dave_NN.nii"'[1..$(2)]' -b "sc_Dave_NN.nii"'[2..$(2)]' -overwrite -prefix "reshuffled.nii" -expr 'a+b'

#rm "sBasis_b.nii"


echo "I expect: dave_prepare.sh SOS.nii Dave_output_NN.nii Dave_output_N.nii"

 
