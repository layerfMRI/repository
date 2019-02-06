#!/bin/bash


prefix=180413 

echo 'prefix is '$prefix


3dcalc -a $prefix'_VASO_zstat1_index.nii' -b $prefix'_VASO_zstat2_middle.nii' -c $prefix'_VASO_zstat3_ring.nii' -d $prefix'_VASO_zstat4_pinky.nii' -e $prefix'_VASO_zstat5_thumb.nii' -overwrite -expr 'posval(-1*a/(posval(-1*a)+posval(-1*b)+posval(-1*c)+posval(-1*d)+posval(-1*e)))' -prefix VASO_norm_index.nii
3dcalc -a $prefix'_VASO_zstat1_index.nii' -b $prefix'_VASO_zstat2_middle.nii' -c $prefix'_VASO_zstat3_ring.nii' -d $prefix'_VASO_zstat4_pinky.nii' -e $prefix'_VASO_zstat5_thumb.nii' -overwrite -expr 'posval(-1*b/(posval(-1*a)+posval(-1*b)+posval(-1*c)+posval(-1*d)+posval(-1*e)))' -prefix VASO_norm_middle.nii
3dcalc -a $prefix'_VASO_zstat1_index.nii' -b $prefix'_VASO_zstat2_middle.nii' -c $prefix'_VASO_zstat3_ring.nii' -d $prefix'_VASO_zstat4_pinky.nii' -e $prefix'_VASO_zstat5_thumb.nii' -overwrite -expr 'posval(-1*c/(posval(-1*a)+posval(-1*b)+posval(-1*c)+posval(-1*d)+posval(-1*e)))' -prefix VASO_norm_ring.nii
3dcalc -a $prefix'_VASO_zstat1_index.nii' -b $prefix'_VASO_zstat2_middle.nii' -c $prefix'_VASO_zstat3_ring.nii' -d $prefix'_VASO_zstat4_pinky.nii' -e $prefix'_VASO_zstat5_thumb.nii' -overwrite -expr 'posval(-1*d/(posval(-1*a)+posval(-1*b)+posval(-1*c)+posval(-1*d)+posval(-1*e)))' -prefix VASO_norm_pinky.nii
3dcalc -a $prefix'_VASO_zstat1_index.nii' -b $prefix'_VASO_zstat2_middle.nii' -c $prefix'_VASO_zstat3_ring.nii' -d $prefix'_VASO_zstat4_pinky.nii' -e $prefix'_VASO_zstat5_thumb.nii' -overwrite -expr 'posval(-1*e/(posval(-1*a)+posval(-1*b)+posval(-1*c)+posval(-1*d)+posval(-1*e)))' -prefix VASO_norm_thumb.nii

3dcalc -a $prefix'_BOLD_zstat1_index.nii' -b $prefix'_BOLD_zstat2_middle.nii' -c $prefix'_BOLD_zstat3_ring.nii' -d $prefix'_BOLD_zstat4_pinky.nii' -e $prefix'_BOLD_zstat5_thumb.nii' -overwrite -expr 'posval(a/(posval(a)+posval(b)+posval(c)+posval(d)+posval(e)))' -prefix BOLD_norm_index.nii
3dcalc -a $prefix'_BOLD_zstat1_index.nii' -b $prefix'_BOLD_zstat2_middle.nii' -c $prefix'_BOLD_zstat3_ring.nii' -d $prefix'_BOLD_zstat4_pinky.nii' -e $prefix'_BOLD_zstat5_thumb.nii' -overwrite -expr 'posval(b/(posval(a)+posval(b)+posval(c)+posval(d)+posval(e)))' -prefix BOLD_norm_middle.nii
3dcalc -a $prefix'_BOLD_zstat1_index.nii' -b $prefix'_BOLD_zstat2_middle.nii' -c $prefix'_BOLD_zstat3_ring.nii' -d $prefix'_BOLD_zstat4_pinky.nii' -e $prefix'_BOLD_zstat5_thumb.nii' -overwrite -expr 'posval(c/(posval(a)+posval(b)+posval(c)+posval(d)+posval(e)))' -prefix BOLD_norm_ring.nii
3dcalc -a $prefix'_BOLD_zstat1_index.nii' -b $prefix'_BOLD_zstat2_middle.nii' -c $prefix'_BOLD_zstat3_ring.nii' -d $prefix'_BOLD_zstat4_pinky.nii' -e $prefix'_BOLD_zstat5_thumb.nii' -overwrite -expr 'posval(d/(posval(a)+posval(b)+posval(c)+posval(d)+posval(e)))' -prefix BOLD_norm_pinky.nii
3dcalc -a $prefix'_BOLD_zstat1_index.nii' -b $prefix'_BOLD_zstat2_middle.nii' -c $prefix'_BOLD_zstat3_ring.nii' -d $prefix'_BOLD_zstat4_pinky.nii' -e $prefix'_BOLD_zstat5_thumb.nii' -overwrite -expr 'posval(e/(posval(a)+posval(b)+posval(c)+posval(d)+posval(e)))' -prefix BOLD_norm_thumb.nii




