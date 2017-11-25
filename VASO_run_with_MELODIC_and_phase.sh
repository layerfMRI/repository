#!/bin/bash

echo "Are you cooking in a clean kitchen?"

antiBold Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
fix_TR_s.sh Bold_no_drift.nii
fix_TR_s.sh Anti_BOLD_no_drift.nii
drift_s.sh Bold_no_drift.nii
drift_s.sh Anti_BOLD_no_drift.nii
SNR_int_corr Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
SNR_any_series Anti_BOLD_no_drift.nii 0 
SNR_any_series Bold_no_drift.nii 0 

echo "say my name bitch"

cp /home/brain/Desktop/sf_NeuroDebian/repository/MELODIC_design_template.fsf ./MELODIC_design_VASO.fsf
pfad=$(pwd)
sed -i "1 i\set feat_files(1) $pfad/Anti_BOLD_no_drift" MELODIC_design_VASO.fsf
feat MELODIC_design_VASO.fsf
cp ./Anti_BOLD_no_drift.ica/filtered_func_data.ica/melodic_IC.nii VASO_ICAs.nii
cp ./Anti_BOLD_no_drift.ica/filtered_func_data.ica/melodic_mix VASO_ICA_timecourses.dat


cp /home/brain/Desktop/sf_NeuroDebian/repository/MELODIC_design_template.fsf ./MELODIC_design_BOLD.fsf
sed -i "1 i\set feat_files(1) $pfad/Bold_no_drift" MELODIC_design_BOLD.fsf
feat MELODIC_design_BOLD.fsf
cp ./Bold_no_drift.ica/filtered_func_data.ica/melodic_IC.nii BOLD_ICAs.nii
cp ./Bold_no_drift.ica/filtered_func_data.ica/melodic_mix BOLD_ICA_timecourses.dat

rm MELODIC_design_VASO.fsf
rm MELODIC_design_BOLD.fsf

echo "Heisenberg bug detection"

phase_eval.sh


echo "I am in $pfad"
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
