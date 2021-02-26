#!/bin/bash

echo "fange an"

miconv -trange 2-193 -noscale Bold_no_drift.nii BOLD.nii
miconv -trange 2-193 -noscale Anti_BOLD_no_drift.nii VASO.nii

echo "und tschuess"

 
