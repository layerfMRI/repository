#!/bin/bash

3dautomask -prefix moma.nii -overwrite -peels 3 -dilate 2 vol_1000.nii.gz


3dZeropad -A -4 -P -4 -I -4 -S -4 -R -4 -L -4 \
    -overwrite                                \
    -prefix _tmp_AAA.nii.gz                   \
      moma.nii

3dcalc                           \
    -overwrite                   \
    -a           _tmp_AAA.nii.gz \
    -expr        '100*a'           \
    -prefix      _tmp_BBB.nii.gz \
    -datum       short

3dZeropad                                     \
    -overwrite                                \
    -master         moma.nii       \
    -prefix         _tmp_CCC.nii.gz           \
    _tmp_BBB.nii.gz 

3dmerge                                       \
    -overwrite                                \
    -1blur_sigma    3                         \
    -prefix         weight_gauss.nii.gz       \
    _tmp_CCC.nii.gz

rm *_tmp_*


# optional: fixing oblique header and removing outer slice 
3dcalc -overwrite -b weight_gauss.nii.gz -expr 'step(b-81)' -prefix moma.nii

fslcpgeom vol_1000.nii.gz moma.nii

#checking how many TRs there are
n_vols=`PrintHeader merged.nii | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`
tr=1 

echo "seperating $n_vols time steps to save RAM"
ImageMath 4 vol_.nii TimeSeriesDisassemble merged.nii # vol_1000.nii, vol_1001.nii ...



antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1001_,vol_1001_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1001.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1001.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1001.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1002_,vol_1002_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1002.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1002.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1002.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1003_,vol_1003_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1003.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1003.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1003.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1004_,vol_1004_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1004.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1004.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1004.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1005_,vol_1005_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1005.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1005.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1005.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox


antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1006_,vol_1006_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1006.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1006.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1006.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox


antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1007_,vol_1007_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1007.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1007.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1007.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsRegistration \
--dimensionality 3 \
--float 1 \
--collapse-output-transforms 1 \
--output [vol_1000_,vol_1000_Warped.nii.gz,1] \
--interpolation BSpline[2] \
--use-histogram-matching 1 \
--winsorize-image-intensities [ 0.005,0.995 ] \
-x moma.nii \
--initial-moving-transform [vol_1000.nii.gz,vol_1000.nii.gz,1 ] \
--transform Rigid[ 0.1 ] \
--metric MI[vol_1000.nii.gz,vol_1000.nii.gz,1,32,Regular,0.25 ] \
--convergence [ 250x100,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[ 0.1,3,0 ] \
--metric CC[vol_1000.nii.gz,vol_1000.nii.gz,1,2 ] \
--convergence [ 50x0,1e-6,10 ] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

#this script has been developed with kind support from Sri and tested on Bens server dabeast
#This stript does motion correction by nonliniarly aligning each individual Time frame of a time series. 


echo "reassembling the time points"
ImageMath 4 moco_300.nii.gz TimeSeriesAssemble 1 vol_*_Warped.nii.gz

#m vol_*.nii vol_*_Warped.nii.gz vol_*_InverseWarped.nii.gz


#the -t s is doing rigid affine andSyn
#the -t a would do rigid and affine only


# the same in docker: 
#sudo docker run --rm -it -v $PWD:/data YOURDOCKER antsMotionCorr -d 3 -l -n 10 -m MI[/data/nulled_mean.nii.gz,/data/nulled_subset.nii.gz,1,32,Regular,0.25] -u 1 -e -t Rigid[0.2] -i 30x15 -s 1x0 -f 2x1 -m MI[/data/nulled_mean.nii.gz,/data/nulled_subset.nii.gz,1,32,Regular,0.25] -t Affine[0.1] -i 30x15 -s 1x0 -f 2x1 -o [/data/test_itk4,/data/test_itk4_warped.nii.gz,/data/test_itk4_avg.nii.gz] -w 1 -v 1


