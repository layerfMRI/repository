#!/bin/bash

# Adapted from https://github.com/layerfMRI/repository/blob/master/moco/forcomparison/AFNI/AFNI_moco_cbvbold.sh
# Credit: Renzo Huber NIH, Paul Taylor NIH, Marco Barilari UCLouain
#
# Scipt actions:
# (1) removes the nordic noise scans (assuming are 2 vols at the end)
# (2) create a "referenmce" to align to all the volumes across the runs (it is an average of the first 2 volumes 
#     of run 1, one for nulled and one for not nulled series)
# (3) align each volume to the reference (using 6 DOF)

# stop on first error
set -e

# set some subject spefici info to query the data
subID="SC14"

sesID="02"

taskID="bimodalMotionVis"

output_dir="/Volumes/PAUL/datalad/analysis_high-res_BLAM_NIH_vaso_sandbox/outputs/derivates_nodl/${taskID}-vaso-preproc/sub-${subID}"

# calculate motion alignment, with *solid body (6 DOF)*
echo "starting file loop nulled"

cnt=1

for filename in ${output_dir}/sub*nordic_nulled.nii; do
    
    echo ""
    echo "run moco for:" "${filename}"
    echo ""

    # remove noise scans from the end of the time series (it is '-3' due to afni indexing starting from 0) 
    NumVol=`3dinfo -nv $filename`

    3dTcat \
        -prefix ${output_dir}/sub-${subID}_Basis_cbv_${cnt}.nii \
        $filename'[0..'`expr $NumVol - 3`']' \
        -overwrite

    # Example in case you need to remove "not in steady state" vols aka dummies, check that file names matches
    # 3dCopy $filename ${output_dir}/Basis_cbv_${cnt}.nii -overwrite
    # 3dTcat -prefix Basis_bold_${cnt}.nii Basis_cbv_${cnt}.nii'[2..3]' Basis_cbv_${cnt}.nii'[2..$]' -overwrite

    # create the refence
    3dMean -prefix ${output_dir}/n_reference.nii ${output_dir}/sub-${subID}_Basis_cbv_1.nii'[0..3]'

    mask_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_desc-brainMask_space-EPI_mask.nii"

    # run realignment    
    # remove the -warp line to make it an affine transformation. 
    3dAllineate \
        -1Dmatrix_save  ${output_dir}/sub-${subID}_ALLIN_cbv_${cnt}.aff12.1D \
        -1Dparam_save   ${output_dir}/sub-${subID}_ALLIN_cbv_${cnt}.aff12 \
        -cost           lpa \
        -prefix         ${output_dir}/sub-${subID}_moco_Basis_cbv_${cnt}.nii \
        -base           ${output_dir}/n_reference.nii \
        -source         ${output_dir}/sub-${subID}_Basis_cbv_${cnt}.nii \
        -weight         ${mask_name} \
        -warp           shift_rotate \
        -final          wsinc5
    
    # in case data is an oblique dataset, you might encoure in a motion corrected series which not anymore in the original orientation
    # here we correct for that by copyng back in the header the original orientation info
    if [[ $(3dinfo -is_oblique ${output_dir}/n_reference.nii) == 1 ]]; then

        # copy the full matrix from ref dset to the copy, essentially "putting back" any obliquity
        # info that might have been purged by 3dAllineate

        echo ""
        echo "correcting for possible output misplacement"
        echo ""

        3drefit \
            -atrcopy ${output_dir}/n_reference.nii IJK_TO_DICOM_REAL \
            ${output_dir}/sub-${subID}_moco_Basis_cbv_${cnt}.nii

    fi 

    # copy of the motion paramenters in a easy readable format
    cp ${output_dir}/sub-${subID}_ALLIN_cbv_${cnt}.aff12.param.1D ${output_dir}/sub-${subID}_ALLIN_cbv_${cnt}.aff12.param.txt

    cnt=$(($cnt+1))


done

cnt=1

echo "starting file loop notnulled"

for filename in ${output_dir}/sub*nordic_notnulled.nii ; do

    echo ""
    echo "run moco for:" "${filename}"
    echo ""
    
    # remove noise scans from the end of the time series (it is '-3' due to afni indexing starting from 0) 
    NumVol=`3dinfo -nv $filename`

    3dTcat \
        -prefix ${output_dir}/sub-${subID}_Basis_bold_${cnt}.nii \
        $filename'[0..'`expr $NumVol - 3`']' \
        -overwrite

    # Example in case you need to remove "not in steady state" vols aka dummies
    # 3dCopy $filename ${output_dir}/Basis_bold_${cnt}.nii -overwrite
    # 3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite
    
    3dMean -prefix ${output_dir}/nn_reference.nii ${output_dir}/sub-${subID}_Basis_bold_1.nii'[1..3]'

    # create the refence
    mask_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_desc-brainMask_space-EPI_mask.nii"

    # run realignment    
    # remove the -warp line to make it an affine transformation. 
    3dAllineate \
        -1Dmatrix_save  ${output_dir}/sub-${subID}_ALLIN_bold_${cnt}.aff12.1D \
        -1Dparam_save   ${output_dir}/sub-${subID}_ALLIN_bold_${cnt}.aff12 \
        -cost           lpa \
        -prefix         ${output_dir}/sub-${subID}_moco_Basis_bold_${cnt}.nii \
        -base           ${output_dir}/nn_reference.nii \
        -source         ${output_dir}/sub-${subID}_Basis_bold_${cnt}.nii \
        -weight         ${mask_name} \
        -warp           shift_rotate \
        -final          wsinc5

    # in case data is an oblique dataset, you might encoure in a motion corrected series which not anymore in the original orientation
    # here we correct for that by copyng back in the header the original orientation info
    if [[ $(3dinfo -is_oblique ${output_dir}/nn_reference.nii) == 1 ]]; then

        # copy the full matrix from ref dset to the copy, essentially "putting back" any obliquity
        # info that might have been purged by 3dAllineate

        echo ""
        echo "correcting for possible output misplacement"
        echo ""

        3drefit \
            -atrcopy ${output_dir}/n_reference.nii IJK_TO_DICOM_REAL \
            ${output_dir}/sub-${subID}_moco_Basis_bold_${cnt}.nii

    fi 

    # copy of the motion paramenters in a easy readable format
    cp ${output_dir}/sub-${subID}_ALLIN_bold_${cnt}.aff12.param.1D ${output_dir}/sub-${subID}_ALLIN_bold_${cnt}.aff12.param.txt

    cnt=$(($cnt+1))

done 