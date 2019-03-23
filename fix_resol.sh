#!/bin/bash

echo "starting"



3drefit -zdel 1.25 -overwrite $1

fslmaths $1 -mul 1 $1 

echo "done"
