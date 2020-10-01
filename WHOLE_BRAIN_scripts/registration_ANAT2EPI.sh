#!/bin/bash

#This script can be downloaded from here: https://github.com/layerfMRI/repository/blob/master/Alignement_scripts/align_0.5mm_MP2RAGE_2_EPI/executed_command.sh 

antsRegistration \
--verbose 1 \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--interpolation BSpline[5] \
--output [registered1_,registered1_Warped.nii,registered1_InverseWarped.nii]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform initial_matrix.txt \
-x mask.nii \
--transform Rigid[0.1]  \
--metric MI[EPI_T1.nii,ANAT.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[EPI_T1.nii,ANAT.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.2,3,0]  \
--metric CC[EPI_T1.nii,ANAT.nii,1,4]  \
--convergence [50x50x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \


3dresample -dxyz 0.4 0.4 0.4 -rmode Cu -overwrite -prefix scaled_EPI.nii -input EPI_T1.nii 


#antsApplyTransforms --interpolation BSpline[5] -d 3 -i mask_from_miriam.nii -o warped_mask.nii -r scaled_EPI.nii -t registered1_1Warp.nii.gz -t registered1_0GenericAffine.mat
antsApplyTransforms --interpolation NearestNeighbor -d 3 -i MIRIAM.nii -o warped_mask.nii -r EPI_T1.nii -t registered1_1Warp.nii.gz -t registered1_0GenericAffine.mat

3dresample -dxyz 0.4 0.4 0.4 -rmode Li -overwrite -prefix scaled_warped_mask.nii -input warped_mask.nii 
short_me.sh scaled_warped_mask.nii 
