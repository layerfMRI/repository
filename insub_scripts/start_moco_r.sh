echo "start"
#!/bin/bash

cnt=0
for filename in ./S*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[4..7]' Basis_${cnt}a.nii'[4..$]' -overwrite
cp ./Basis_${cnt}a.nii ./Basis_${cnt}b.nii

3dinfo -nt Basis_${cnt}a.nii >> NT.txt
3dinfo -nt Basis_${cnt}b.nii >> NT.txt
cnt=$(($cnt+1))

done





export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/Applications/MATLAB_R2016b.app/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"

: '
echo "clean up"
mkdir motion_junk
mv Basis_* motion_junk
mkdir nii
mv S*.nii nii
echo "Done"
'