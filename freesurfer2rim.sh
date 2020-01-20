#!/bin/bash



export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

pfad=$(pwd)
SUBJECTS_DIR=$pfad

recon-all -s subject_name -i EPI.nii -all -parallel -openmp 6 

echo "*****************************************************************"
echo "************* doing AFNI surfaces  ******************************"
echo "*****************************************************************"


cd subject_name
@SUMA_Make_Spec_FS -sid subject_name -NIFTI



echo "************* upscaling EPI.nii    ******************************"

delta_x=$(3dinfo -di EPI.nii)
delta_y=$(3dinfo -dj EPI.nii)
delta_z=$(3dinfo -dk EPI.nii)

sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / 2))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / 2))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 2))"|bc -l)

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Bk -overwrite -prefix scaled_EPI.nii -input EPI.nii

cd SUMA 
cp ../scaled_EPI.nii ./
cp ../EPI.nii ./

#get obliquity matrix
#3dWarp -card2oblique EPI.nii -verb warped_MP2RAGE.nii -overwrite > orinentfile.txt

echo  "dense mesh starting"

#get dense mesh
MapIcosahedron -spec subject_name_lh.spec -ld 564 -prefix std_lh.ld564. -overwrite
MapIcosahedron -spec subject_name_rh.spec -ld 564 -prefix std_rh.ld564. -overwrite

3dWarp -card2oblique EPI.nii -verb scaled_EPI.nii -overwrite > orinentfile.txt

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
echo  " get binary mask of surface left  This stuff might take a while " 
echo  " **************************" 
3dSurf2Vol -spec std_lh.ld564.lh.pial.obl.spec -surf_A std_lh.ld564.lh.pial.obl.gii -map_func mask -gridset scaled_EPI.nii -prefix lh.pial.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_lh.ld564.lh.smoothwm.obl.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -map_func mask -gridset scaled_EPI.nii  -prefix lh.WM.epi_vol.nii -sv T1.nii -overwrite
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr 0.07 -f_pn_fr -0.05 -prefix ribbonmask_564_lh.nii -overwrite

# is fill should be bigger
#3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite


echo  " **************************"  
echo  " *******DONE WITH LEFT HEMISHPERE" 
echo  " **************************" 

echo "************************ get surfaces in oblique orientation right"
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

#3dLocalstat -nbhd 'SPHERE(0.3)' -stat mean -overwrite -prefix filled_fill.nii fill.nii 
3dcalc -a  filled_fill.nii -b fill.nii -expr 'step(step(a-0.5)+b)' -overwrite  -prefix filled_fill.nii 

3dcalc -a  filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'step(a-b-c)' -overwrite  -prefix GM_robbon4_manual_corr.nii 

3dcalc -a filled_fill.nii -b pial_vol.nii -c WM_vol.nii -expr 'a + b + 2*c ' -prefix rim_auto.nii -overwrite

cp fill.nii ../../
cp filled_fill.nii ../../
cp pial_vol.nii ../../
cp WM_vol.nii ../../
cp rim_auto.nii ../../
cp scaled_EPI.nii ../../
cp GM_robbon4_manual_corr.nii ../../

cd ../../ 
3dcalc -a pial_vol.nii -b WM_vol.nii -c fill.nii -expr 'step(a)+2*step(b)+3*step(c)-3*step(a*c)-3*step(b*c)' -prefix rim.nii -overwrite
 
echo "und tschuess"

 
