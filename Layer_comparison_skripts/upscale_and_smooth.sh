#!/bin/bash



echo "fange an"

NEAREST warped_VASO_no_touch.nii 0 
NEAREST warped_BOLD_no_touch.nii 0 

NEAREST warped_VASO_right.nii 0 
NEAREST warped_BOLD_right.nii 0 

NEAREST warped_VASO_left.nii 0 
NEAREST warped_BOLD_left.nii 0 

NEAREST T1_no_touch.nii 0 

SMinMASK scaledNN_warped_VASO_no_touch.nii equi_dist_layers.nii 60 
SMinMASK scaledNN_warped_BOLD_no_touch.nii equi_dist_layers.nii 60 

SMinMASK scaledNN_warped_VASO_right.nii equi_dist_layers.nii 60 
SMinMASK scaledNN_warped_BOLD_right.nii equi_dist_layers.nii 60 

SMinMASK scaledNN_warped_VASO_left.nii equi_dist_layers.nii 60 
SMinMASK scaledNN_warped_BOLD_left.nii equi_dist_layers.nii 60 


CLEAN_MP2R smoothed_scaledNN_warped_VASO_no_touch.nii equi_dist_layers.nii 0 
CLEAN_MP2R smoothed_scaledNN_warped_BOLD_no_touch.nii equi_dist_layers.nii 0 

CLEAN_MP2R smoothed_scaledNN_warped_VASO_right.nii equi_dist_layers.nii 0 
CLEAN_MP2R smoothed_scaledNN_warped_BOLD_right.nii equi_dist_layers.nii 0 

CLEAN_MP2R smoothed_scaledNN_warped_VASO_left.nii equi_dist_layers.nii  0 
CLEAN_MP2R smoothed_scaledNN_warped_BOLD_left.nii equi_dist_layers.nii  0 

mkdir Muellhalde

mv scaledNN_warped_VASO_no_touch.nii ./Muellhalde/scaledNN_warped_VASO_no_touch.nii
mv scaledNN_warped_BOLD_no_touch.nii ./Muellhalde/scaledNN_warped_BOLD_no_touch.nii
mv scaledNN_warped_VASO_right.nii    ./Muellhalde/scaledNN_warped_VASO_right.nii 
mv scaledNN_warped_BOLD_right.nii ./Muellhalde/scaledNN_warped_BOLD_right.nii
mv scaledNN_warped_VASO_left.nii ./Muellhalde/scaledNN_warped_VASO_left.nii
mv scaledNN_warped_BOLD_left.nii ./Muellhalde/scaledNN_warped_BOLD_left.nii

mv smoothed_scaledNN_warped_VASO_no_touch.nii ./Muellhalde/smoothed_scaledNN_warped_VASO_no_touch.nii
mv smoothed_scaledNN_warped_BOLD_no_touch.nii ./Muellhalde/smoothed_scaledNN_warped_BOLD_no_touch.nii
mv smoothed_scaledNN_warped_VASO_right.nii ./Muellhalde/smoothed_scaledNN_warped_VASO_right.nii
mv smoothed_scaledNN_warped_BOLD_right.nii ./Muellhalde/smoothed_scaledNN_warped_BOLD_right.nii
mv smoothed_scaledNN_warped_VASO_left.nii ./Muellhalde/smoothed_scaledNN_warped_VASO_left.nii
mv smoothed_scaledNN_warped_BOLD_left.nii ./Muellhalde/smoothed_scaledNN_warped_BOLD_left.nii


echo "und tschuess"


