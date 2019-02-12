
fslcpgeom reference.nii mask.nii

antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 0 \
--collapse-output-transforms 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation BSpline[5] \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--initial-moving-transform initial_matrix.txt \
--transform Rigid[0.2] \
--metric MI[reference.nii,T1.nii,0.7,32,Regular,0.1] \
--convergence [1000x700x500,1e-6,10] \
--shrink-factors 3x2x1 \
--smoothing-sigmas 2x1x0vox \
-x mask.nii \
--transform Affine[0.1] \
--metric MI[reference.nii,T1.nii,1,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
-x mask.nii \
--transform SyN[0.1,3,0]  \
--metric CC[reference.nii,T1.nii,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox  \
-x mask.nii


antsApplyTransforms --interpolation BSpline[5] -d 3 -i T1.nii -o warped_T1.nii -r reference.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat

for file in *zstat*.nii
do
 antsApplyTransforms --interpolation BSpline[5] -d 3 -i $file -o warped_$file -r reference.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
done



fslsplit BOLD.nii splited -t 
for file in splited*.nii
do
 antsApplyTransforms --interpolation BSpline[5] -d 3 -i $file -o warped_$file -r reference.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
done

fslmerge -t warped_BOLD.nii warped_splited*

rm *splited*


fslsplit VASO.nii splited -t 

for file in splited*.nii
do
 antsApplyTransforms --interpolation BSpline[5] -d 3 -i $file -o warped_$file -r reference.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
done

fslmerge -t warped_VASO.nii warped_splited*

rm *splited*

for file in warped_*.nii
do
 3dRefit -TR 3 $file
done

 short_me.sh warped_BOLD.nii


