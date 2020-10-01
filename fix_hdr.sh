#!/bin/bash


for filename in `ls *.nii`; do
	echo ${filename}
	3drefit -TR 8.9640 ${filename}
	3drefit -zdel 0.8 ${filename}
	3drefit -denote ${filename}
done
