#!/bin/bash


fslmaths $1 -s $2 smoothed_$1

echo "expecting: fslmaths arg_1 -s arg_2 smoothed_arg_1"