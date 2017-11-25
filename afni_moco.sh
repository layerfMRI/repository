#!/bin/bash

3dvolreg -overwrite -prefix "$1"_volreg.nii -base $1'[0]'  -dfile dfile.1D -1Dfile 1Dfile.mot.1D $1'[0..$]'
