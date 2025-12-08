#!/bin/bash


3dAutomask -prefix mask.nii -peels 3 -dilate 2 -overwrite run1_TE1.nii.gz


antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [run1_TE1.nii.gz,run2_TE1.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[run1_TE1.nii.gz,run2_TE1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[run1_TE1.nii.gz,run2_TE1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[run1_TE1.nii.gz,run2_TE1.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \
-x mask.nii

antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered2_,registered2_Warped.nii.gz,registered2_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [run1_TE1.nii.gz,run3_TE1.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[run1_TE1.nii.gz,run3_TE1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[run1_TE1.nii.gz,run3_TE1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[run1_TE1.nii.gz,run3_TE1.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \
-x mask.nii

antsApplyTransforms --interpolation BSpline[5] -d 3 -i run2_TE1.nii.gz -o aligned_run2_TE1.nii -r run1_TE1.nii.gz -t registered1_1Warp.nii.gz -t registered1_0GenericAffine.mat
antsApplyTransforms --interpolation BSpline[5] -d 3 -i run2_TE2.nii.gz -o aligned_run2_TE2.nii -r run1_TE1.nii.gz -t registered1_1Warp.nii.gz -t registered1_0GenericAffine.mat
antsApplyTransforms --interpolation BSpline[5] -d 3 -i run2_TE3.nii.gz -o aligned_run2_TE3.nii -r run1_TE1.nii.gz -t registered1_1Warp.nii.gz -t registered1_0GenericAffine.mat


antsApplyTransforms --interpolation BSpline[5] -d 3 -i run3_TE1.nii.gz -o aligned_run3_TE1.nii -r run1_TE1.nii.gz -t registered2_1Warp.nii.gz -t registered2_0GenericAffine.mat
antsApplyTransforms --interpolation BSpline[5] -d 3 -i run3_TE2.nii.gz -o aligned_run3_TE2.nii -r run1_TE1.nii.gz -t registered2_1Warp.nii.gz -t registered2_0GenericAffine.mat
antsApplyTransforms --interpolation BSpline[5] -d 3 -i run3_TE3.nii.gz -o aligned_run3_TE3.nii -r run1_TE1.nii.gz -t registered2_1Warp.nii.gz -t registered2_0GenericAffine.mat


3dMean -prefix grant_average.nii -overwrite \
            run1_TE1.nii \
            run1_TE2.nii \
            run1_TE3.nii \
            aligned_run2_TE1.nii \
            aligned_run2_TE2.nii \
            aligned_run2_TE3.nii \
            aligned_run3_TE1.nii \
            aligned_run3_TE2.nii \
            aligned_run3_TE3.nii



