#!/bin/bash


echo "fange an"

3dTstat -overwrite -mean -prefix odd_mean_$1 $1'[4..$(2)]'\n
3dTstat -overwrite -mean -prefix eve_mean_$1 $1'[3..$(2)]'\n
3dTstat -overwrite -tSNR -prefix odd_tSNR_$1 $1'[4..$(2)]'\n
3dTstat -overwrite -tSNR -prefix eve_tSNR_$1 $1'[3..$(2)]'\n

3dcalc -a odd_mean_$1 -b eve_mean_$1 -prefix diff_$1 -expr '2*(a-b)/(a+b)' -overwrite


echo "und tschuess"

 
