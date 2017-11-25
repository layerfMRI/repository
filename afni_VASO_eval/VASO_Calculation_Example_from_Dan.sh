#!/bin/bash

# Run identifiers listed in the temporal order they were collected
RunList=('S6_30mmHg_Ascending' 'S78_30mmHg_Descending' 'S1112_BH_Ascending' \
         'S1314_BH_Ascending' 'S1516_30mmHg_Ascending' 'S17_30mmHg_Ascending')

# Run identifiers to use on the file names in the same order as $RunList
RunIDs=('ValsalvaAscend1' 'ValsalvaDescend' 'BH1' \
        'BH2' 'ValsalvaAscend2' 'ValsalvaAscend3')

# The directory were I'm processing these data
cd /data/NIMH_SFIM/handwerkerd/VASO_Valsalva/PrcsData/Sbj_151204/D01_Processing

# Symbollically link the files from the original data directory to the processing directory
for idx in 0 1 2 3 4 5; do
   ln -s ../D00_OrigData/${RunList[$idx]}/Basis_a.nii ./${RunIDs[$idx]}.nii
done

# The images are improperly listed as in TLRC space so I'm changing that to orig
# (This is an AFNI distinction for files that are in their subject-original space
#    vs aligned to a standardize template)
#
# The true TR is actually 1.5s rather than 1.49900s.
#
# 3drefit can correct both of these things
#   The way this is written, it will change values for the files in the D00_OrigData directory
for filename in `ls *.nii`; do
  echo ${filename}
  3drefit -space ORIG -view orig -TR 1.5 ${filename}
done

# The Descending run actually as a TR of 1.5060s
for filename in `ls *Descend*.nii`; do
  echo ${filename}
  3drefit -TR 1.560 ${filename}
done


# Run motion correction. Athought I originally did this on BOLD and Null together,
# I separated them here since these are the final BOLD time series & I'd need to make
# a distinct run for these data anyway.
#
# All runs are being aligned to the first volume of ValsalvaAscend1.nii
#  The mot.1D file contains the 6 motion parameters. 
# The dfile.1D contains the 6 motion parameters + 3 summary-of-motion parameters
for RunID in ${RunIDs[@]}; do
  3dvolreg -overwrite -prefix p02.${RunID}.BOLD.volreg.nii -base ValsalvaAscend1.nii'[0]' \
    -dfile ${RunID}.BOLD.dfile.1D -1Dfile ${RunID}.BOLD.mot.1D ${RunID}.nii'[0..$(2)]'
  3dvolreg -overwrite -prefix p01.${RunID}.Null.volreg.nii -base ValsalvaAscend1.nii'[0]' \
    -dfile ${RunID}.Null.dfile.1D -1Dfile ${RunID}.Null.mot.1D ${RunID}.nii'[1..$(2)]'
done

# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes
# I was mainly doing this as a check to make sure motion correction worked reasonably.
# A TSNR calculation should probably be done after non-linear drift removal.
for RunID in ${RunIDs[@]}; do
  3dTstat  -overwrite -mean -stdev -cvarinv -prefix p02a.${RunID}.BOLD.MeanStdCVar.nii \
     p02.${RunID}.BOLD.volreg.nii'[2..$]'
  3dTstat  -overwrite -mean -stdev -cvarinv -prefix p01a.${RunID}.Null.MeanStdCVar.nii \
     p01.${RunID}.Null.volreg.nii'[2..$]'
done

# Calculate VASO!
for RunID in ${RunIDs[@]}; do
  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume
  3dcalc -prefix tmp.VASO_vol1.${RunID}.nii \
         -a      p02.${RunID}.BOLD.volreg.nii'[1]' \
         -b      p01.${RunID}.Null.volreg.nii'[0]' \
         -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume
  NumVol=`3dinfo -nv p02.${RunID}.BOLD.volreg.nii`
  3dcalc -prefix tmp.VASO_othervols.${RunID}.nii \
         -a      p02.${RunID}.BOLD.volreg.nii'[1..'`expr $NumVol - 2`']' \
         -b      p02.${RunID}.BOLD.volreg.nii'[2..$]' \
         -c      p01.${RunID}.Null.volreg.nii'[1..$]' \
         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
   3dTcat -overwrite -prefix p02.${RunID}.VASO.volreg.nii tmp.VASO_vol1.${RunID}.nii tmp.VASO_othervols.${RunID}.nii
done

# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers
for filename in `ls p02.*BOLD*.nii p02.*VASO*.nii`; do
  echo ${filename}
  3drefit -TR 3.0 ${filename}
done
for filename in `ls p02.*Descend*BOLD*.nii p02.*Descend*VASO*.nii`; do
  echo ${filename}
  3drefit -TR 3.12 ${filename}
done



# TO TRY TO INSERT BEFORE THE GLM
# 1. Trying out 3dDespike to see if it can identify problems in the data. So far it's too agressively editing good data.
# 2. Remove voxels that leave the imaging plane due to motion at any point during any scan


# Run the model fits
# Note: VASO is 1.5s (1/2 TR) later than BOLD. This is the best way to calculate the trial averaged shapes,
#   but, if I'm temporally overlaying time series, I should shift VASO by 1.5sec
# 3dDeconvolve sets up the design matrix * the model is fitted wtih 3dREMLfit
for stype in BOLD VASO; do

  # Using all 3 Ascending Valsalva runs in one GLM. I might run the Desending run later or combine it with these three
  # If my math is correct, the 13 volume (zero indexed) is when the breath hold period begins for BOLD
  3dDeconvolve -input p02.ValsalvaAscend1.${stype}.volreg.nii'[13..193]' \
                    p02.ValsalvaAscend2.${stype}.volreg.nii'[13..193]' \
                    p02.ValsalvaAscend3.${stype}.volreg.nii'[13..193]' \
	-polort a -overwrite \
	-num_stimts 1 \
	-stim_times 1 '1D: 0 54 108 162 216 270 324 378 432 486 | 0 54 108 162 216 270 324 378 432 486 | 0 54 108 162 216 270 324 378 432 486' 'TENT(0,51,18)' \
	-stim_label 1 Valsalva \
	-cbucket cbucket.${stype}_ValsalvaAllAscend.nii \
	-fitts fitts.${stype}_ValsalvaAllAscend.nii \
	-errts errts.${stype}_ValsalvaAllAscend.nii \
	-fout -bucket stats.${stype}_ValsalvaAllAscend.nii \
	-x1D Tent.${stype}_ValsalvaAllAscend \
	-x1D_stop -jobs 8
    

    3dREMLfit -matrix Tent.${stype}_ValsalvaAllAscend.xmat.1D \
       -input "p02.ValsalvaAscend1.${stype}.volreg.nii[13..193] p02.ValsalvaAscend2.${stype}.volreg.nii[13..193] p02.ValsalvaAscend3.${stype}.volreg.nii[13..193]" \
      -Rbeta cbucket.${stype}_ValsalvaAllAscend_REML.nii -fout \
      -Rbuck stats.${stype}_ValsalvaAllAscend_REML.nii -Rvar stats.${stype}_ValsalvaAllAscend_REMLvar.nii \
      -Rfitts fitts.${stype}_ValsalvaAllAscend_REML.nii -Rerrts errts.${stype}_ValsalvaAllAscend_REML.nii -verb

   # Make a volume of just the parameter fits (i.e. the trial averaged responses
   3dcalc -a stats.${stype}_ValsalvaAllAscend_REML.nii'[1..18]' \
	-prefix TrialAvg.${stype}_ValsalvaAllAscend.nii -expr 'a'

  # Calculate the responses for the two breath hold on exhale runs
  3dDeconvolve -input p02.BH1.${stype}.volreg.nii'[13..193]' \
                    p02.BH2.${stype}.volreg.nii'[13..193]' \
	-polort a -overwrite \
	-num_stimts 1 \
	-stim_times 1 '1D: 0 54 108 162 216 270 324 378 432 486 | 0 54 108 162 216 270 324 378 432 486' 'TENT(0,51,18)' \
	-stim_label 1 BreathHoldAll \
	-cbucket cbucket.${stype}_BreathHoldAll.nii \
	-fitts fitts.${stype}_BreathHoldAll.nii \
	-errts errts.${stype}_BreathHoldAll.nii \
	-fout -bucket stats.${stype}_BreathHoldAll.nii \
	-x1D Tent.${stype}_BreathHoldAll \
	-x1D_stop -jobs 8
    

    3dREMLfit -matrix Tent.${stype}_BreathHoldAll.xmat.1D \
       -input "p02.BH1.${stype}.volreg.nii[13..193] p02.BH2.${stype}.volreg.nii[13..193]" \
      -Rbeta cbucket.${stype}_BreathHoldAll_REML.nii -fout \
      -Rbuck stats.${stype}_BreathHoldAll_REML.nii -Rvar stats.${stype}_BreathHoldAll_REMLvar.nii \
      -Rfitts fitts.${stype}_BreathHoldAll_REML.nii -Rerrts errts.${stype}_BreathHoldAll_REML.nii -verb

   # Make a volume of just the parameter fits (i.e. the trial averaged responses
   3dcalc -a stats.${stype}_BreathHoldAll_REML.nii'[1..18]' \
	-prefix TrialAvg.${stype}_BreathHoldAll.nii -expr 'a'


done


