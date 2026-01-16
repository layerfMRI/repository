#!/bin/bash


cnt=100
for filename in S*e1.nii.gz
do
cp $filename S${cnt}_echotmp1.nii.gz
cnt=$(($cnt+1))
done

cnt=100
for filename in S*e2.nii.gz
do
cp $filename S${cnt}_echotmp2.nii.gz
cnt=$(($cnt+1))
done

cnt=100
for filename in S*e3.nii.gz
do
cp $filename S${cnt}_echotmp3.nii.gz
cnt=$(($cnt+1))
done

cnt=100
for filename in S*_echotmp1.nii.gz
do
3dMean -overwrite -prefix echo_average_${cnt}.nii.gz S${cnt}_echotmp1.nii.gz S${cnt}_echotmp2.nii.gz S${cnt}_echotmp3.nii.gz
cnt=$(($cnt+1))
done

rm *echotmp*.nii.gz

antsMultivariateTemplateConstruction.sh \
  -d 3 \
  -o template_ \
  -i 4 \
  -g 0.2 \
  -j 4 \
  -c 2 \
  -k 1 \
  -w 1 \
  -m 100x70x50x10 \
  -n 1 \
  -r 1 \
  -s CC \
  -t GR \
  echo_average*.nii.gz


rm *echotmp.nii.gz

antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [echo_average_source2.nii.gz,echo_average_source1.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[echo_average_source2.nii.gz,echo_average_source1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[echo_average_source2.nii.gz,echo_average_source1.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[echo_average_source2.nii.gz,echo_average_source1.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

cp registered1_Warped.nii.gz Source1_registered.nii.gz


antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [echo_average_S28.nii.gz,echo_average_source2.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_source2.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_source2.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[echo_average_S28.nii.gz,echo_average_source2.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

cp registered1_Warped.nii.gz Source2_registered.nii.gz



antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [echo_average_S28.nii.gz,echo_average_S12.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S12.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S12.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S12.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

cp registered1_Warped.nii.gz S12_registered.nii.gz




antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [echo_average_S28.nii.gz,echo_average_S14.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S14.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S14.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S14.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

cp registered1_Warped.nii.gz S14_registered.nii.gz



antsRegistration \
--dimensionality 3  \
--float 0  \
--collapse-output-transforms 1  \
--output [registered1_,registered1_Warped.nii.gz,registered1_InverseWarped.nii.gz]  \
--interpolation  BSpline[5]  \
--use-histogram-matching 0  \
--winsorize-image-intensities [0.005,0.995]  \
--initial-moving-transform [echo_average_S28.nii.gz,echo_average_S40.nii.gz,1]  \
--transform Rigid[0.1]  \
--metric MI[echo_average_S28.ni.gz,echo_average_S40.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform Affine[0.1]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S40.nii.gz,1,32,Regular,0.25]  \
--convergence [1000x500x250x100,1e-6,10]  \
--shrink-factors 12x8x4x2  \
--smoothing-sigmas 4x3x2x1vox  \
--transform SyN[0.1,3,0]  \
--metric MI[echo_average_S28.nii.gz,echo_average_S40.nii.gz,1,4]  \
--convergence [100x100x70x50x20,1e-6,10]  \
--shrink-factors 10x6x4x2x1  \
--smoothing-sigmas 5x3x2x1x0vox 

cp registered1_Warped.nii.gz S40_registered.nii.gz
