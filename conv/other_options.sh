#!/bin/bash



#afni conf:
Dimon -infile_prefix folder_with_dicoms -dicom_org -gert_create_dataset

to3d -assume_dicom_mosaic -prefix run1c.nii -time:tz 200 1 1000 zero *.dcm

dcm2niix -z y -f S_%p_%t_%s -o ../ ./
dcm2niix -b y -z y -i n  -o ../ ./

If you want it isisconv like, then I would call it like: dcm2niix -ba y -z y -o ${output_dir} -f S%s_%d_e%e ${input_dir}
