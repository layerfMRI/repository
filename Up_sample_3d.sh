#!/bin/bash



echo "fange an"

delta_x=$(3dinfo -di $1)
delta_y=$(3dinfo -dj $1)
delta_z=$(3dinfo -dk $1)

sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / 4))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / 4))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 4))"|bc -l)

echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"

3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix scaled_$1 -input $1 
#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode NN -overwrite -prefix scaled_$1 -input $1

3dcalc -a scaled_$1 -datum short -gscale -expr 'a' -prefix scaled_$1 -overwrite
 

echo "und tschuess"

 
