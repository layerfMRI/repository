#!/bin/bash



echo "fange an"

mkdir PHASE

for filename in *_PHS_*
do
mv $filename ./PHASE/$filename
done

mkdir UNI

fslmerge -t merged_UNI_DEN.nii *DEN*.nii

fslmerge -t merged_INV1.nii *INV1*.nii
fslmerge -t merged_INV2.nii *INV2*.nii
fslmerge -t merged_T1.nii *T1*.nii

3dTstat -mean -prefix mean_INV1.nii merged_INV1.nii -overwrite
3dTstat -mean -prefix mean_INV2.nii merged_INV2.nii -overwrite
3dTstat -mean -prefix mean_T1.nii   merged_T1.nii -overwrite

3dcalc -a mean_INV1.nii -b mean_INV2.nii -c mean_T1.nii -expr '(a+b)*c' -prefix intens.nii -overwrite

3dclust -savemask clusters.nii -1clip 500000 0.499 2000 intens.nii -overwrite
3dclust -savemask cluster_cluster.nii -1clip 1 0.8 2000 clusters.nii -overwrite
3dclust -savemask single_cluster.nii -1clip 1.5 0.8 2000 cluster_cluster.nii -overwrite

3dcalc -a cluster_cluster.nii -b single_cluster.nii -expr '(a-2*b)' -prefix motion_mask.nii -overwrite

echo "und tschuess"

 
