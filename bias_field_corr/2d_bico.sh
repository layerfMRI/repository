#!/bin/bash


fslsplit $1 -z

for filename in vol*.nii; do
3dUnifize -input $filename -prefix uni_$filename
done

fslmerge -z uni_$1 uni_vol*

rm vol*.nii
