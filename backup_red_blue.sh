#!/bin/bash


echo "red Berkeley and Kenshu"
rsync -a  --delete /Volumes/Redthin /Volumes/Backup_redb

echo "blue Alejandro"
rsync -a  --delete /Volumes/blue_2 /Volumes/Backup_redb
