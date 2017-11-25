#!/bin/bash



echo "fange an 1600802"

antiBold Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
fix_TR_s.sh Bold_no_drift.nii
fix_TR_s.sh Anti_BOLD_no_drift.nii
drift_s.sh Bold_no_drift.nii
drift_s.sh Anti_BOLD_no_drift.nii
SNR_int_corr Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
SNR_any_series Anti_BOLD_no_drift.nii 0 
SNR_any_series Bold_no_drift.nii 0 
MAP Anti_BOLD_no_drift.nii  Bold_no_drift.nii MEAN_Nulled_Basis_b.nii

cp /home/brain/Desktop/sf_NeuroDebian/repository/feat_design_template.fsf ./feat_design_VASO.fsf
pfad=$(pwd)
sed -i "1 i\set feat_files(1) $pfad/Anti_BOLD_no_drift" feat_design_VASO.fsf
feat feat_design_VASO.fsf
cp ./Anti_BOLD_no_drift.feat/stats/zstat2.nii VASO_zstat2.nii

cp /home/brain/Desktop/sf_NeuroDebian/repository/feat_design_template.fsf ./feat_design_BOLD.fsf
sed -i "1 i\set feat_files(1) $pfad/Bold_no_drift" feat_design_BOLD.fsf
feat feat_design_BOLD.fsf
cp ./Bold_no_drift.feat/stats/zstat1.nii BOLD_zstat1.nii

rm feat_design_VASO.fsf
rm feat_design_BOLD.fsf

phase_eval.sh

# berechnie absolute signal aenderung von VASO und BOLD
3dcalc -a dVASO.nii -b MEAN_Anti_BOLD_no_drift.nii -expr "a*b" -overwrite -prefix abs_dVASO.nii
3dcalc -a dBOLD.nii -b MEAN_Bold_no_drift.nii -expr "a*b" -overwrite -prefix abs_dBOLD.nii

echo "I am in $pfad"
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
