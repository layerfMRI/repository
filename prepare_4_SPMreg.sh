#!/bin/bash

Renzo_mask.sh MEAN_Bold_no_drift.nii

CLEAN_MP2R T1_instability_intensNulled_Basis_b.nii mask.nii 0

FFT_INT cleanedT1_instability_intensNulled_Basis_b.nii 0

susan_me.sh  scaled_amplcleanedT1_instability_intensNulled_Basis_b.nii

edge_18.sh susan_scaled_amplcleanedT1_instability_intensNulled_Basis_b.nii
