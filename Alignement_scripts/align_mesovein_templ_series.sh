#!/bin/bash

3dMean -overwrite -prefix first_series.nii.gz  S24_1280_mesovein_to_build_from_runs_DP_e1.nii.gz S24_1280_mesovein_to_build_from_runs_DP_e2.nii.gz
3dMean -overwrite -prefix second_series.nii.gz S25_1280_mesovein_to_build_from_runs_DP_e1.nii.gz S25_1280_mesovein_to_build_from_runs_DP_e2.nii.gz

3dTcat -overwrite -prefix merged.nii.gz first_series.nii.gz second_series.nii.gz

mkdir to_align

ImageMath 4 to_align/vol_.nii.gz TimeSeriesDisassemble merged.nii.gz


antsMultivariateTemplateConstruction.sh \
  -d 3 \
  -o template_ \
  -i 4 \
  -g 0.2 \
  -j 4 \
  -c 2 \
  -k 1 \
  -w 1 \
  -m 100x70x50x10 \
  -n 1 \
  -r 1 \
  -s CC \
  -t GR \
  to_align/*.nii.gz


rm second_series.nii.gz
rm first_series.nii.gz
rm merged.nii.gz
