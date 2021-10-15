#!/bin/tcsh 

# VASO patch demonstration using SurfLayers & surface patches.
# Flickering checkerboard example data: see Figure 2A of Huber et al 2020,
# "Layer-dependent functional connectivity methods" Prog. in Neurobiology.
# Thanks to Renzo Huber for providing it. Code below by S. Torrisi July 2021.

# Note: if the act of entering clipping plane mode messes with AFNI+SUMA talking
# for a random surface, jiggle thresholding in AFNI gui and it'll return.

# ----------------------------------------------------------------------
##do some stuff to get images and surfaces more the way i like

#3dAutobox -npad 10 -prefix bico_out_abox.nii bico_output.nii
#
##dense but not too dense. this is partly an aesthetic decision to minimize "sawtooth" 
##edges, but is more about RAM and ease of manipulation during suma -onestate:
#cd SUMA
#MapIcosahedron -spec subject_name_lh.spec -ld 350 -prefix std_lh.ld350. -overwrite
#MapIcosahedron -spec subject_name_rh.spec -ld 350 -prefix std_rh.ld350. -overwrite
#
## (and then i drew the calcarine ROI following instructions in the first half of:
##     https://youtu.be/5KrIDiN022k
## but saved the output as a .1D file. Then I ran:
#
#SurfPatch -spec std_lh.ld350.subject_name_lh.spec -surf_A std.141.lh.smoothwm.gii \
#       -surf_B std.141.lh.pial.gii -input vasoLcalc.roi.1D.roi 0 -1 -node_depth 2 \
#       -patch2surf -fix_bowtie -overwrite
#
## Finally, I ran SurfLayers w/ resulting SurfPatch_A.gii and SurfPatch_B.gii boundary
## surfaces which created the surflayers/ directory:
#SurfLayers -surf_A SurfPatch_A.gii -surf_B SurfPatch_B.gii -n_intermed_surfs 25

# ----------------------------------------------------------------------
# now get to visualizing in both AFNI and SUMA.
# locations for volumetric and surface data: 

set topdir    = ${PWD}
set dir_afni  = /Users/torrisi/Downloads/VASO_SL_example
set dir_suma  = ${dir_afni}/SUMA/surflayers
# ----------------------------------------------------------------------
# check that everything is in place

set DEP_FAIL  = 0
set all_progs = (quickspecSL SurfLayers) 
set all_dirs  = ( ${dir_afni} ${dir_suma} )

foreach prog ( ${all_progs} )
    set aa = `which ${prog}`
    if ( $status ) then
        set DEP_FAIL = 1
        echo "** ERROR: Cannot find program: ${prog}"
    endif
end

foreach dir ( ${all_dirs} )
    if ( ! -d ${dir} ) then
        set DEP_FAIL = 1
        echo "** ERROR: Cannot find data dir: ${dir}"
    endif
end

if ( ${DEP_FAIL} ) then
    exit 1
endif

# -------------------------------------------------------------------
# just set some background/default behavior.

setenv AFNI_NOSPLASH                   YES
setenv AFNI_SPLASH_MELT                NO
setenv AFNI_NEVER_SAY_GOODBYE          YES
setenv AFNI_STARTUP_WARNINGS           NO
setenv AFNI_ENVIRON_WARNINGS           NO
setenv AFNI_MOTD_CHECK                 NO
setenv AFNI_ONE_OBLIQUE_WARNING        YES
setenv AFNI_CROP_AUTOCENTER            YES
setenv AFNI_CROP_ZOOMSAVE              YES
setenv AFNI_IMAGE_ZOOM_NN              YES
setenv AFNI_LEFT_IS_LEFT               NO        # to match paper figure
setenv SUMA_ConvColorMap               ngray20
setenv AFNI_SUMA_LINECOLOR_FORCE_001   rbgyr20_01
setenv AFNI_SUMA_LINECOLOR_FORCE_002   rbgyr20_02
setenv AFNI_SUMA_LINECOLOR_FORCE_003   rbgyr20_02
setenv AFNI_SUMA_LINECOLOR_FORCE_004   rbgyr20_03
setenv AFNI_SUMA_LINECOLOR_FORCE_005   rbgyr20_03
setenv AFNI_SUMA_LINECOLOR_FORCE_006   rbgyr20_04
setenv AFNI_SUMA_LINECOLOR_FORCE_007   rbgyr20_05
setenv AFNI_SUMA_LINECOLOR_FORCE_008   rbgyr20_06
setenv AFNI_SUMA_LINECOLOR_FORCE_009   rbgyr20_07
setenv AFNI_SUMA_LINECOLOR_FORCE_010   rbgyr20_08
setenv AFNI_SUMA_LINECOLOR_FORCE_011   rbgyr20_09
setenv AFNI_SUMA_LINECOLOR_FORCE_012   rbgyr20_11
setenv AFNI_SUMA_LINECOLOR_FORCE_013   rbgyr20_12
setenv AFNI_SUMA_LINECOLOR_FORCE_014   rbgyr20_13
setenv AFNI_SUMA_LINECOLOR_FORCE_015   rbgyr20_14
setenv AFNI_SUMA_LINECOLOR_FORCE_016   rbgyr20_15
setenv AFNI_SUMA_LINECOLOR_FORCE_017   rbgyr20_16
setenv AFNI_SUMA_LINECOLOR_FORCE_018   rbgyr20_16
setenv AFNI_SUMA_LINECOLOR_FORCE_019   rbgyr20_17
setenv AFNI_SUMA_LINECOLOR_FORCE_020   rbgyr20_17
setenv AFNI_SUMA_LINECOLOR_FORCE_021   rbgyr20_18
setenv AFNI_SUMA_LINECOLOR_FORCE_022   rbgyr20_18
setenv AFNI_SUMA_LINECOLOR_FORCE_023   rbgyr20_19
setenv AFNI_SUMA_LINECOLOR_FORCE_024   rbgyr20_19
setenv AFNI_SUMA_LINECOLOR_FORCE_025   rbgyr20_20
setenv AFNI_SUMA_LINECOLOR_FORCE_026   rbgyr20_20
setenv AFNI_SUMA_LINECOLOR_FORCE_027   red

# -------------------------------------------------------------------
# start afni

cd ${dir_afni}

afni -q -yesplugouts -niml -com QUIET_PLUGOUTS

#using MPRAGE ulay instead of MEAN_VASO because surfaces are associated with
#the former. i'm working on how we can acceptably display on the latter.
set dset_anat = (bico_out_abox.nii)
set dset_stat = (VASOact.nii)
#set dset_stat = (BOLDact.nii)

# specify subbricks (from their respective dsets) for: ULAY OLAY THR
set subbr  = ( -1 0 0 )

# just some threshold value (these are Z stats?)
set thresh = 3

# adjust some settings to more or less match the paper figure.
# zoom and move xhairs to interior of calcarine sulcus
plugout_drive -echo_edu                                                       \
   -com "SWITCH_UNDERLAY ${dset_anat}"                                        \
   -com "SWITCH_OVERLAY  ${dset_stat}"                                        \
   -com "SET_THRESHNEW A ${thresh}"                                           \
   -com "SEE_OVERLAY +"                                                       \
   -com "SET_PBAR_ALL A.+99 9.0 Spectrum:yellow_to_red"                       \
   -com "SET_XHAIR_GAP -1"                                                    \
   -com "SET_DICOM_XYZ A 11.645 54.283 -50.93"                                \
   -com "OPEN_WINDOW A.axialimage ifrac=1 keypress=m keypress=Z keypress=Z    \
            keypress=Z keypress=XK_Home"                                      \
   -com "OPEN_WINDOW A.sagittalimage ifrac=1 keypress=m keypress=Z keypress=Z \
            keypress=Z keypress=XK_Home"                                      \
   -com "OPEN_WINDOW A.coronalimage ifrac=1 keypress=m keypress=Z keypress=Z  \
            keypress=XK_Home"                                                 \
   -com "SET_SUBBRICKS A ${subbr}"                                            \
   -com "SET_FUNC_RANGE A 9"                                                  \
   -quit

sleep 1

# -------------------------------------------------------------------
# start suma

cd ${dir_suma}

echo "++ open set of drawn boundaries and intermediate surfaces"
suma -onestate                                          \
    -i  SurfPatch_A.gii isurf*.gii SurfPatch_B.gii      \
    -sv ../../${dset_anat} &

sleep 1

DriveSuma                                               \
    -com viewer_cont -viewer_size 700 700               \
    -com viewer_cont -key 'a'                           \
    -com viewer_cont -key 't'

# then crop the afni views a bit more, rotate patch group in suma to match afni axial view,
# enter clipping plane mode and press "-" approx 5x for fine-tuned plane control.
# i added a couple parallel planes to clean up sawtoothiness & adjusted one of 
# them to scroll through the cortex laterally-to-medially.
