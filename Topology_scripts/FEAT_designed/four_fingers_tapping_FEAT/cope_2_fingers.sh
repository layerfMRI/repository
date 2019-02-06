3dcalc -a BOLD_cope1.nii -b BOLD_cope2.nii -c BOLD_cope3.nii -d BOLD_cope4.nii -overwrite -expr '   a-b/3-c/3-d/3' -prefix BOLD_index.nii
3dcalc -a BOLD_cope1.nii -b BOLD_cope2.nii -c BOLD_cope3.nii -d BOLD_cope4.nii -overwrite -expr '-1*a/3+b-c/3-d/3' -prefix middle.nii
3dcalc -a BOLD_cope1.nii -b BOLD_cope2.nii -c BOLD_cope3.nii -d BOLD_cope4.nii -overwrite -expr '-1*a/3-b/3+c-d/3' -prefix ring.nii
3dcalc -a BOLD_cope1.nii -b BOLD_cope2.nii -c BOLD_cope3.nii -d BOLD_cope4.nii -overwrite -expr '-1*a/3-b/3-c/3+d' -prefix small.nii

3dcalc -a VASO_cope1.nii -b VASO_cope2.nii -c VASO_cope3.nii -d VASO_cope4.nii -overwrite -expr 'a-b/3-c/3-d/3' -prefix VASO_index.nii
3dcalc -a VASO_cope1.nii -b VASO_cope2.nii -c VASO_cope3.nii -d VASO_cope4.nii -overwrite -expr '-1*a/3+b-c/3-d/3' -prefix VASO_middle.nii
3dcalc -a VASO_cope1.nii -b VASO_cope2.nii -c VASO_cope3.nii -d VASO_cope4.nii -overwrite -expr '-1*a/3-b/3+c-d/3' -prefix VASO_ring.nii
3dcalc -a VASO_cope1.nii -b VASO_cope2.nii -c VASO_cope3.nii -d VASO_cope4.nii -overwrite -expr '-1*a/3-b/3-c/3+d' -prefix VASO_small.nii