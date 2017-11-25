#!/bin/bash

echo "fange an"

3dUnifize -prefix UNIFIZED.nii -input $1

#3dcopy Unifized* UNIFIZED.nii
#rm Unifized*

3dSkullStrip -input UNIFIZED.nii -push_to_edge -shrink_fac 0 -prefix SKULL_striped.nii

# if you want to have more removed increase -shrink_fac to  0.01 or 0.005
echo "und tschuess"

 
