#!/bin/bash

#on felix run me with: sbatch --mem=100g --cpus-per-task=50 --time=14400:00  denoise_me_felix_nn.sh

module load ANTs


echo "I expect 2 filed. the T1_weighted EPI.nii and a MP2RAGE_orig.nii"

#  bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=50
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

DenoiseImage -d 4 -n Rician -i Not_Nulled_Basis_0a.nii -o denoised_Not_Nulled_Basis_0a.nii
DenoiseImage -d 4 -n Rician -i Not_Nulled_Basis_0a.nii -o denoised_Not_Nulled_Basis_2a.nii
DenoiseImage -d 4 -n Rician -i Not_Nulled_Basis_0a.nii -o denoised_Not_Nulled_Basis_4a.nii
DenoiseImage -d 4 -n Rician -i Not_Nulled_Basis_0a.nii -o denoised_Not_Nulled_Basis_a.nii


echo "und tschuess"

 
