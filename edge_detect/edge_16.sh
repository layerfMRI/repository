#!/bin/bash


echo "starte jetzt"



fslsplit $1 slice_ -z 


for idx in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15    ; do
3dedge3 -input "slice_00$idx.nii" -prefix "edge_slice_$idx.nii"  -overwrite -scale_floats 1000
done


fslmerge -z "edge_$1" edge_slice*



rm slice_*
rm edge_slice_*
