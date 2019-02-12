#!/bin/bash

3dcalc -a column_coordinates_M1.nii -b column_coordinates_S1.nii -expr 'a+step(a)*-3+step(b)*189+b' -prefix column_coordinate_MS.nii -overwrite