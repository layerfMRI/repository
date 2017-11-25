#!/bin/bash

echo  "starting: I want to be run in the SUMA directory, which sould also contain the EPI.nii file  and the warped_MP2RAFGE file"

#Upsample EPI 
Up_sample.sh EPI.nii


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
3dSurf2Vol -spec std_BOTH.ld564.lh.orient.spec -surf_A std_lh.ld564.lh.smoothwm.obl.gii -surf_B std_lh.ld564.lh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_lh.nii -overwrite

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
3dSurf2Vol -spec std_BOTH.ld564.rh.orient.spec -surf_A std_rh.ld564.rh.smoothwm.obl.gii -surf_B std_rh.ld564.rh.pial.obl.gii -sv T1.nii -gridset scaled_EPI.nii  -map_func mask -f_steps 40 -f_index points -f_p1_fr -0.05 -f_pn_fr 0.05 -prefix ribbonmask_564_rh.nii -overwrite

3dcalc -a lh.pial.epi_vol.nii -b lh.WM.epi_vol.nii -c rh.pial.epi_vol.nii -d rh.WM.epi_vol.nii -expr '2*a + 3* b + 2*c + 3*d' -prefix rim.nii -overwrite
3dcalc -a ribbonmask_564_rh.nii -b ribbonmask_564_lh.nii -expr 'a + b ' -prefix fill.nii -overwrite 

echo  "done"