#!/bin/bash


echo "fange an"

3dTstat -overwrite -mean -prefix odd_mean_$1 $1'[4..$(2)]'\n
3dTstat -overwrite -mean -prefix eve_mean_$1 $1'[3..$(2)]'\n
3dTstat -overwrite -tSNR -prefix odd_tSNR_$1 $1'[4..$(2)]'\n
3dTstat -overwrite -tSNR -prefix eve_tSNR_$1 $1'[3..$(2)]'\n
3dcalc -a odd_mean_$1 -b eve_mean_$1 -prefix diff_$1 -expr '2*abs((a-b)/(a+b))' -overwrite
3dcalc -prefix mean_$1 -b eve_mean_$1 -a odd_mean_$1 -expr '(a+b)/2' -overwrite
3dcalc -a odd_mean_$1 -b eve_mean_$1 -prefix diff1_$1 -expr '2*(a-b)/(a+b)' -overwrite
3dcalc -a diff1_$1 -b mean_$1 -prefix ugly_$1 -expr 'b*(1+1.4*a)' -overwrite
3dMean -prefix tSNRmean_$1 -overwrite odd_tSNR_$1 eve_tSNR_$1

echo "done"

 
