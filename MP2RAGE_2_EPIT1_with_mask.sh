#!/bin/bash

#on felix run me with: sbatch --mem=100g --cpus-per-task=50 --time=14400:00  executed_command.sh

#fslcpgeom T1.nii mask.nii

#antsApplyTransforms --interpolation BSpline[5] -d 3 -i mask.nii -o reg_mask.nii -r MP2RAGE.nii -t initial_matrix.txt


module load ANTs 

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=50
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

antsRegistration \
--verbose 1  \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--interpolation BSpline[5] \
--output [registered1_,registered1_Warped.nii,registered1_InverseWarped.nii]  \
--use-histogram-matching 1  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform initial_matrix \
--transform Rigid[0.1]  \
--metric MI[T1.nii,MP2RAGE.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--masks mask.nii \
--metric MI[T1.nii,MP2RAGE.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--masks mask.nii \
--metric CC[T1.nii,MP2RAGE.nii,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \
--masks mask.nii


antsApplyTransforms --interpolation BSpline[5] -d 3 -i second_image.nii -o warped_second_image.nii -r T1.nii -t registered1_0GenericAffine.mat -t registered1_1Warp.nii.gz