#!/bin/bash


echo "It starts now"

3dLocalstat -stat mode -prefix moded_1 -nbhd 'SPHERE(1)' $1 -overwrite
