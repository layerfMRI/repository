#!/bin/bash



echo "fange an"

delta_x=$(3dinfo -di $1)
delta_y=$(3dinfo -dj $1)
delta_z=$(3dinfo -dk $1)

sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / 3))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / 3))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 3))"|bc -l)

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix scaled_$1 -input $1 
#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode NN -overwrite -prefix scaled_$1 -input $1

3dcalc -a scaled_$1 -datum short -gscale -expr 'a' -prefix scaled_$1 -overwrite

3drefit -atrcopy $1 IJK_TO_DICOM_REAL scaled_$1


#alternative ResampleImage 3 inputImage.nii.gz outputImage.nii.gz  0.25x0.25x0.25 0 3['l'] 6
# Itksapnresample


echo "und tschuess"

 
