#!/bin/bash

#Temporal filtering




3dclust -prefix nice_${filename} -1clip 1.6 0.8 10 ${filename} -overwrite

#3dclust masked_file        -1clip val_thresh distance vol ${filename} -overwrite
