LAYER_VOL_LEAK rim.nii 

GROW_LAYERS rim.nii

3dcalc -a leak_vol_lay_rim.nii -b equi_dist_layers.nii -expr 'a-b' -overwrite -prefix difference.nii

SMinMASK difference.nii rim.nii  30

3dcalc -a smoothed_difference.nii -b leak_vol_lay_rim.nii -expr 'b-2*a' -overwrite -prefix corrected_leak_1.nii

SMinMASK corrected_leak_1.nii rim.nii  12

GLOSSY_LAYERS  smoothed_corrected_leak_1.nii
