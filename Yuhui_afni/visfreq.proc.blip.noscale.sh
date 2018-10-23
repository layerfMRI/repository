#!/usr/bin/env bash
module load afni

# created by uber_subject.py: version 0.39 (March 21, 2016)
# creation date: Mon Jan 23 12:21:21 2017

# set data directories
top_dir=$1
anatFile=$top_dir/SUMA/brain.nii
distr=4
subj=$2
motion_limit=0.3
epi_dsets=($(ls -f $top_dir/Func/${subj}flicker*nii*))
blip_reverse_epi="$top_dir/Func/encoddirreverse*nii*"

if [ ! -f ${anatFile} ]; then
    subjID=${top_dir#*Subj*_}
    subjID=${subjID%2}1
    dataDir=${top_dir%/1*Subj*}
    anatFile=`ls ${dataDir}/*${subjID}/SUMA/brain.nii`
fi

sumaDir=${anatFile%/brain.nii}

if [ ! -d $top_dir/${subj}.noscale.results ]; then
    # run afni_proc.py to create a single subject processing script # tshift align volreg mask scale regress
    afni_proc.py -subj_id $subj                                           \
            -out_dir $top_dir/${subj}.noscale.results                               \
            -script $top_dir/proc.${subj}.noscale -scr_overwrite                    \
            -blocks align volreg mask regress      \
            -copy_anat $anatFile                                    \
            -anat_has_skull no                                            \
            -tcat_remove_first_trs ${distr}                               \
            -dsets                                                        \
                ${epi_dsets[@]}                                                \
            -volreg_align_to MIN_OUTLIER                                  \
            -volreg_align_e2a               \
            -blip_reverse_dset ${blip_reverse_epi}                  \
            -regress_stim_times                                               \
                $top_dir/Stim/${subj}_01Hz_dis${distr}TR.txt                      \
                $top_dir/Stim/${subj}_05Hz_dis${distr}TR.txt                      \
                $top_dir/Stim/${subj}_10Hz_dis${distr}TR.txt                      \
                $top_dir/Stim/${subj}_20Hz_dis${distr}TR.txt                      \
                $top_dir/Stim/${subj}_30Hz_dis${distr}TR.txt                      \
                $top_dir/Stim/${subj}_vigilance_dis${distr}TR.txt                \
                $top_dir/Stim/${subj}_01Hz_dis${distr}TR_onset.txt                      \
                $top_dir/Stim/${subj}_05Hz_dis${distr}TR_onset.txt                      \
                $top_dir/Stim/${subj}_10Hz_dis${distr}TR_onset.txt                      \
                $top_dir/Stim/${subj}_20Hz_dis${distr}TR_onset.txt                      \
                $top_dir/Stim/${subj}_30Hz_dis${distr}TR_onset.txt                      \
                $top_dir/Stim/${subj}_01Hz_dis${distr}TR_offset.txt                      \
                $top_dir/Stim/${subj}_05Hz_dis${distr}TR_offset.txt                      \
                $top_dir/Stim/${subj}_10Hz_dis${distr}TR_offset.txt                      \
                $top_dir/Stim/${subj}_20Hz_dis${distr}TR_offset.txt                      \
                $top_dir/Stim/${subj}_30Hz_dis${distr}TR_offset.txt                      \
            -regress_stim_labels                                              \
                vs01Hz vs05Hz vs10Hz vs20Hz vs30Hz vigilance    \
                vs01Hz_onset vs05Hz_onset vs10Hz_onset vs20Hz_onset vs30Hz_onset \
                vs01Hz_offset vs05Hz_offset vs10Hz_offset vs20Hz_offset vs30Hz_offset \
            -regress_basis_multi                                              \
                'BLOCK(16.44,1)' 'BLOCK(16.44,1)' 'BLOCK(16.44,1)' 'BLOCK(16.44,1)' 'BLOCK(16.44,1)' 'GAM' \
                'GAM' 'GAM' 'GAM' 'GAM' 'GAM' 'GAM' 'GAM' 'GAM' 'GAM' 'GAM'   \
            -regress_censor_motion ${motion_limit}                       \
            -regress_censor_outliers 0.1                                   \
            -regress_opts_3dD                                                 \
                -jobs 8                                                       \
                -num_glt 5                                                             \
                -gltsym 'SYM: 0.25*vs01Hz +0.25*vs05Hz +0.25*vs10Hz +0.25*vs20Hz'      \
                -glt_label 1 mean_vs01to20Hz                                           \
                -gltsym 'SYM: 0.5*vs05Hz +0.5*vs10Hz'                                  \
                -glt_label 2 mean_vs05to10Hz                                           \
                -gltsym 'SYM: vs01Hz -0.5*vs20Hz -0.5*vs30Hz'                          \
                -glt_label 3 01Hz-h20Hz30Hz                                        \
                -gltsym 'SYM: 0.5*vs01Hz +0.5*vs05Hz -0.5*vs20Hz -0.5*vs30Hz'       \
                -glt_label 4 h0105Hz-h2030Hz                                        \
                -gltsym 'SYM: vs01Hz -vs30Hz'                                          \
                -glt_label 5 01Hz-30Hz                                               \
            -regress_make_ideal_sum sum_ideal.1D                              \
            -regress_no_fitts                                                   \
            -regress_compute_gcor no                                              \
            -regress_make_cbucket yes    

    tcsh $top_dir/proc.${subj}.noscale |& tee $top_dir/output.proc.${subj}.noscale      
fi

mv $top_dir/proc.${subj}.noscale $top_dir/${subj}.noscale.results/
mv $top_dir/output.proc.${subj}.noscale $top_dir/${subj}.noscale.results/

