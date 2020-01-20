#!/bin/bash

antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [ref.nii,s1.nii,1]  \
--transform Rigid[0.1]  \
--metric MI[ref.nii,s1.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[ref.nii,s1.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[ref.nii,s1.nii,1,32,Regular,0.25]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

# \
#-x mask.nii

antsRegistration  \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered3_,registered3_Warped.nii.gz,registered3_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [ref.nii,s3.nii,1]  \
--transform Rigid[0.1]  \
--metric MI[ref.nii,s3.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1] \
--metric MI[ref.nii,s3.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[ref.nii,s3.nii,1,32,Regular,0.25]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 
# \
#-x mask.nii

antsRegistration  \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered2_,registered2_Warped.nii.gz,registered2_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [ref.nii,s2.nii,1]  \
--transform Rigid[0.1]  \
--metric MI[ref.nii,s2.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1] \
--metric MI[ref.nii,s2.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[ref.nii,s2.nii,1,32,Regular,0.25]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 
# \

3dMean -prefix AVERAGE.nii ref.nii registered3_Warped.nii.gz registered2_Warped.nii.gz registered1_Warped.nii.gz -overwrite



