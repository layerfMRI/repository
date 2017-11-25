#!/bin/bash

echo "fange an"

3dcalc -prefix "s$1" -a  "$1"'[4..$]'  -expr 'a' -overwrite
3dcalc -prefix "first_$1" -a  "s$1"'[0..3]'  -expr 'a' -overwrite

fslmerge -t $1 "first_$1" "s$1"


rm "s$1"
rm "first_$1"

echo "und tschuess"

 
