#!/bin/bash


echo "starting with IDEA"
rsync -a  --delete /Volumes/IDEA /Volumes/Backup_IdWM

echo "ANNA Whole Brain"
rsync -a  --delete /Volumes/AnnaWB /Volumes/Backup_IdWM
