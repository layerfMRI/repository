#!/bin/bash

echo "fange an"


NumVol=`3dinfo -nv $1`


echo $NumVol

3dcalc -overwrite -prefix NoNoise_$1  -a $1'[0..'`expr $NumVol - 4`']'  -expr 'a'


#miconv -trange 4-7 -noscale scaled_Phase.nii oneTR_Phase.nii


echo "und tschuess:  expects: phase_eval.sh "

 
