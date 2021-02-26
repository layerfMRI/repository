#!/bin/bash

echo "fange an"

miconv -trange 3-239 -noscale Bold_no_drift.nii sBold_no_drift.nii
miconv -trange 3-239 -noscale Anti_BOLD_no_drift.nii sAnti_BOLD_no_drift.nii

miconv -trange 0-2 -noscale sBold_no_drift.nii first_BOLD.nii
miconv -trange 0-2 -noscale sAnti_BOLD_no_drift.nii first_VASO.nii

fslmerge -t Bold_no_drift.nii first_BOLD.nii sBold_no_drift.nii
fslmerge -t Anti_BOLD_no_drift.nii first_VASO.nii sAnti_BOLD_no_drift.nii

rm first_BOLD.nii
rm first_VASO.nii
rm sBold_no_drift.nii
rm sAnti_BOLD_no_drift.nii

echo "und tschuess"

 
