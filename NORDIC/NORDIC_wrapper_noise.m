

%% \: Running NORDIC

function NORDIC_executing (pathtofile)
display(pathtofile);


                ARG.NORDIC=1;
                ARG.noise_volume_last = 1;
                ARG.save_add_info =1;
                ARG.magnitude_only=1;
                ARG.factor_error=1.1
                %ARG.MP = 2; 
                ARG.kernel_size_PCA = [10, 10, 10]; 
                ARG.write_gzipped_niftis=1;

                fn_magn_in=pathtofile;
                fn_phase_in=fn_magn_in;
                fn_out=['NORDIC_' fn_magn_in];
                NIFTI_NORDIC(fn_magn_in,fn_phase_in,fn_out,ARG)  

exit
