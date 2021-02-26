#!/bin/bash

echo "fange an"

miconv -trange 3-159 -noscale $1 "s$1"



miconv -trange 0-2 -noscale "s$1" "first_$1"

fslmerge -t $1 "first_$1" "s$1"

rm "first_$1"
rm "s$1"


echo "und tschuess"

 
