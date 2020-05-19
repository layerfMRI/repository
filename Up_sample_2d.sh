#!/bin/bash



echo "fange an"

delta_x=$(3dinfo -di $1)
delta_y=$(3dinfo -dj $1)
delta_z=$(3dinfo -dk $1)
sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / 5))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / 5))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 1))"|bc -l) 
# here I only upscale in 2 dimensions. 
#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix scaled_$1 -input $1 
3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode NN -overwrite -prefix scaled_$1 -input $1 
#-rmode Li allows smoother resampling

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"


echo "und tschuess"

 
