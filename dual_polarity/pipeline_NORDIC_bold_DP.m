
%% Set, check and move to path
clc; clear; close all
%Input subject information:
SOI=[1]; %Subject of interest
num_runs=1;
%Create structure with path for current subject and sessions:
counter=1;
for i=SOI
    current_study=sprintf('S%02d',SOI(counter));
    subjstruc(i).rootDir=['/Volumes/china2/rhythmicVersusDiscrete/' current_study];
    subjstruc(i).resultsDir=['/Volumes/china2/rhythmicVersusDiscrete/' current_study '/results'];
    subjstruc(i).analysisDir=['/Volumes/china2/rhythmicVersusDiscrete/' current_study '/results/analysis'];
    subjstruc(i).numRuns=num_runs;
    counter=counter+1;
end 

%% Sort DICOMS, convert, remove dummies, and split timeseries into separate polarities
%Use sortDICOMS.sh


%% NORDIC
clc; close all
clearvars -except subjstruc SOI
ARG.magnitude_only = 0; %if 1, only use magnitude images.
ARG.make_complex_nii=1; %Also output denoised phase.
ARG.temporal_phase=1;
ARG.phase_filter_width=10;
ARG.gfactor_patch_overlap=6;
% ARG.kernel_size_PCA=[26 26 1];
%ARG.save_gfactor_map=1;
%ARG.save_add_info=1;
%ARG.save_residual_matlab=1;
ARG.factor_error=1; %Threshold scaling (1 is default).
ARG.noise_volume_last=0;
for i=SOI
cd(subjstruc(i).resultsDir)
for run=1:subjstruc(i).numRuns
NIFTI_NORDIC(['noNORDIC_bold_0' num2str(run) '_dp1.nii'],['noNORDIC_bold_0' num2str(run) 'phase_dp1.nii'],['NORDIC_bold_0' num2str(run) '_dp1'],ARG);
NIFTI_NORDIC(['noNORDIC_bold_0' num2str(run) '_dp2.nii'],['noNORDIC_bold_0' num2str(run) 'phase_dp2.nii'],['NORDIC_bold_0' num2str(run) '_dp2'],ARG);

movefile(['NORDIC_bold_0' num2str(run) '_dp1magn.nii'],['NORDIC_bold_0' num2str(run) '_dp1.nii'])
movefile(['NORDIC_bold_0' num2str(run) '_dp2magn.nii'],['NORDIC_bold_0' num2str(run) '_dp2.nii'])
movefile(['NORDIC_bold_0' num2str(run) '_dp1phase.nii'],['NORDIC_bold_0' num2str(run) 'phase_dp1.nii'])
movefile(['NORDIC_bold_0' num2str(run) '_dp2phase.nii'],['NORDIC_bold_0' num2str(run) 'phase_dp2.nii'])
end
end

%% Run preproc_bold_DP.sh
