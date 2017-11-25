#!/bin/bash

#fslmaths $1 -bptf 16.6666666667 -1  "filtered_$1"


melodic -i $1 --nomask --nobet -d 30

# the -d sets the number of ICAs

# Use this for regression
