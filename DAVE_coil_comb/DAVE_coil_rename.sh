#!/bin/bash


echo "starte jetzt"


for filename in `ls $1*`; do
  echo ${filename}
 # 3drefit -space ORIG -view orig -TR 1.5 ${filename}


#3dTstat -mean -prefix mean_nulled_${filename} ${filename}'[3..$(2)]' -overwrite
#3dTstat -mean -prefix mean_notnulled_${filename} ${filename}'[2..$(2)]' -overwrite

done

for filename in `ls $1*`; do ;  echo ${filename} ; done
 # 3drefit -space ORIG -view orig -TR 1.5 ${filename}


#3dTstat -mean -prefix mean_nulled_${filename} ${filename}'[3..$(2)]' -overwrite
#3dTstat -mean -prefix mean_notnulled_${filename} ${filename}'[2..$(2)]' -overwrite

done

# Run identifiers listed in the temporal order they were collected
Filelist=('1'  '2'  '4'  '8'  '16'  '32'  '64'  '128'  '256'  '512'  '1024'  '2048'  '4096'  '8192'  '16384'  '32768'  '65536'  '131072'  '262144'  '524288'  '1048576'  '2097152'  '4194304'  '8388608'  '16777216'  '33554432'  '67108864'  '134217728'  '268435456'  '536870912'  '1073741824'  '2147483648')


for idx in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ; do
  mv ./$1${Filelist[$idx]}.nii   ./$idx.nii
done



