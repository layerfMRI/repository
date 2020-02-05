#!/bin/bash


echo "starting with Movie_1T"
rsync -a  --delete /Volumes/Movie_1TB /Volumes/HD_backup

echo "starting with 2TB_NIH2019"
rsync -a  --delete /Volumes/2TB_NIH2019 /Volumes/HD_backup


echo "starting with Mixed_500GB"
rsync -a  --delete /Volumes/Mixed_500GB /Volumes/HD_backup


echo "starting with Atlas"
rsync -a  --delete /Volumes/ATLAS_500GB /Volumes/HD_backup
