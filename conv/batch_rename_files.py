#!/bin/env python
import os
import sys
import shutil
from pathlib import Path

current_directory = Path("/home/sriranga/Downloads/2Sri")
list_of_files = list(current_directory.glob("*.nii"))
list_of_files.sort()

renamed_directory = Path(current_directory / "renamed_files")
os.mkdir(renamed_directory)

for idx in range(0,len(list_of_files)):
    old_filename = list_of_files[idx].stem
    old_filename_parts = old_filename.split('_')
    old_filename_parts[1] = old_filename_parts[1].zfill(3)
    old_filename_parts[6] = old_filename_parts[6].zfill(3)
    new_filename = '_'.join(old_filename_parts)
    print("Old filename is:")
    old_filename = old_filename + '.nii'
    print(old_filename)
    print("New filename is:")
    new_filename = new_filename + '.nii'
    print(new_filename)
    src = Path( current_directory / old_filename)
    dest = Path( renamed_directory / new_filename)
    os.rename(src,dest)

os.system("fslmerge -t 4D_dataset.nii " + renamed_directory.as_posix() + "/*.nii")