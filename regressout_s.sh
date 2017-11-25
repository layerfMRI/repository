#!/bin/bash

echo "Are you cooking in a clean kitchen?"

fsl_regfilt -i "$1" -o filtered_"$3"_"$1" -d "$2" -f "$3"

3dcalc -overwrite -a "$1" -b filtered_"$3"_"$1" -expr "a-b" -prefix regressedout_"$3"_"$1"


echo  " fsl_regfilt -i "$1" -o filtered_"$1" -d "$2" -f "$3" "

echo "I expect:"
echo "regressout.sh fMRI.nii timeseries_text_file.dat columns_in_textfile_separated_with_commas "
