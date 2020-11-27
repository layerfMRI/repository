#!/bin/bash

3dcalc -a mean_nulled.nii -b mean_notnulled.nii -expr '(b-a)/(a+b)' -prefix VAPER.nii -overwrite
