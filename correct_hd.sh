#!/bin/bash



echo "fange an"


3drefit -xdel 0.79 -ydel 0.79 -zdel 1 -overwrite  $1 

fslmaths $1 -add 0 $1
#3dcalc -a $1 -overwrite -prefix $1 -expr 'a'


echo "und tschuess"

 
