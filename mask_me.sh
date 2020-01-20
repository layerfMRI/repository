#!/bin/bash

echo "starting"

3dAutomask -prefix mask.nii -peels 3 -dilate 2 -overwrite $1

echo "done"
