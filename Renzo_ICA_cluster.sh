#!/bin/bash

#Temporal filtering


echo "components"
for filename in components*
do

3dclust -prefix nice_${filename} -1clip 1.6 0.8 15 ${filename} -overwrite

#3dclust masked_file        -1clip val_thresh distance vol ${filename} -overwrite

done
#rm smoothed_network_$1 
#rm network_$1 

3dMean -prefix all_components.nii  -overwrite nice_components*

echo "sub components"
for filename in subcomponents*
do

3dclust -prefix nice_${filename} -1clip 1.6 0.8 10 ${filename} -overwrite

#3dclust masked_file        -1clip val_thresh distance vol ${filename} -overwrite

done

3dMean -prefix all_subcomponents.nii -overwrite nice_subcomponents*
