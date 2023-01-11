

%% \: Running NORDIC
addpath(genpath('//Volumes/Redthin/NIH_MRI/20230106_DAN/NORDIC/')); %contains .m function
pathNORDIC=['/Volumes/Redthin/NIH_MRI/20230106_DAN/NORDIC/'];
cd(pathNORDIC) % working inside the data folder
                
                ARG.NORDIC=1;
                RG.noise_volume_last = 1;
                ARG.save_add_info =1;
                ARG.magnitude_only=1;
                %ARG.MP = 2; 
                ARG.kernel_size_PCA = [10, 10, 10]; 

%                 fn_magn_in='moco_Basis_bold_1.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
%                 
%                 fn_magn_in='moco_Basis_bold_2.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
% 
%                 fn_magn_in='moco_Basis_bold_3.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
%       
%                 fn_magn_in='moco_Basis_bold_4.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
% 
%                 fn_magn_in='moco_Basis_cbv_1.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
%                 
%                 fn_magn_in='moco_Basis_cbv_2.nii';
%                 fn_phase_in=fn_magn_in;
%                 fn_out=['NORDIC_' fn_magn_in];
%                 NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 

                fn_magn_in='moco_Basis_cbv_3.nii';
                fn_phase_in=fn_magn_in;
                fn_out=['NORDIC_' fn_magn_in];
                NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
      
                fn_magn_in='moco_Basis_cbv_4.nii';
                fn_phase_in=fn_magn_in;
                fn_out=['NORDIC_' fn_magn_in];
                NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG) 
