module load afni

delta_x=$(3dinfo -di Template.nii)
delta_y=$(3dinfo -dj Template.nii)
delta_z=$(3dinfo -dk Template.nii)

sdelta_x=$(echo "(($delta_x / 2))"|bc -l)
sdelta_y=$(echo "(($delta_x / 2))"|bc -l)
sdelta_z=$(echo "(($delta_z / -2))"|bc -l)

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite  -prefix Template.nii -input Template.nii

