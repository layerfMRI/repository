#!/bin/bash

#Felix run me with: sbatch --mem=100g --cpus-per-task=50 --time=14400:00  executed.sh

fslmaths $1 -mul 2000 short_$1 -odt short