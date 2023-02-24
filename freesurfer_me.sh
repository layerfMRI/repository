#!/bin/bash

export FREESURFER_HOME=/Applications/freesurfer/
source $FREESURFER_HOME/SetUpFreeSurfer.sh

pfad=$(pwd)
SUBJECTS_DIR=$pfad


recon-all -s subject_name -i *.nii  -all -parallel -openmp 4 

#recon-all -s subject_name -hires  -i *.nii  -all -parallel -openmp 4 


cd subject_name


echo "und tschuess"


#cd subject_name

#mris_expand -thickness surf/lh.white 0.1 lh.01mid
#mris_expand -thickness surf/lh.white 0.2 lh.02mid
#mris_expand -thickness surf/lh.white 0.3 lh.03mid
#mris_expand -thickness surf/lh.white 0.4 lh.04mid
#mris_expand -thickness surf/lh.white 0.5 lh.05mid
#mris_expand -thickness surf/lh.white 0.6 lh.06mid
#mris_expand -thickness surf/lh.white 0.7 lh.07mid
#mris_expand -thickness surf/lh.white 0.8 lh.08mid
#mris_expand -thickness surf/lh.white 0.9 lh.09mid
#mris_expand -thickness surf/lh.white 1.1 lh.11mid

#mris_expand -thickness surf/rh.white 0.1 rh.01mid
#mris_expand -thickness surf/rh.white 0.2 rh.02mid
#mris_expand -thickness surf/rh.white 0.3 rh.03mid
#mris_expand -thickness surf/rh.white 0.4 rh.04mid
#mris_expand -thickness surf/rh.white 0.5 rh.05mid
#mris_expand -thickness surf/rh.white 0.6 rh.06mid
#mris_expand -thickness surf/rh.white 0.7 rh.07mid
#mris_expand -thickness surf/rh.white 0.8 rh.08mid
#mris_expand -thickness surf/rh.white 0.9 rh.09mid
#mris_expand -thickness surf/rh.white 1.1 rh.11mid

#mris_expand -thickness surf/lh.white -0.1 lh.m01mid
#mris_expand -thickness surf/rh.white -0.1 rh.m01mid

 

freeview -v \
mri/T1.mgz \
mri/wm.mgz \
mri/brainmask.mgz \
-f surf/lh.white:edgecolor=blue \
surf/lh.pial:edgecolor=red \
surf/rh.white:edgecolor=blue \
surf/rh.pial:edgecolor=red

