#!/bin/bash


3dautomask -prefix moma.nii -peels 3 -dilate 2 NORDIC_S*_bold*.nii



#read ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
#export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
tr=1.875
basevol=1000 # ANTs indexing


###########################################
####### preparig odd and even images ######
###########################################

n_vols=`PrintHeader S*_bold*.nii | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`

cnt=1
echo "starting file loop nulled"
for filename in ./NORDIC_S*_cbv*.nii
do
echo $filename
3dCopy $filename ./Basis_cbv_${cnt}.nii -overwrite
3dTcat -prefix Basis_cbv_${cnt}.nii Basis_cbv_${cnt}.nii'[2..3]' Basis_cbv_${cnt}.nii'[2..$]' -overwrite

n_vols=`PrintHeader Basis_cbv_1.nii | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`
nthvol=$(($basevol + $n_vols - 1)) # Zero indexing

echo "seperating $n_vols time steps to save RAM"
ImageMath 4 vol_.nii TimeSeriesDisassemble Basis_cbv_${cnt}.nii # vol_1000.nii, vol_1001.nii ...
3dMean -prefix n_reference.nii vol_1003.nii vol_1004.nii vol_1005.nii

	for i in $(eval echo "{$basevol..$nthvol}");
	do
		antsRegistration \
		--dimensionality 3 \
		--float 1 \
		--collapse-output-transforms 1 \
		--output [ vol_${i}_,vol_${i}_Warped.nii.gz,1] \
		--interpolation BSpline[2] \
		--use-histogram-matching 1 \
		--winsorize-image-intensities [ 0.005,0.995 ] \
		-x moma.nii \
		--initial-moving-transform [n_reference.nii,vol_${i}.nii,1 ] \
		--transform Rigid[ 0.1 ] \
		--metric MI[n_reference.nii,vol_${i}.nii,1,32,Regular,0.25 ] \
		--convergence [ 250x100,1e-6,10 ] \
		--shrink-factors 2x1 \
		--smoothing-sigmas 1x0vox \
		--transform SyN[ 0.1,3,0 ] \
		--metric CC[n_reference.nii,vol_${i}.nii,1,2 ] \
		--convergence [ 50x0,1e-6,10 ] \
		--shrink-factors 2x1 \
		--smoothing-sigmas 1x0vox
	done
echo "reassembling the time points"
ImageMath 4 moco_Basis_cbv_${cnt}.nii TimeSeriesAssemble $tr 0 vol_*_Warped.nii.gz
rm -f vol_*.nii vol_*_0GenericAffine.mat vol_*_1Warp.nii.gz vol_*_1InverseWarp.nii.gz vol_*_InverseWarped.nii.gz vol_*_Warped.nii.gz


cnt=$(($cnt+1))
done

echo "starting file loop not nulled"
cnt=1
for filename in ./NORDIC_S*_bold*.nii
do
echo $filename
3dCopy $filename ./Basis_bold_${cnt}.nii -overwrite
3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite

n_vols=`PrintHeader Basis_cbv_1.nii | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`
nthvol=$(($basevol + $n_vols - 1)) # Zero indexing

echo "seperating $n_vols time steps to save RAM"
ImageMath 4 vol_.nii TimeSeriesDisassemble Basis_bold_${cnt}.nii # vol_1000.nii, vol_1001.nii ...
3dMean -prefix nn_reference.nii vol_1003.nii vol_1004.nii vol_1005.nii

	for i in $(eval echo "{$basevol..$nthvol}");
	do
		antsRegistration \
		--dimensionality 3 \
		--float 1 \
		--collapse-output-transforms 1 \
		--output [ vol_${i}_,vol_${i}_Warped.nii.gz,1] \
		--interpolation BSpline[2] \
		--use-histogram-matching 1 \
		--winsorize-image-intensities [ 0.005,0.995 ] \
		-x moma.nii \
		--initial-moving-transform [nn_reference.nii,vol_${i}.nii,1 ] \
		--transform Rigid[ 0.1 ] \
		--metric MI[nn_reference.nii,vol_${i}.nii,1,32,Regular,0.25 ] \
		--convergence [ 250x100,1e-6,10 ] \
		--shrink-factors 2x1 \
		--smoothing-sigmas 1x0vox \
		--transform SyN[ 0.1,3,0 ] \
		--metric CC[nn_reference.nii,vol_${i}.nii,1,2 ] \
		--convergence [ 50x0,1e-6,10 ] \
		--shrink-factors 2x1 \
		--smoothing-sigmas 1x0vox
	done
echo "reassembling the time points"
ImageMath 4 moco_Basis_bold_${cnt}.nii TimeSeriesAssemble $tr 0 vol_*_Warped.nii.gz
rm -f vol_*.nii vol_*_0GenericAffine.mat vol_*_1Warp.nii.gz vol_*_1InverseWarp.nii.gz vol_*_InverseWarped.nii.gz vol_*_Warped.nii.gz


cnt=$(($cnt+1))
done
