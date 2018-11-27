#!/bin/bash

#Felix run me with: sbatch --mem=100g --cpus-per-task=50 --time=14400:00  executed.sh

module load afni 

./Up_sample_3d.sh VASO_LN_1.nii
3dcalc -a  scaled_VASO_LN_1.nii -datum short -overwrite -prefix scaled_VASO_LN_1.nii
./zoom_me.sh scaled_VASO_LN_1.nii  
3dcalc -a  yz_slab_scaled_VASO_LN_1.nii -datum short -overwrite -prefix yz_slab_scaled_VASO_LN_1.nii -expr 'step(a)'


./Up_sample_3d.sh VASO_LN_2.nii
3dcalc -a  scaled_VASO_LN_2.nii -datum short -overwrite -prefix scaled_VASO_LN_2.nii
./zoom_me.sh scaled_VASO_LN_2.nii 
3dcalc -a  yz_slab_scaled_VASO_LN_2.nii -datum short -overwrite -prefix yz_slab_scaled_VASO_LN_2.nii -expr 'step(a)'

