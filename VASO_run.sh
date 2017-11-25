#!/bin/bash



echo "fange an"

antiBold Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
fix_TR_s.sh Anti_BOLD_no_drift.nii
fix_TR_s.sh Bold_no_drift.nii
drift_s.sh Bold_no_drift.nii
drift_s.sh Anti_BOLD_no_drift.nii
SNR_int_corr Nulled_Basis_b.nii Not_Nulled_Basis_a.nii 0
SNR_any_series Anti_BOLD_no_drift.nii 0 
SNR_any_series Bold_no_drift.nii 0 

#phase_eval.sh
#isisconv -in . -out ../nii/S{sequenceNumber}_{sequenceDescription}_{echoTime}_{coilChannelMask}.nii -wdialect fsl -repn s16bit

echo "und tschuess"

 
