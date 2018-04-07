#!/bin/bash

#on felix run me with: sbatch --mem=100g --cpus-per-task=50 --time=14400:00  anatomical_master_felix.sh

module load ANTs




echo "I expect 2 filed. the T1_weighted EPI.nii and a MP2RAGE_orig.nii"

#  bet MP2RAGE_orig.nii MP2RAGE.nii -f 0.05
  3dcalc -a MP2RAGE.nii -datum short -expr 'a' -prefix MP2RAGE.nii -overwrite

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=50
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

echo "*****************************************************************"
echo "************* starting with ANTS ************************************"
echo "*****************************************************************"
#2 steps
antsRegistration \
--verbose 1  \
--dimensionality 3  \
--float 1  \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz]   \
--interpolation BSpline[5]  \
--use-histogram-matching 0   \
--winsorize-image-intensities [0.005,0.995]   \
--initial-moving-transform initial_matrix.txt    \
--transform Rigid[0.05]   \
--metric CC[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1]   \
--convergence [1000x500,1e-6,10]   \
--shrink-factors 2x1   \
--smoothing-sigmas 1x0vox   \
--transform Affine[0.1]   \
--metric MI[EPI.nii,MP2RAGE.nii,0.7,32,Regular,0.1]   \
--convergence [1000x500,1e-6,10]   \
--shrink-factors 2x1   \
--smoothing-sigmas 1x0vox   \
--transform SyN[0.1,2,0]   \
--metric CC[EPI.nii,MP2RAGE.nii,1,2]   \
--convergence [500x100,1e-6,10]   \
--shrink-factors 2x1   \
--smoothing-sigmas 1x0vox

#antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
antsApplyTransforms -d 3 -i MP2RAGE.nii -o warped_MP2RAGE.nii -r MP2RAGE.nii -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat

3dcalc -a warped_MP2RAGE.nii -datum short -expr 'a' -prefix warped_MP2RAGE.nii -overwrite


echo "*****************************************************************"
echo "************* starting with FREE surfer *************************"
echo "*****************************************************************"

module load freesurfer
#export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

pfad=$(pwd)
export SUBJECTS_DIR=$pfad

recon-all -s subject_name -hires  -i warped_MP2RAGE.nii  -all -parallel -openmp 6 

echo "*****************************************************************"
echo "************* doing AFNI surfaces  ******************************"
echo "*****************************************************************"


cd subject_name
@SUMA_Make_Spec_FS -sid subject_name -NIFTI
cd SUMA 

cp ../../EPI.nii ./
cp ../../warped_MP2RAGE.nii ./

echo "************* upscaling EPI.nii    ******************************"
module load afni

delta_x=$(3dinfo -di EPI.nii)
delta_y=$(3dinfo -dj EPI.nii)
delta_z=$(3dinfo -dk EPI.nii)

sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
sdelta_z=$(echo "(($delta_z / 4))"|bc -l)

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix scaled_EPI.nii -input EPI.nii



#get obliquity matrix
3dWarp -card2oblique EPI.nii -verb warped_MP2RAGE.nii -overwrite > orinentfile.txt

echo  "dense mesh starting"

#get dense mesh
MapIcosahedron -spec subject_name_lh.spec -ld 564 -prefix std_lh.ld564. -overwrite
MapIcosahedron -spec subject_name_rh.spec -ld 564 -prefix std_rh.ld564. -overwrite

echo "************************ get surfaces in oblique orientation left"
ConvertSurface -xmat_1D orinentfile.txt -i std_lh.ld564.lh.pial.gii -o std_lh.ld564.lh.pial.obl.gii -overwrite
ConvertSurface -xmat_1D orinentfile.txt -i std_lh.ld564.lh.smoothwm.gii -o std_lh.ld564.lh.smoothwm.obl.gii -overwrite

#get spec for the new file
quickspec -tn gii std_lh.ld564.lh.pial.obl.gii
mv quick.spec std_lh.ld564.lh.pial.obl.spec
quickspec -tn gii std_lh.ld564.lh.smoothwm.obl.gii 
mv quick.spec std_lh.ld564.lh.smoothwm.obl.spec
inspec -LRmerge std_lh.ld564.lh.smoothwm.obl.spec  std_lh.ld564.lh.pial.obl.spec -detail 2 -prefix std_BOTH.ld564.lh.orient.spec -overwrite 

echo  " **************************" 
echo  " get binary mask of surface left" 
echo  " **************************" 
3dSurf2Vol -spec std_lh.ld564.lh.pial.obl.spec -surf_A std_lh.ld564.lh.pial.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.obl.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -map_func mask -gridset scaled_EPI.nii  -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite

# is fill should be bigger
#3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite


echo  " **************************"  
echo  " *******DONE WITH LEFT HEMISHPERE" 
echo  " **************************" 

echo "************************ get surfaces in oblique orientation left"
ConvertSurface -xmat_1D orinentfile.txt -i std_rh.ld564.rh.pial.gii -o std_rh.ld564.rh.pial.obl.gii -overwrite
ConvertSurface -xmat_1D orinentfile.txt -i std_rh.ld564.rh.smoothwm.gii -o std_rh.ld564.rh.smoothwm.obl.gii -overwrite

#get spec for the new file
quickspec -tn gii std_rh.ld564.rh.pial.obl.gii
mv quick.spec std_rh.ld564.rh.pial.obl.spec
quickspec -tn gii std_rh.ld564.rh.smoothwm.obl.gii 
mv quick.spec std_rh.ld564.rh.smoothwm.obl.spec
inspec -LRmerge std_rh.ld564.rh.smoothwm.obl.spec  std_rh.ld564.rh.pial.obl.spec -detail 2 -prefix std_BOTH.ld564.rh.orient.spec -overwrite

echo  " **************************" 
echo  " get binary mask of surface right" 
echo  " **************************" 
3dSurf2Vol -spec std_rh.ld564.rh.pial.obl.spec -surf_A std_rh.ld564.rh.pial.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix rh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_rh.ld564.rh.smoothwm.obl.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -map_func mask -gridset scaled_EPI.nii  -prefix rh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -surf_B std_rh.ld564.rh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_rh.nii -overwrite



#3dLocalstat -nbhd 'SPHERE(0.2)' -prefix filled_ribbonmask_564 ribbonmask_564+orig

3dcalc -a ribbonmask_564_rh.nii -b ribbonmask_564_lh.nii -expr 'a + b ' -prefix fill.nii -overwrite 
3dcalc -a lh.pial.epi_vol.nii -b rh.pial.epi_vol.nii  -expr 'a + b ' -prefix pial_vol.nii -overwrite
3dcalc -a lh.WM.epi_vol.nii   -b rh.WM.epi_vol.nii    -expr 'a + b ' -prefix WM_vol.nii   -overwrite

3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.nii fill.nii 
3dcalc -a  filled_fill.nii -b fill.nii -expr 'step(step(a-0.5)+b)' -overwrite  -prefix filled_fill.nii 

3dcalc -a  filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'step(a-b-c)' -overwrite  -prefix GM_robbon4_manual_corr.nii 

3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'a + b + 2*c ' -prefix rim_auto.nii -overwrite

cp filled_fill.nii ../../
cp pial_vol.nii ../../
cp WM_vol.nii ../../
cp rim_auto.nii ../../
cp scaled_EPI.nii ../../
cp GM_robbon4_manual_corr.nii ../../


echo "und tschuess"

 
