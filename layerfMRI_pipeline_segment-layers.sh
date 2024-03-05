# layerfMRI-toolbox - SEGMENTATION AND LAYERS

echo ""
echo ""
echo "    _____________________________________________________________"
echo "                                      _    _   _    ____       __"
echo "        /                           /      /  /|    /    )     / "
echo "    ---/----__----------__---)__--_/__----/| /-|---/___ /-----/--"
echo "      /   /   ) /   / /___) /   ) /      / |/  |  /    |     /     - toolbox is ready to use"
echo "    _/___(___(_(___/_(___ _/_____/______/__/___|_/_____|__ _/_ __"
echo "                  /                                              "
echo "    __________(_ /_______________________________________________"
echo ""
echo ""
echo "    Contributors: "
echo "      - Marco Barilari"
echo "      - Renzo Huber"
echo "      - Daniel Glen"
echo "      - Paul Taylor"
echo "      - Kenshu Koiso"
echo "      - et al. ... if you think your name is missing,"
echo "        please do not hesitate to reach out"
echo ""
echo ""

# This script is a demo of the layerfMRI pipeline for the segmentation and layers for 1 subject only
#generate folder structure and grab all scripts
pfad=$(pwd)
# Create a directory for the YODA file

mkdir -p ${pfad}/code/lib
mkdir -p ${pfad}/code/src
mkdir -p ${pfad}/inputs/raw/sub-01/ses-01/anat
mkdir -p ${pfad}/outputs/derivatives

# clone the layerfMRI-toolbox
git clone --recursive https://github.com/marcobarilari/layerfMRI-toolbox.git ${pfad}/code/lib/layerfMRI-toolbox

echo ""
echo " *** ready to use the YODA ${pfad} folder is"

## Set up the YODA folder path
export root_dir=${pfad}

## Select subjet and session

subID="01"
sesID="01"
modality="anat"


## Set up the paths

raw_dir=${root_dir}/inputs/raw
derivatives_dir=${root_dir}/outputs/derivatives
code_dir=${root_dir}/code
export layerfMRI_toolbox_dir=${code_dir}/lib/layerfMRI-toolbox
export layerfMRI_logfiles_dir=${derivatives_dir}/layerfMRI-logfiles/sub-${subID}
layerfMRI_fs_segmentation_dir=${derivatives_dir}/layerfMRI-segmentation
layerfMRI_mesh_dir=${derivatives_dir}/layerfMRI-surface-mesh
layerfMRI_layers_dir=${derivatives_dir}/layerfMRI-layers

cp ./UNI.nii $raw_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_UNIT1.nii
cp ./INV2.nii $raw_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_INV2.nii


## Configure the layerfMRI pipeline 
#source ${code_dir}/lib/layerfMRI-toolbox/config_layerfMRI_pipeline.sh 

export FREESURFER_HOME=/Applications/freesurfer/ #monster
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# matlab
matlabpath=/Applications/MATLAB_R2023a.app/bin/matlab

find $layerfMRI_toolbox_dir/src -name '*.sh' -exec chmod u+x {} \;

# add the toolbox to the path
export PATH=$PATH:$layerfMRI_toolbox_dir
export PATH=$PATH:$(find $layerfMRI_toolbox_dir/src -maxdepth 1 -type d | paste -sd ":" -)


## Get raw data (bidslike files)

mkdir -p $layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat

cp $raw_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_UNIT1.nii $layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat
cp $raw_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_INV2.nii $layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat


## get brain mask with presurfer

UNIT1_image=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_UNIT1.nii
INV2_image=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_INV2.nii


$matlabpath -nodisplay -nosplash -nodesktop \
    -r "INV2='$INV2_image'; \
    addpath(genpath(fullfile('$code_dir', 'lib', 'layerfMRI-toolbox', 'src'))); \
    run_presurfer_brainmask(INV2); \
    exit"


## Run SPM12 bias field correction via presurfer

UNIT1_image=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat/sub-${subID}_UNIT1.nii

$matlabpath -nodisplay -nosplash -nodesktop \
    -r "UNIT1='$UNIT1_image'; \
    addpath(genpath(fullfile('$code_dir', 'lib', 'layerfMRI-toolbox', 'src'))); \
    run_presurfer_biasfieldcorr(UNIT1); \
    exit"

# ## Run freesurfer recon-all 
# #  !!! this will take at least 5h on crunch machines

anat_image=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat/presurf_biascorrect/sub-${subID}_UNIT1_biascorrected.nii
anat_mask=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat/presurf_INV2/sub-01_INV2_stripmask.nii
output_dir=$layerfMRI_fs_segmentation_dir/sub-${subID}/ses-${sesID}/anat
openmp=8

# NB: in $output_dir, freesurfer will create a folder called `freesurfer/freesurfer`
# I don't know what is the best naming option atm

run_freesurfer_recon_all.sh \
    $anat_image \
    $layerfMRI_fs_segmentation_dir/sub-${subID}/freesurfer \
    $openmp \
    $anat_mask

## Run suma reconstruction 

fs_surf_path=$layerfMRI_fs_segmentation_dir/sub-${subID}/freesurfer/freesurfer/surf
suma_output_dir=$layerfMRI_mesh_dir/sub-${subID}

run_suma_fs_to_surface.sh \
    $fs_surf_path \
    $suma_output_dir \
    sub-$subID 


## Resample anatomical
#  The image will used as a reference for the resampling of the surface 
#  images

image_to_resample=$suma_output_dir/SUMA/T1.nii.gz
output_dir=$suma_output_dir
output_filename=sub-${subID}_UNIT1_biascorrected_fromFS.nii.gz
resample_iso_factor=3

resample_afni_image_iso_factor.sh \
    $image_to_resample \
    $output_dir \
    $output_filename \
    $resample_iso_factor

## Upsample the surface image 
#  !!! with `linDepth=2000` this will take long time (up to 4h) and a hog memory (up 40 GB) *per hemisphere*
#  !!! to make the process faster you can run the two hemispheres in parallel in separate terminals
#  !!! if in linux, consider increasesing the swap memory.

suma_dir=$layerfMRI_mesh_dir/sub-${subID}/SUMA
upsampled_anat=$suma_dir/sub-${subID}_ses-${sesID}_res-r0p25_UNIT1_MPRAGEised_biascorrected_fromFS.nii.gz

# Number of edge divides for linear icosahedron tesselation 
# the higher the number, the longer the computation
# Suggested values: 2000 for high resolution, 100 for debugging
linDepth=2000

hemisphere="lh"

upsample_suma_surface.sh \
    $suma_dir \
    $upsampled_anat \
    $subID \
    $linDepth \
    $hemisphere

hemisphere="rh"

upsample_suma_surface.sh \
    $suma_dir \
    $upsampled_anat \
    $subID \
    $linDepth \
    $hemisphere

## Convert segmentated tissue from surface to volume maks

suma_dir=$layerfMRI_mesh_dir/sub-${subID}/SUMA
upsampled_anat=$layerfMRI_mesh_dir/sub-${subID}/sub-${subID}_UNIT1_biascorrected_fromFS.nii.gz
output_dir=$layerfMRI_layers_dir/sub-${subID}

# Number of edge divides for linear icosahedron tesselation 
# the higher the number, the longer the computation
# Suggested values: 2000 for high resolution, 100 for debugging
# linDepth=100 

hemisphere="lh"

convert_afni_surface_to_volume_tissue_mask.sh \
    $suma_dir \
    $output_dir \
    $upsampled_anat \
    $subID \
    $linDepth \
    $hemisphere

hemisphere="rh"

convert_afni_surface_to_volume_tissue_mask.sh \
    $suma_dir \
    $output_dir \
    $upsampled_anat \
    $subID \
    $linDepth \
    $hemisphere

## Make the RIM to be inspected and manually edited if necessary
#  the outout is rim012.nii.gz to be visually inspected and manually edited if necessary
#  You might cosnider to first align it to EPI space and then manually edit it
#  and then make the final rim and make layers in the next steps

rim_layer_dir=$layerfMRI_layers_dir/sub-${subID}
rim_filename=rim012.nii.gz
# linDepth=100 

make_afni_GM_WM_rim.sh \
    $rim_layer_dir \
    $rim_filename \
    $linDepth

################################################################
#      VISUAL INSPECTION AND MANUAL EDITING IF NECESSARY       #
################################################################

## Move images to  EPI distorted space

# Move anatomical to EPI space

#image_to_warp=$layerfMRI_fs_segmentation_dir/sub-${subID}/anat/presurf_MPRAGEise/presurf_biascorrect/sub-${subID}_ses-${sesID}_acq-r0p75_UNIT1_MPRAGEised_biascorrected.nii
#epi_image=$raw_dir /sub-${subID}/anat/sub-${subID}_ses-02_space-epi_T1w.nii.gz
#mask_image=$raw_dir/sub-SC08/ses-02/roi/sub-SC08_bubble_rMT.nii.gz
#output_dir=$layerfMRI_layers_dir/sub-${subID}
#output_prefix=ANTs
#output_filename=sub-${subID}_space-EPI_UNIT1.nii.gz

#export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4

#coreg_ants_anat_to_epi.sh \
#    $image_to_warp \
#    $epi_image \
#    $mask_image \
#    $output_dir \
#    $output_prefix

# Upsample the T1w image extracted from vaso

#image_to_resample==$raw_dir/sub-${subID}/anat/sub-${subID}_ses-02_space-epi_T1w.nii.gz
#output_dir=$layerfMRI_layers_dir/sub-${subID}
#output_filename=sub-${subID}_ses-02_space-epi_res-0p25_T1w.nii.gz
#resample_iso_factor=3

#resample_ants_image_iso_factor.sh \
#    $image_to_resample \
#    $output_dir \
#    $output_filename \
#    $resample_iso_factor

# Move mask/rim to EPI space
# Move rim012 to epi space for manual editing and then reacting final rim and layers

#mask_to_warp=$layerfMRI_layers_dir/sub-${subID}/rim012.nii.gz
#epi_image_upsampled=$layerfMRI_layers_dir/sub-${subID}/sub-${subID}_ses-02_space-epi_res-0p25_T1w.nii.gz
#MTxfm=$layerfMRI_layers_dir/sub-${subID}/ANTs_1Warp.nii.gz
#MTgenericAffine=$layerfMRI_layers_dir/sub-${subID}/ANTs_0GenericAffine.mat
#output_dir=$layerfMRI_layers_dir/sub-${subID}/
#output_filename=rim012_space-EPI.nii.gz

#coreg_ants_mask_to_epi.sh \
 #   $mask_to_warp \
 #   $epi_image_upsampled \
 #   $MTxfm \
 #   $MTgenericAffine \
 #   $output_dir \
 #   $output_filename

################################################################
#      VISUAL INSPECTION AND MANUAL EDITING IF NECESSARY       #
################################################################

## Make final RIM with 1 2 3 labels 

input_rim=$layerfMRI_layers_dir/sub-${subID}/rim012.nii.gz
output_dir=$layerfMRI_layers_dir/sub-${subID}
output_filename=rim123.nii.gz


make_afni_laynii_rim123.sh \
    $input_rim \
    $output_dir \
    $output_filename


################################################################
#      VISUAL INSPECTION AND MANUAL EDITING IF NECESSARY       #
################################################################

## Make layers

mask_roi="ROI"
desc="7layers"

nb_layers=7

input_rim123=$layerfMRI_layers_dir/sub-${subID}/rim123.nii.gz
output_dir=$layerfMRI_layers_dir/sub-${subID}
output_filename=sub-${subID}I"${mask_roi}"_desc-"${desc}".nii.gz

make_laynii_layers.sh \
    $input_rim123 \
    $nb_layers \
    $output_dir \
    $output_filename




