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
