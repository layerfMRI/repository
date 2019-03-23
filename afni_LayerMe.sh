#!/bin/bash

#get mean value
3dROIstats -mask layers.nii -1DRformat -quiet -nzmean $1 > layer_t.dat
#get standard deviation
3dROIstats -mask layers.nii -1DRformat -quiet -sigma $1 >> layer_t.dat
#get number of voxels in each layer
3dROIstats -mask layers.nii -1DRformat -quiet -nzvoxels $1 >> layer_t.dat
#format file to be in columns, so gnuplot can read it.
WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' layer_t.dat| tr '\n' ' ';echo; done > layer.dat



 
1dplot -sepscl layer.dat 
