####################################################################
######### This alignes non linearsly based #########################
######### on a first semi-manual alignement in ITK-SNAP   ##########
####################################################################
# comand details here: https://github.com/ANTsX/ANTs/wiki/Anatomy-of-an-antsRegistration-call 


ml ants

antsRegistration \
--verbose 1 \
--dimensionality 3  \
--float 1  \
--collapse-output-transforms 1  \
--interpolation BSpline[5] \
--output [registered1_,registered1_Warped.nii,registered1_InverseWarped.nii]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.1]  \
--metric MI[meanEPI.nii,anat.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
-x moma.nii.gz \
--transform Affine[0.1]  \
--metric MI[meanEPI.nii,anat.nii,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
-x moma.nii.gz \
--transform SyN[0.1,3,0]  \
--metric CC[meanEPI.nii,anat.nii,1,4]  \
--convergence [50x50x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \
-x moma.nii.gz



