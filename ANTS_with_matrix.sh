#!/bin/bash



echo "fange an"

#   bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05 -datatype short
#   3dcalc -a MP2RAGE.nii -datum short -expr 'a' -prefix MP2RAGE.nii -overwrite

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=3
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 0 \
--collapse-output-transforms 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation Linear \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.05,0.95] \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric MI[EPI.nii,MP2RAGE.nii,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox 

#step_size

antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 0 \
--collapse-output-transforms 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation Linear \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.05,0.95] \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.1] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.1] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric MI[EPI.nii,MP2RAGE.nii,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox

#2 steps
antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 0 \
--collapse-output-transforms 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation Linear \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.2] \
--metric CC[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1] \
--convergence [1000x700x500,1e-6,10] \
--shrink-factors 3x2x1 \
--smoothing-sigmas 2x1x0vox \
--transform Affine[0.1] \
--metric MI[EPI.nii,MP2RAGE.nii,1,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[0.1,3,0] \
--metric MI[EPI.nii,MP2RAGE.nii,1,4] \
--convergence [500x200,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox


antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat


#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
