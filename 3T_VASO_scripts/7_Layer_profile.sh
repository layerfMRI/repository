#!/bin/bash


echo "fange an"




mkdir profiles


LN2_PROFILE -input P001/layers/sc_BOLD.nii -layers P001/layers/layers.nii -plot -output profiles/P001_BOLD_profile.txt
LN2_PROFILE -input P003/layers/sc_BOLD.nii -layers P003/layers/layers.nii -plot -output profiles/P003_BOLD_profile.txt
LN2_PROFILE -input P004/layers/sc_BOLD.nii -layers P004/layers/layers.nii -plot -output profiles/P004_BOLD_profile.txt
LN2_PROFILE -input P005/layers/sc_BOLD.nii -layers P005/layers/layers.nii -plot -output profiles/P005_BOLD_profile.txt
LN2_PROFILE -input P006/layers/sc_BOLD.nii -layers P006/layers/layers.nii -plot -output profiles/P006_BOLD_profile.txt
LN2_PROFILE -input P007/layers/sc_BOLD.nii -layers P007/layers/layers.nii -plot -output profiles/P007_BOLD_profile.txt
LN2_PROFILE -input P008/layers/sc_BOLD.nii -layers P008/layers/layers.nii -plot -output profiles/P008_BOLD_profile.txt
LN2_PROFILE -input P009/layers/sc_BOLD.nii -layers P009/layers/layers.nii -plot -output profiles/P009_BOLD_profile.txt
LN2_PROFILE -input P0011/layers/sc_BOLD.nii -layers P0011/layers/layers.nii -plot -output profiles/P0011_BOLD_profile.txt
LN2_PROFILE -input P0012/layers/sc_BOLD.nii -layers P0012/layers/layers.nii -plot -output profiles/P0012_BOLD_profile.txt
LN2_PROFILE -input P0013/layers/sc_BOLD.nii -layers P0013/layers/layers.nii -plot -output profiles/P0013_BOLD_profile.txt
LN2_PROFILE -input P0014/layers/sc_BOLD.nii -layers P0014/layers/layers.nii -plot -output profiles/P0014_BOLD_profile.txt
LN2_PROFILE -input P0015/layers/sc_BOLD.nii -layers P0015/layers/layers.nii -plot -output profiles/P0015_BOLD_profile.txt
LN2_PROFILE -input P0016/layers/sc_BOLD.nii -layers P0016/layers/layers.nii -plot -output profiles/P0016_BOLD_profile.txt

LN2_PROFILE -input P001/layers/sc_VASO.nii -layers P001/layers/layers.nii -plot -output profiles/P001_VASO_profile.txt
LN2_PROFILE -input P003/layers/sc_VASO.nii -layers P003/layers/layers.nii -plot -output profiles/P003_VASO_profile.txt
LN2_PROFILE -input P004/layers/sc_VASO.nii -layers P004/layers/layers.nii -plot -output profiles/P004_VASO_profile.txt
LN2_PROFILE -input P005/layers/sc_VASO.nii -layers P005/layers/layers.nii -plot -output profiles/P005_VASO_profile.txt
LN2_PROFILE -input P006/layers/sc_VASO.nii -layers P006/layers/layers.nii -plot -output profiles/P006_VASO_profile.txt
LN2_PROFILE -input P007/layers/sc_VASO.nii -layers P007/layers/layers.nii -plot -output profiles/P007_VASO_profile.txt
LN2_PROFILE -input P008/layers/sc_VASO.nii -layers P008/layers/layers.nii -plot -output profiles/P008_VASO_profile.txt
LN2_PROFILE -input P009/layers/sc_VASO.nii -layers P009/layers/layers.nii -plot -output profiles/P009_VASO_profile.txt
LN2_PROFILE -input P0011/layers/sc_VASO.nii -layers P0011/layers/layers.nii -plot -output profiles/P0011_VASO_profile.txt
LN2_PROFILE -input P0012/layers/sc_VASO.nii -layers P0012/layers/layers.nii -plot -output profiles/P0012_VASO_profile.txt
LN2_PROFILE -input P0013/layers/sc_VASO.nii -layers P0013/layers/layers.nii -plot -output profiles/P0013_VASO_profile.txt
LN2_PROFILE -input P0014/layers/sc_VASO.nii -layers P0014/layers/layers.nii -plot -output profiles/P0014_VASO_profile.txt
LN2_PROFILE -input P0015/layers/sc_VASO.nii -layers P0015/layers/layers.nii -plot -output profiles/P0015_VASO_profile.txt
LN2_PROFILE -input P0016/layers/sc_VASO.nii -layers P0016/layers/layers.nii -plot -output profiles/P0016_VASO_profile.txt

cd  profiles

awk 'FNR == 1 { nfiles++; ncols = NF }
     { for (i = 1; i < NF; i++) sum[FNR,i] += $i
       if (FNR > maxnr) maxnr = FNR
     }
     END {
         for (line = 1; line <= maxnr; line++)
         {
             for (col = 1; col < ncols; col++)
                  printf "  %f", sum[line,col]/nfiles;
             printf "\n"
         }
     }' *_VASO_profile.txt  > average_VASO_profile.txt
     
     
awk 'FNR == 1 { nfiles++; ncols = NF }
     { for (i = 1; i < NF; i++) sum[FNR,i] += $i
       if (FNR > maxnr) maxnr = FNR
     }
     END {
         for (line = 1; line <= maxnr; line++)
         {
             for (col = 1; col < ncols; col++)
                  printf "  %f", sum[line,col]/nfiles;
             printf "\n"
         }
     }' *_BOLD_profile.txt  > average_BOLD_profile.txt


echo "und tschuess"

 
