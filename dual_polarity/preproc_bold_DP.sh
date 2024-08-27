subj=1
runs=(01) #2 digits per number (01, 02, 10, 11 etc.)

#for subj in ${subjects[@]}; do
printf -v rootDir "/Volumes/china2/rhythmicVersusDiscrete/S%02d" ${subj}
outputDir=${rootDir}/results
cd ${outputDir}


#============= Deoblique ============#
#Remove oblique information:
3drefit -deoblique ${outputDir}/nulled.nii
3drefit -deoblique ${outputDir}/notNulled.nii
3drefit -deoblique ${outputDir}/MP2RAGE*.nii
3drefit -deoblique ${outputDir}/noNORDIC_bold_0?.nii
3drefit -deoblique ${outputDir}/noNORDIC_bold_0?phase.nii    
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
for dp in 1 2; do #dp1 first polarity, dp2 second polarity
3drefit -deoblique ${outputDir}/${NORDvers}_bold_${run}_dp${dp}.nii
3drefit -deoblique ${outputDir}/${NORDvers}_bold_${run}phase_dp${dp}.nii
done
done
done


#============= Estimate motion parameters ============#
#Motion is estimated based on magnitude images, i.e. just align all images to magnitude-average of first volume (dp1-dp2 pair) in first run.
#Note, we tried magnitude-average instead of complex average and image looks similar so should be fine for moco.
#Note, if there is large motion between dp1 and dp2 in first volume, it might be better to align just to e.g. dp1?
3dcalc -prefix mocoBase.nii -a NORDIC_bold_01_dp1.nii'[0]' -b NORDIC_bold_01_dp2.nii'[0]' -expr '(a+b)/2'
for run in ${runs[@]} ; do
for dp in 1 2; do
3dvolreg -verbose -zpad 2 -base mocoBase.nii \
    -prefix tmp_rNORDIC_bold_${run}_dp${dp}.nii -overwrite \
    -1Dfile dfile.bold_${run}_dp${dp}.1D \
    -1Dmatrix_save mat.bold_${run}_dp${dp}.vr.aff12.1D \
    NORDIC_bold_${run}_dp${dp}.nii
done
done

mkdir ${outputDir}/coregParam
mv ${outputDir}/*.1D ${outputDir}/coregParam


#============= Check motion parameters ============#
#Concatenate motion files across runs. Should be almost identical for dp1 and dp2:
for dp in 1 2; do
cat ${outputDir}/coregParam/dfile.bold_0?_dp${dp}.1D > ${outputDir}/coregParam/dfile.bold_dp${dp}.1D  
1dplot.py                                    \
    -sepscl                                  \
    -reverse_order                           \
    -infiles ${outputDir}/coregParam/dfile.bold_dp${dp}.1D \
    -ylabels  VOLREG          \
    -xlabel  "vols"                          \
    -title   "Motion and outlier plots"      \
    -prefix  ${outputDir}/coregParam/mot_plot_bold_dp${dp}.png
done


#============= Apply motion parameters and complex averaging ============#
#Get real and imaginary components:
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
matlab -nodisplay -nosplash -r "convertToRectangular('${NORDvers}_bold_${run}_dp1.nii','${NORDvers}_bold_${run}phase_dp1.nii','${NORDvers}_bold_${run}_dp2.nii','${NORDvers}_bold_${run}phase_dp2.nii'); exit;"
done
done

#Apply magnitude-estimated motion parameters to these (interpolatable as opposed to circular scale of phase data):
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
for dp in 1 2; do
for type in "Real" "Imag"; do
#with allineate function we can use wsinc5 which has less blurring):
3dAllineate -base NORDIC_bold_01_dp1.nii'[0]' \
    -input tmp${type}_${NORDvers}_bold_${run}_dp${dp}.nii \
    -1Dmatrix_apply ./coregParam/mat.bold_${run}_dp${dp}.vr.aff12.1D \
    -final wsinc5 \
    -prefix tmp${type}_r${NORDvers}_bold_${run}_dp${dp}.nii -overwrite
done
done
done
done

#Compute complex average across polarities:
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
for type in "Real" "Imag"; do
3dmean -prefix tmp${type}_r${NORDvers}_bold_${run}.nii tmp${type}_r${NORDvers}_bold_${run}_dp1.nii tmp${type}_r${NORDvers}_bold_${run}_dp2.nii
done
done
done

#Convert to magnitude:
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
3dcalc -prefix r${NORDvers}_bold_${run}.nii -a tmpReal_r${NORDvers}_bold_${run}.nii -b tmpImag_r${NORDvers}_bold_${run}.nii -expr 'sqrt(a^2+b^2)' -overwrite
3dcalc -prefix r${NORDvers}_bold_${run}.nii -a tmpReal_r${NORDvers}_bold_${run}.nii -b tmpImag_r${NORDvers}_bold_${run}.nii -expr 'sqrt(a^2+b^2)' -overwrite
done
done




#============= Quality checks ============#
mkdir ${outputDir}/QC
#Get QA images with and without DP:
for run in ${runs[@]} ; do
LN_SKEW -input rNORDIC_bold_${run}.nii -output ${outputDir}/QC/QC_rNORDIC_bold_${run}.nii
#LN_SKEW -input tmp_rNORDIC_bold_${run}_dp1.nii -output ${outputDir}/QC/QC_rNORDIC_bold_${run}_dp1.nii
done


#============= tSNR ============#
mkdir ${outputDir}/tSNR

#Average dp1 volume-pairs to get fair comparison (as for DP-corrected which is also average of pairs). 
#We will only have half the timepoints compared to DP-corrected, but should be fine for tSNR - alternatively scale by sqrt(2)?
#3dcalc -prefix tmp_pairAveraged_rNORDIC_bold_01_dp1.nii -a tmp_rNORDIC_bold_01_dp1.nii'[0..$(2)]' -b tmp_rNORDIC_bold_01_dp1.nii'[1..$(2)]' -expr '(a+b)/2'

#Compute tSNR maps:
3dTstat -overwrite -cvarinv -prefix ${outputDir}/tSNR/tSNR_NORDIC_bold_01.nii rNORDIC_bold_01.nii
3dTstat -overwrite -cvarinv -prefix ${outputDir}/tSNR/tSNR_noNORDIC_bold_01.nii rnoNORDIC_bold_01.nii
#3dTstat -overwrite -cvarinv -prefix ${outputDir}/tSNR/tSNR_NORDIC_bold_01_dp1.nii tmp_pairAveraged_rNORDIC_bold_01_dp1.nii



#============= get vaso T1-weighted and align to BOLD ============#
# 3dvolreg -verbose -zpad 2 -base nulled.nii'[0]' \
#     -prefix rnulled.nii -overwrite \
#     -1Dfile ${outputDir}/coregParam/dfile.nulled.1D \
#     -1Dmatrix_save ${outputDir}/coregParam/mat.nulled.vr.aff12.1D \
#     nulled.nii

# 3dvolreg -verbose -zpad 2 -base notNulled.nii'[0]' \
#     -prefix rnotNulled.nii -overwrite \
#     -1Dfile ${outputDir}/coregParam/dfile.notNulled.1D \
#     -1Dmatrix_save ${outputDir}/coregParam/mat.notNulled.vr.aff12.1D \
#     notNulled.nii

#Compute T1-weighted VASO and remove noise outside brain (magnitude average should be fine here, i dont think we need to bother with complex averaging)
#MOCO first (code above) if longer timeseries:
3dtstat -mean -prefix mean_nulled.nii nulled.nii
3dtstat -mean -prefix mean_notNulled.nii notNulled.nii
3dAutomask -dilate 1 -prefix tmp_brain_VASO.nii -overwrite mean_nulled.nii
3dcalc -a mean_nulled.nii -b mean_notNulled.nii -c tmp_brain_VASO.nii -prefix T1_weighted.nii -expr '(a/b)*c'

#Get mean BOLD for registration:
3dtstat -mean -prefix mean_rnoNORDIC_bold_01.nii rnoNORDIC_bold_01.nii

#Now register notNulled to BOLD
antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 1 \
--output [${outputDir}/coregParam/registeredVASO2BOLD_,${outputDir}/coregParam/registeredVASO2BOLD_Warped.nii.gz] \
--interpolation BSpline[5] \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--transform Rigid[0.05] \
--metric MI[mean_rnoNORDIC_bold_01.nii,./mean_notNulled.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform Affine[0.1] \
--metric MI[mean_rnoNORDIC_bold_01.nii,./mean_notNulled.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[0.1,2,0] \
--metric CC[mean_rnoNORDIC_bold_01.nii,./mean_notNulled.nii,1,2] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox

antsApplyTransforms \
--interpolation BSpline[5] \
-d 3 -i ./mean_notNulled.nii \
-r mean_rnoNORDIC_bold_01.nii \
-t ${outputDir}/coregParam/registeredVASO2BOLD_1Warp.nii.gz \
-t ${outputDir}/coregParam/registeredVASO2BOLD_0GenericAffine.mat \
-o ./mean_notNulled_albold.nii

antsApplyTransforms \
--interpolation BSpline[5] \
-d 3 -i ./T1_weighted.nii \
-r mean_rnoNORDIC_bold_01.nii \
-t ${outputDir}/coregParam/registeredVASO2BOLD_1Warp.nii.gz \
-t ${outputDir}/coregParam/registeredVASO2BOLD_0GenericAffine.mat \
-o ./T1_weighted_albold.nii


## ==================== Coregister MP2RAGE to EPI (ANTS) =================#
mkdir ${outputDir}/analysis
#Denoise T1
3dSkullStrip -orig_vol -prefix tmp_MP2RAGE_INV2_ns.nii -overwrite -input MP2RAGE_INV2.nii
3dAutomask -dilate 1 -prefix tmp_T1mask.nii -overwrite tmp_MP2RAGE_INV2_ns.nii
3dcalc -a tmp_T1mask.nii -b MP2RAGE_UNI.nii -expr 'a*b' -prefix T1_bold.nii -overwrite

# mv ${outputDir}/tmp_*.nii ${HOME}/Desktop/trash
# mv ${outputDir}/tmp_*.1D ${HOME}/Desktop/trash

antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 1 \
--output [${outputDir}/coregParam/registered_,${outputDir}/coregParam/registered_Warped.nii.gz] \
--interpolation BSpline[5] \
--use-histogram-matching 0 \
--initial-moving-transform ${outputDir}/initial_matrix.txt \
--winsorize-image-intensities [0.005,0.995] \
--transform Rigid[0.05] \
--metric MI[T1_weighted_albold.nii,T1_bold.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform Affine[0.1] \
--metric MI[T1_weighted_albold.nii,T1_bold.nii,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[0.1,2,0] \
--metric CC[./T1_weighted_albold.nii,T1_bold.nii,1,2] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox


#Apply the transforms and reslice:
antsApplyTransforms \
--interpolation BSpline[5] \
-d 3 -i T1_bold.nii \
-r ./T1_weighted_albold.nii \
-t ${outputDir}/coregParam/registered_1Warp.nii.gz \
-t ${outputDir}/coregParam/registered_0GenericAffine.mat \
-o ./analysis/T1_bold_al.nii


## ==================== Smooth iso =================#
for NORDvers in "NORDIC" "noNORDIC"; do
for run in ${runs[@]} ; do
3dmerge -1blur_fwhm 1 -doall -prefix sr${NORDvers}_bold_${run}.nii -overwrite r${NORDvers}_bold_${run}.nii
done
done


## ==================== scale =================#
for NORDvers in "NORDIC" "noNORDIC" ; do
for run in ${runs[@]} ; do
    3dTstat -prefix tmp_mean_r${NORDvers}_bold_${run}.nii -overwrite \
        -mean r${NORDvers}_bold_${run}.nii

    3dTstat -prefix tmp_mean_sr${NORDvers}_bold_${run}.nii -overwrite \
        -mean sr${NORDvers}_bold_${run}.nii

    3dcalc -a r${NORDvers}_bold_${run}.nii -b tmp_mean_r${NORDvers}_bold_${run}.nii \
        -expr 'min(200, a/b*100)*step(a)*step(b)' \
        -prefix tmp_scaled_r${NORDvers}_bold_${run}.nii -overwrite

    3dcalc -a sr${NORDvers}_bold_${run}.nii -b tmp_mean_sr${NORDvers}_bold_${run}.nii \
        -expr 'min(200, a/b*100)*step(a)*step(b)' \
        -prefix tmp_scaled_sr${NORDvers}_bold_${run}.nii -overwrite
done
done


## ==================== GLM =================#
TR=6 #Effective TR after averaging polarities
for NORDvers in "NORDIC" "noNORDIC" ; do
    3dDeconvolve -force_TR ${TR} \
     -input tmp_scaled_r${NORDvers}_bold_01.nii   \
     -polort 'A' \
     -TR_times ${TR} \
     -local_times \
     -num_stimts 2 \
     -stim_times 1 ${rootDir}/right_bold.txt 'UBLOCK(30,1)' \
     -stim_label 1 right \
     -stim_times 2 ${rootDir}/left_bold.txt 'UBLOCK(30,1)' \
     -stim_label 2 left \
     -gltsym 'SYM: right -left' \
     -glt_label 1 right-left \
     -jobs 2 \
     -tout -xjpeg bold.png \
     -bucket stats_bold_${NORDvers}.nii \
     -overwrite

    3dDeconvolve -force_TR ${TR} \
     -input tmp_scaled_sr${NORDvers}_bold_01.nii   \
     -polort 'A' \
     -TR_times ${TR} \
     -local_times \
     -num_stimts 2 \
     -stim_times 1 ${rootDir}/right_bold.txt 'UBLOCK(30,1)' \
     -stim_label 1 right \
     -stim_times 2 ${rootDir}/left_bold.txt 'UBLOCK(30,1)' \
     -stim_label 2 left \
     -gltsym 'SYM: right -left' \
     -glt_label 1 right-left \
     -jobs 2 \
     -tout -xjpeg bold.png \
     -bucket stats_bold_${NORDvers}_smooth.nii \
     -overwrite
done


# mv ${outputDir}/stats*.1D ${HOME}/Desktop/trash
# mv ${outputDir}/stats*_cmd ${HOME}/Desktop/trash
# mv ${outputDir}/tmp_*.nii ${HOME}/Desktop/trash
