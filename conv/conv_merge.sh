#!/bin/bash
# this needs to run in bash

#expectig: conv_merge.sh VASO.nii BOLD.nii

echo "fange an"


##################################################################################### 
#### combining odd and even images that are stored in seperate files a la zipper ####
#####################################################################################
# 0 2 4 6 8 ...
fslsplit $1 e_ -t 
# 1 3 5 7 9 ...
fslsplit $2 o_ -t 

la=`imglob -extension [eo]_*`
lb=`ls -1 $la | sort -t _ -k 2`
fslmerge -t combined.nii $lb
rm e_*.nii
rm o_*.nii



echo "expecting in bash: conv_merge.sh VASO.nii BOLD.nii"

echo "und tschuess"


 
