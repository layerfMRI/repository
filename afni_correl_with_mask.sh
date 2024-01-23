#!/bin/bash


#extraxting time time course of ROI
3dROIstats -mask $2 -quiet -1DRformat $1 > timecourse.txt

# looking at it
#1dplot  timecourse.txt

#correlating each voxel with this time course
3dTcorr1D -prefix correl_$1 -pearson -overwrite $1 timecourse.txt

echo " I expect ./correl_with_mask.sh timeseries.nii mask.nii "
