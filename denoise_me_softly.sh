#!/bin/bash

DenoiseImage -d 3 -n Rician -i $1 -o denoised_$1

3dMean -prefix softly_denoised_$1 -overwrite denoised_$1 $1
