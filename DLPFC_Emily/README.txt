Scripts used in the analysis of the paper published as: Finn, E. S., Huber, L., Jangraw, D. C. & Bandettini, P. A. Layer-dependent activity in human prefrontal cortex during working memory. bioRxiv 425249 (2018). doi:10.1101/425249

Please see supplementary material for the working principle and the reasoning and the overview of the entire pipeline (Fig. S2)

1.) Script to convert VASO dicoms to nii despite TR inconsistencies in VASO: https://github.com/layerfMRI/repository/blob/master/moco/conv_nih.sh
This script searches for all dicom images in a folder and subfolders therein and groups them in nii-timeseries based on the header info in the dicoms. This script depends on ISIS-CONV (https://layerfmri.com/2018/11/29/installing-isisconv/). The output of this script are nii-timeseries sorted with this name-convention S1*.nii S2*.nii S3*.nii….

2.) Script to run motion correction across all functional runs as the same step as the registration across runs:
2a) This wrapper collects all time series in a folder that have a file name starting with “S”. The first 2 TRs are overwritten to account for non-steady-state effects. This script also duplicated every file to apply the motion correction on BOLD and VASO images separately. This script also plots the motion traces for BOLD and VASO on top of each other (for visual inspection) with gnuplot. The script prepares all runs to apply the motion correction in a concatenated way. This script also opens matlab to run the motion correction in SPM.  https://github.com/layerfMRI/repository/blob/master/moco/start_moco_flex.sh
2b) The actual SPM-matlab script that does the motion estimation and alignment. It is optimized for sub-millimeter data. The motion estimation is doen in a locally defined region given in moma.nii  https://github.com/layerfMRI/repository/blob/master/moco/mocobatch_VASO_flex.m
The output of this script are motion corrected time series for all runs and both contrasts BOLD and VASO in separate files: Nulled_Basis*.nii and NotNulled_Basis*.nii

3) This script to runs the separation of BOLD and VASO within the mean runs:
As input is expects the run-averages in the naming convention: Nulled_Basis*.nii and NotNulled_Basis*.nii
https://github.com/layerfMRI/repository/blob/master/afni_VASO_flex.sh
The output of this stript are multiple measures of signal quality for manual inspection (tSNR, kurtosis maps for ghost detection. T1-EPI for anatomical alignment etc.). The output is also a clean BOLD time series and a clean VASO time series without interleave contrast changes across time.

4.) The stimulus task blocks in FSL_Feat design are given below (GLM results are not used in the Paper, but trial sorting is exemplary shown in gray-red in Fig. S2): 
Note that for this step the nii header information for TR must be correct. Here it was manually overwritten with “3dRefit -TR 2”  https://github.com/layerfMRI/repository/tree/master/DLPFC_Emily/Featdesign
This script was not used to produce layer results in Figs.  2-4, S4. Instead, this was used for manual inspection and to investigate the consistency of activity hotspots across participants and across sessions. (Figs. 1c, S4, and S5). 
The important output of the Feat analysis was the z-score maps in ?*.feat/stats/zstat*.nii

5.)  Script to extract trial blocks with the same task condition and average them respectively for the alphabetization runs. Input are run-averages of BOLD and VASO for the two task runs: In the naming convention: E.g. MEAN_BOLD_A.nii (BOLD during alphabetization runs), MEAN_VASO_G.nii (VASO during response-manipulation runs) https://github.com/layerfMRI/repository/blob/master/DLPFC_Emily/sort_trials_A.sh 

6.) Script to extract trial blocks with the same task condition and average them respectively for the alphabetization runs: https://github.com/layerfMRI/repository/blob/master/DLPFC_Emily/sort_trials_G.sh
The output of the script are all task conditions in all runs for all contrasts in the following naming convention: {contrast}_{condition}.nii
Contrast: BOLD, VASO
Period: go, nogo, alpha, rem 

7.) Script to average the signal across voxels within layers and extract time courses for the axial protocols (with two layers). The input of the script are the run and contrast averaged form step 5-6 in the same naming convention. This script also uses the layer masks in the naming convention upper_layer.nii and lower_layer.nii, respectively.  https://github.com/layerfMRI/repository/blob/master/DLPFC_Emily/get_time_courses.sh
The output of the scripts are time courses in seperate *.dat files for every task, layer, and condition in the same naming convention:
Naming convention: {contrast}_{condition}_{layer}.dat
Contrast: BOLD, VASO
Period: go, nogo, alpha, rem 
Layer: upper, deeper

8.) LAYNII programs that does the BOLD correction LN_BOCO. This script applied a simple division of images with and without blood-nulling. The input are time series of MRI signal with and without blood nulling.
https://github.com/layerfMRI/LAYNII/blob/master/LN_BOCO.cpp
The output is a BOLD corrected VASO time series. 

9.)  Script to generate a voxel grid that has a finder resolution to allow 21 layer to be generated in sagittal protocol. The input is any nifty image with a native resolution.  https://github.com/layerfMRI/repository/blob/master/DLPFC_Emily/Up_sample_2d.sh
The output is an upscaled version of the input file. Upscaled with a factor of 4. On the chois of the number, please see https://layerfmri.com/2019/02/22/how-many-layers-should-i-reconstruct/
The naming convention of the output is: scaled_{inputfilename}.

10.) Program to generate layers from manually drawn segmentation borders: The input is a manually drawn rim as a nii file.  https://github.com/layerfMRI/LAYNII/blob/master/LN_GROW_LAYERS.cpp
The output is a nii file where every voxel in the upscaled space has an integer value assigned corresponding to one out of 21 layers. For more information on how this algorithm works and on the value convention of the rim file see: https://layerfmri.com/2018/03/11/quick-way-of-getting-layer-fmri-profiles-from-epi-data/

11.) Program to do layer smoothing:
The input is the layer nii-file from step 10.) and the upscaled activation map from step 9.) https://github.com/layerfMRI/LAYNII/blob/master/LN_LAYER_SMOOTH.cpp
The output is a layer-smoothed activation map. For more information see https://layerfmri.com/2018/03/15/smoothing-within-layers/ 

12.) Script to align multiple runs of 0.5mm MP2RAGE data for the supplementary figure: The input are three 0.5mm MP2RAGE datasets with the naming convention: s1.nii, ref.nii, s3.nii. And a manually drawn mask (mask.nii) that excludes the skull and the skin. https://github.com/layerfMRI/repository/blob/master/Alignement_scripts/align_multiple_MP2RAGE_0.5/executed_command.sh
The output is a mean image of the three aligned MP2RAGE images. For more information see also https://layerfmri.com/2019/02/11/high-quality-registration/

13.) Script to align EPI to 0.5mm MP2RAGE data in supplementary figure: 
The input are the T1-EPI from step 3.) and the mean MP2RAGE from step 12.). The input naming convention is: EPI_T1.nii for the EPI in upscaled space and ANAT.nii for the mean MP2RAGE image.  https://github.com/layerfMRI/repository/blob/master/Alignement_scripts/align_0.5mm_MP2RAGE_2_EPI/executed_command.sh
The output is a warped MP2RAGE image in upscaled EPI space with the name egistered1_Warped.nii. For more information see also https://layerfmri.com/2019/02/11/high-quality-registration/

14.) Script to plot layer profiles of sagittal experiments: 
The input is the layer nii file from step 10.) and the upscaled unsmoothed activation map in EPI space. The layer file is expected to be called layers.nii, the activation file name needs to be specified. 
https://github.com/layerfMRI/repository/blob/master/afni_LayerMe.sh
The output is an ASCII file with three columns:
1st column: mean activation strengths in per layer
2nd column: standard deviation of the activation strength per layer
3rd column: number of upscaled voxels in each layer. 

15.) Gnuplot script to plot layer profiles:
The input file is the ASCII file from step 14.).
https://github.com/layerfMRI/repository/blob/master/gnuplot_templates/gnuplot_profile_plot.txt
The output is a vector graphic of the layer profile in *.ps format
