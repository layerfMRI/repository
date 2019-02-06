#!/bin/bash

#get mean value
3dROIstats -mask S1_index_mask.nii -1DRformat -quiet  $1 > S1_index.dat
#get standard deviation
3dROIstats -mask S1_pinky_mask.nii -1DRformat -quiet  $1 > S1_pinky.dat
#get number of voxels in each layer

