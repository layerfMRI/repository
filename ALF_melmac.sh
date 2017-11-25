#!/bin/bash

echo "starting ALF: Amlpitude from low frequancy Fluctuations"

fslpspec "$1" "fslFFT_$1"

3dTstat -mean -prefix "AFL_$1" -overwrite "fslFFT_$1" 

3dcalc -a "AFL_$1" -expr 'a/10000' -prefix "AFL_$1" -overwrite


#3dcalc -a "mean_fslFFT_$1" -b "fslFFT_$1" -expr 'b/a' -prefix "fslFFT_$1" -overwrite

#rm "mean_fslFFT_$1"



#3dTstat -mean -overwrite -prefix "ALF_$1" "fslFFT_$1"'[2..20]'  

#3dcalc -a "mean_fslFFT_$1" -b "ALF_$1" -expr 'b/a' -prefix "normaliced_ALF_$1" -overwrite


echo "done: I expect: ALF_melmac.sh Dataset_timeseries.nii"

 
