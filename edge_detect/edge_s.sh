#!/bin/bash


echo "starte jetzt"


for idx in 0 1 2 3 4 5 6 7   ; do
  miconv -srange "$idx-$idx" $1 "slice_$idx.nii"
done

for idx in 0 1 2 3 4 5 6 7   ; do
3dedge3 -input "slice_$idx.nii" -prefix "edge_slice_$idx.nii"  -overwrite -scale_floats 1000
done

cp "edge_slice_0.nii" "edge_$1" 
for idx in  1 2 3 4 5 6 7   ; do
fslmerge -z "edge_$1" "edge_$1" "edge_slice_$idx.nii"
done


rm slice_*
rm edge_slice_*
