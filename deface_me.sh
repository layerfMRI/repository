#!/bin/bash

echo "starting this might take 4-5 min"

fsl_deface $1 deface_$1 -d face_mask.nii

echo "done"

 
