#!/bin/bash

#from Harries Cheat sheet July 6th 2017
# it expects: 1.) a acq file 2.) a Anti_BOLD_no_drift.nii filed 3.) and a Bold_no_drift.nii files



echo "starting now with converting acq in txt"

acq2txt *.acq  > physio1.txt  

#remove header line in physio.txt 
tail -n +2 "physio1.txt" > physio.txt
rm physio1.txt
# lines are: 1 time; 2 respiration; 3 cardio unfiltered; 4 trigger ; 5 cardio filtered


echo "cutting unnecessary first and last image"
python report_TR.py physio.txt

TR_vol=$(< TR.txt)
sampling_rate=500

echo "TR = $TR_vol"
echo "sampling_rate = $sampling_rate"

echo "generating VASO regressors a la Rick "
RetroTS.py -r resp_vaso.1D -c card_vaso.1D -p $sampling_rate -n 1 -v $TR_vol -prefix 'VASO' 

echo "generating GLM map for all 13 regressors VASO"

    1deval -x VASO.slibase.1D'[0]' -expr 'x' > VASO_0.1D
    1deval -x VASO.slibase.1D'[1]' -expr 'x' > VASO_1.1D
    1deval -x VASO.slibase.1D'[2]' -expr 'x' > VASO_2.1D
    1deval -x VASO.slibase.1D'[3]' -expr 'x' > VASO_3.1D
    1deval -x VASO.slibase.1D'[4]' -expr 'x' > VASO_4.1D
    1deval -x VASO.slibase.1D'[5]' -expr 'x' > VASO_5.1D
    1deval -x VASO.slibase.1D'[6]' -expr 'x' > VASO_6.1D
    1deval -x VASO.slibase.1D'[7]' -expr 'x' > VASO_7.1D
    1deval -x VASO.slibase.1D'[8]' -expr 'x' > VASO_8.1D
    1deval -x VASO.slibase.1D'[9]' -expr 'x' > VASO_9.1D
    1deval -x VASO.slibase.1D'[10]' -expr 'x' > VASO_10.1D
    1deval -x VASO.slibase.1D'[11]' -expr 'x' > VASO_11.1D
    1deval -x VASO.slibase.1D'[12]' -expr 'x' > VASO_12.1D

3dDeconvolve -num_stimts 13 -stim_file 1 VASO_0.1D -stim_file 2 VASO_1.1D -stim_file 3 VASO_2.1D -stim_file 4 VASO_3.1D -stim_file 5 VASO_4.1D -stim_file 6 VASO_5.1D -stim_file 7 VASO_6.1D -stim_file 8 VASO_7.1D -stim_file 9 VASO_8.1D -stim_file 10 VASO_9.1D -stim_file 11 VASO_10.1D -stim_file 12 VASO_11.1D -stim_file 13 VASO_12.1D -input Anti_BOLD_no_drift.nii -cbucket bucket_Anti_BOLD_no_drift.nii -overwrite -polort 0

#3dcalc -a bucket_Anti_BOLD_no_drift.nii'[0]' -expr 'a' -prefix coeff_VASO_0.nii -overwrite this is the mean only
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[1]' -expr 'a' -prefix coeff_VASO_1.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[2]' -expr 'a' -prefix coeff_VASO_2.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[3]' -expr 'a' -prefix coeff_VASO_3.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[4]' -expr 'a' -prefix coeff_VASO_4.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[5]' -expr 'a' -prefix coeff_VASO_5.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[6]' -expr 'a' -prefix coeff_VASO_6.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[7]' -expr 'a' -prefix coeff_VASO_7.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[8]' -expr 'a' -prefix coeff_VASO_8.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[9]' -expr 'a' -prefix coeff_VASO_9.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[10]' -expr 'a' -prefix coeff_VASO_10.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[11]' -expr 'a' -prefix coeff_VASO_11.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[12]' -expr 'a' -prefix coeff_VASO_12.nii -overwrite
3dcalc -a bucket_Anti_BOLD_no_drift.nii'[13]' -expr 'a' -prefix coeff_VASO_13.nii -overwrite


fslmerge -t VASO_physio_coefficient.nii  coeff_VASO_*

rm VASO_*.1D
rm coeff_VASO_*


echo "generating BOLD regressors ala Rick"

RetroTS.py -r resp_bold.1D -c card_bold.1D -p $sampling_rate -n 1 -v $TR_vol -prefix 'BOLD' 

echo "generating GLM map for all 13 regressors BOLDs"

    1deval -x BOLD.slibase.1D'[0]'  -expr 'x' > BOLD_0.1D
    1deval -x BOLD.slibase.1D'[1]'  -expr 'x' > BOLD_1.1D
    1deval -x BOLD.slibase.1D'[2]'  -expr 'x' > BOLD_2.1D
    1deval -x BOLD.slibase.1D'[3]'  -expr 'x' > BOLD_3.1D
    1deval -x BOLD.slibase.1D'[4]'  -expr 'x' > BOLD_4.1D
    1deval -x BOLD.slibase.1D'[5]'  -expr 'x' > BOLD_5.1D
    1deval -x BOLD.slibase.1D'[6]'  -expr 'x' > BOLD_6.1D
    1deval -x BOLD.slibase.1D'[7]'  -expr 'x' > BOLD_7.1D
    1deval -x BOLD.slibase.1D'[8]'  -expr 'x' > BOLD_8.1D
    1deval -x BOLD.slibase.1D'[9]'  -expr 'x' > BOLD_9.1D
    1deval -x BOLD.slibase.1D'[10]' -expr 'x' > BOLD_10.1D
    1deval -x BOLD.slibase.1D'[11]' -expr 'x' > BOLD_11.1D
    1deval -x BOLD.slibase.1D'[12]' -expr 'x' > BOLD_12.1D

3dDeconvolve -num_stimts 13 -stim_file 1 BOLD_0.1D -stim_file 2 BOLD_1.1D -stim_file 3 BOLD_2.1D -stim_file 4 BOLD_3.1D -stim_file 5 BOLD_4.1D -stim_file 6 BOLD_5.1D -stim_file 7 BOLD_6.1D -stim_file 8 BOLD_7.1D -stim_file 9 BOLD_8.1D -stim_file 10 BOLD_9.1D -stim_file 11 BOLD_10.1D -stim_file 12 BOLD_11.1D -stim_file 13 BOLD_12.1D -input Bold_no_drift.nii -overwrite -polort 0 -cbucket bucket_Bold_no_drift.nii

3dcalc -a bucket_Bold_no_drift.nii'[0]'  -expr 'a' -prefix coeff_BOLD_0.nii -overwrite this is the mean only
3dcalc -a bucket_Bold_no_drift.nii'[1]'  -expr 'a' -prefix coeff_BOLD_1.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[2]'  -expr 'a' -prefix coeff_BOLD_2.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[3]'  -expr 'a' -prefix coeff_BOLD_3.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[4]'  -expr 'a' -prefix coeff_BOLD_4.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[5]'  -expr 'a' -prefix coeff_BOLD_5.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[6]'  -expr 'a' -prefix coeff_BOLD_6.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[7]'  -expr 'a' -prefix coeff_BOLD_7.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[8]'  -expr 'a' -prefix coeff_BOLD_8.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[9]'  -expr 'a' -prefix coeff_BOLD_9.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[10]' -expr 'a' -prefix coeff_BOLD_10.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[11]' -expr 'a' -prefix coeff_BOLD_11.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[12]' -expr 'a' -prefix coeff_BOLD_12.nii -overwrite
3dcalc -a bucket_Bold_no_drift.nii'[13]' -expr 'a' -prefix coeff_BOLD_13.nii -overwrite

fslmerge -t BOLD_physio_coefficient.nii  coeff_BOLD_*

rm BOLD_*.1D
rm coeff_BOLD_*

rm bucket_*


echo "Done"

