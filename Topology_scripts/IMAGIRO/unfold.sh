#!/bin/bash


for file in *BOLD*.nii 
do 
	echo "$file"
	Up_sample_3d.sh $file
	short_me.sh scaled_$file
	LN_IMAGIRO -layer_file layers.nii -column_file column_coordinate_MS.nii -data scaled_$file
done

for file in *VASO*.nii 
do 
	echo "$file"
	Up_sample_3d.sh $file
	short_me.sh scaled_$file
	LN_IMAGIRO -layer_file layers.nii -column_file column_coordinate_MS.nii -data scaled_$file
done

for file in *T1_*.nii 
do 
	echo "$file"
	Up_sample_3d.sh $file
	short_me.sh scaled_$file
	LN_IMAGIRO -layer_file layers.nii -column_file column_coordinate_MS.nii -data scaled_$file
done

for file in *T2star_*.nii 
do 
	echo "$file"
	Up_sample_3d.sh $file
	short_me.sh scaled_$file
	LN_IMAGIRO -layer_file layers.nii -column_file column_coordinate_MS.nii -data scaled_$file
done

echo "und tschuess"


for file in unfolded_scaled_*.nii
do 
	echo "$file"
	LN_DIRECT_SMOOTH -input $file -FWHM 10 -direction 3
done

