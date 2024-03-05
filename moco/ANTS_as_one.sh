#!/bin/bash

antsMotionCorr  -d 3 -o [output,output.nii.gz,reference.nii.gz] -m gc[ reference.nii.gz , input.nii , 1 , 1 , Random, 0.05  ] -t Affine[ 0.005 ] -i 20 -u 1 -e 1 -s 0 -f 1 -n 10

