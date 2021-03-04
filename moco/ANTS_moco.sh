#!/bin/bash

#this script has been developed with kind support from Sri and tested on Bens server dabeast
#This stript does motion correction by nonliniarly aligning each individual Time frame of a time series. 


#checking how many TRs there are
n_vols=`PrintHeader $1 | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`
tr=1 

echo "seperating $n_vols time steps to save RAM"
ImageMath 4 vol_.nii TimeSeriesDisassemble $1 # vol_1000.nii, vol_1001.nii ...

basevol=1000 # ANTs indexing
nthvol=$(($basevol + $n_vols - 1)) # Zero indexing

echo "doing the alignemt"
for i in $(eval echo "{$basevol..$nthvol}");
do
antsRegistrationSyN.sh -d 3 -f vol_1000.nii -m vol_${i}.nii -o vol_${i}_ -t a -n 30 -p f -j 1 -e 42
done

echo "reassembling the time points"
ImageMath 4 moco_$1 TimeSeriesAssemble $tr vol_*_Warped.nii.gz

rm vol_*.nii vol_*_Warped.nii.gz vol_*_InverseWarped.nii.gz


#the -t s is doing rigid affine andSyn
#the -t a would do rigid and affine only


# the same in docker: 
#sudo docker run --rm -it -v $PWD:/data YOURDOCKER antsMotionCorr -d 3 -l -n 10 -m MI[/data/nulled_mean.nii.gz,/data/nulled_subset.nii.gz,1,32,Regular,0.25] -u 1 -e -t Rigid[0.2] -i 30x15 -s 1x0 -f 2x1 -m MI[/data/nulled_mean.nii.gz,/data/nulled_subset.nii.gz,1,32,Regular,0.25] -t Affine[0.1] -i 30x15 -s 1x0 -f 2x1 -o [/data/test_itk4,/data/test_itk4_warped.nii.gz,/data/test_itk4_avg.nii.gz] -w 1 -v 1
