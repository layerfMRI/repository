#!/bin/bash



#afni conf:
Dimon -infile_prefix folder_with_dicoms -dicom_org -gert_create_dataset

to3d -assume_dicom_mosaic -prefix run1c.nii -time:tz 200 1 1000 zero *.dcm

dcm2niix -z y -f S_%p_%t_%s -o ../ ./
dcm2niix -b y -z y -i n  -o ../ ./

If you want it isisconv like, then I would call it like: dcm2niix -ba y -z y -o ${output_dir} -f S%s_%d_e%e ${input_dir}

Dimon -quiet -sort_by_acq_time -infile_pattern "mr_0016/*.dcm" -dicom_org -gert_create_dataset -gert_to3d_prefix testMosaic.nii


Other option from Martin Kronbicher

FILES="/data/neurokog/nsi/LAY20/raw_data/in_test/MR*"
for f  in $FILES

do
 seriesID=`dicom_hdr ${f} | grep "Series Number" | awk -F"//" '{print $3}'`; 
 if [ ! -e /data/neurokog/nsi/LAY20/raw_data/in_test/SORTED/${seriesID} ]; then
 mkdir -p /data/neurokog/nsi/LAY20/raw_data/in_test/SORTED/${seriesID};
 echo "Series ${seriesID}"
 fi;
 cp ${f} /data/neurokog/nsi/LAY20/raw_data/in_test/SORTED/${seriesID};
done
dann habe ich dimon so verwendet
Dimon -infile_prefix 8/ -dicom_org -gert_create_dataset  -gert_write_as_nifti
