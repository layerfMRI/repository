#!/bin/bash

# Adapted from https://github.com/layerfMRI/repository/blob/master/moco/forcomparison/mask_generation.sh
# Credit: Renzo Huber

# create weight, essentially an "inner" block (smoothed at the
# boundary) to remove influence of differing FOV coverage

subID="SC14"

sesID="02"

taskID="bimodalMotionVis"

output_dir="/Volumes/PAUL/datalad/analysis_high-res_BLAM_NIH_vaso_sandbox/outputs/derivates_nodl/${taskID}-vaso-preproc/sub-${subID}"

cnt=1

for filename in ${output_dir}/*_boldcbv.nii; do

    echo ""
    echo "creating mask for:" "${filename}"
    echo ""

    mask_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_desc-brainMask_space-EPI_mask.nii"

    weighted_gaus_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_weightedgauss.nii"

    3dautomask \
        -prefix ${mask_name} \
        -peels 3 \
        -dilate 2 \
        ${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_boldcbv.nii

    3dZeropad \
        -A -4 -P -4 -I -4 -S -4 -R -4 -L -4 \
        -overwrite \
        -prefix _tmp_AAA.nii.gz \
        ${mask_name}

    3dcalc \
        -overwrite \
        -a _tmp_AAA.nii.gz \
        -expr '100*a' \
        -prefix _tmp_BBB.nii.gz \
        -datum short

    3dZeropad \
        -overwrite \
        -master ${mask_name} \
        -prefix _tmp_CCC.nii.gz \
        _tmp_BBB.nii.gz 

    3dmerge \
        -overwrite \
        -1blur_sigma 3 \
        -prefix ${weighted_gaus_name} \
        _tmp_CCC.nii.gz

    rm *_tmp_*

    # optional: fixing oblique header and removing outer slice 
    3dcalc \
        -overwrite \
        -a ${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_boldcbv.nii \
        -b ${weighted_gaus_name} \
        -expr 'step(0*a+b-55)' \
        -prefix ${mask_name}

    # fixing header 
    cnt=$(($cnt+1))

done