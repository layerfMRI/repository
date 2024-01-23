#!/bin/bash

# Adapted from https://github.com/layerfMRI/repository/blob/master/moco/forcomparison/AFNI/AFNI_moco_cbvbold.sh
# Credit: Renzo Huber

# stop on first error
set -e

# calculate motion alignment, with *solid body (6 DOF)*
echo "starting file loop nulled"

subID="SC14"

sesID="02"

taskID="bimodalMotionVis"

output_dir="/Volumes/PAUL/datalad/analysis_high-res_BLAM_NIH_vaso_sandbox/outputs/derivates_nodl/${taskID}-vaso-preproc/sub-${subID}"

cnt=1

for filename in ${output_dir}/sub*nordic_nulled.nii; do
    
    # FOR TESTING ONLY
    # filename="/Volumes/PAUL/datalad/analysis_high-res_BLAM_NIH_vaso_sandbox/outputs/derivates_nodl/bimodalMotionVis-vaso-preproc/sub-SC08/sub-SC08_ses-02_task-bimodalMotionVis_run-01_label-nordic_nulled.nii"

    echo ""
    echo "run moco for:" "${filename}"
    echo ""

    # remove noise scans from the end of the time series (it is '-3' due to afni indexing starting from 0) 
    NumVol=`3dinfo -nv $filename`

    3dTcat \
        -prefix ${output_dir}/Basis_cbv_${cnt}.nii \
        $filename'[0..'`expr $NumVol - 3`']' \
        -overwrite


    # 3dCopy $filename ${output_dir}/Basis_cbv_${cnt}.nii -overwrite

    # 3dTcat -prefix Basis_cbv_${cnt}.nii Basis_cbv_${cnt}.nii'[2..3]' Basis_cbv_${cnt}.nii'[2..$]' -overwrite

    # if [$cnt == 1]; then
        3dMean -prefix ${output_dir}/n_reference.nii ${output_dir}/Basis_cbv_1.nii'[0..3]'
    # fi

    mask_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_desc-brainMask_space-EPI_mask.nii"

    # set ttt = 020
    3dAllineate \
        -1Dmatrix_save  ${output_dir}/ALLIN_cbv_${cnt}.aff12.1D \
        -1Dparam_save   ${output_dir}/ALLIN_cbv_${cnt}.aff12 \
        -cost           lpa \
        -prefix         ${output_dir}/moco_Basis_cbv_${cnt}.nii \
        -base           ${output_dir}/n_reference.nii \
        -source         ${output_dir}/Basis_cbv_${cnt}.nii \
        -weight         ${mask_name} \
        -warp           shift_rotate \
        -final          wsinc5
    # remove the -warp line to make it an affine transformation. 

    fslcpgeom ${output_dir}/Basis_cbv_${cnt}.nii ${output_dir}/moco_Basis_cbv_${cnt}.nii 


    cp ${output_dir}/ALLIN_cbv_${cnt}.aff12.param.1D ${output_dir}/ALLIN_cbv_${cnt}.aff12.param.txt

    cnt=$(($cnt+1))


done

cnt=1
echo "starting file loop notnulled"

for filename in ${output_dir}/sub*nordic_notnulled.nii ; do

    echo ""
    echo "run moco for:" "${filename}"
    echo ""
    
    3dTcat \
        -prefix ${output_dir}/Basis_bold_${cnt}.nii \
        $filename'[0..'`expr $NumVol - 3`']' \
        -overwrite

    # 3dCopy $filename ${output_dir}/Basis_bold_${cnt}.nii -overwrite
    # 3dTcat -prefix Basis_bold_${cnt}.nii Basis_bold_${cnt}.nii'[2..3]' Basis_bold_${cnt}.nii'[2..$]' -overwrite
    
    # if [cnt == 1]; then
        3dMean -prefix ${output_dir}/nn_reference.nii ${output_dir}/Basis_bold_1.nii'[1..3]'
    # fi

    mask_name="${output_dir}/sub-${subID}_ses-${sesID}_task-${taskID}_run-0${cnt}_desc-brainMask_space-EPI_mask.nii"

    set ttt = 020
    3dAllineate \
        -1Dmatrix_save  ${output_dir}/ALLIN_bold_${cnt}.aff12.1D \
        -1Dparam_save   ${output_dir}/ALLIN_bold_${cnt}.aff12 \
        -cost           lpa \
        -prefix         ${output_dir}/moco_Basis_bold_${cnt}.nii \
        -base           ${output_dir}/nn_reference.nii \
        -source         ${output_dir}/Basis_bold_${cnt}.nii \
        -weight         ${mask_name} \
        -warp           shift_rotate \
        -final          wsinc5
    # remove the -warp line to make it an affine transformation. 

    fslcpgeom ${output_dir}/Basis_bold_${cnt}.nii ${output_dir}/moco_Basis_bold_${cnt}.nii 

    cp ${output_dir}/ALLIN_bold_${cnt}.aff12.param.1D ${output_dir}/ALLIN_bold_${cnt}.aff12.param.txt

    cnt=$(($cnt+1))

done 