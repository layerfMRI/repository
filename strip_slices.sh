#!/bin/bash

echo "starting"
#!/bin/bash



fslsplit ./$1 splited -z

rm splited0000.nii
rm splited0001.nii
rm splited0010.nii
rm splited0011.nii


fslmerge -z striped_$1 splited*

rm splited*


echo "done"
