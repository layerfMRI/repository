#!/bin/bash

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=6
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

DenoiseImage -d 4 -n Rician -i $1 -o denoised_$1
