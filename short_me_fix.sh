#!/bin/bash

echo "starting"

3dcalc -a $1 -datum float  -expr 'a' -prefix float_$1 -overwrite
LN_SHORT_ME -input float_$1 -output short_$1
3dcalc -a float_$1 -b short_$1 -expr 'b-a' -prefix difference.nii -overwrite
3dcalc -a short_$1 -b difference.nii -prefix fixed_$1 -expr 'a-b' -overwrite
rm short_$1
rm float_$1
rm difference.nii

echo "done"
