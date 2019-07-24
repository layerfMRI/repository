#!/bin/bash


3dCalc -a $1 -prefix inv_$1 -overwrite -expr '-1*a'

echo "expecting: 3dCalc -a $1 -prefix inv_$1 -overwrite -expr '-a' "
