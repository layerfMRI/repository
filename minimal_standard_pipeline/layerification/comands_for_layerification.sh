#!/bin/bash

#################################################
#########  locating data and moving there  #############
#################################################

#cd PathToData 

####################################################
#########  getting familiar with LayNii ############
####################################################
#we use LayNii 2.2.1

ml laynii

LN_INFO -help

LN_INFO -input anat.nii.gz -sub 5 -inv


########################################
######### Drawing rim in ITK-SNAP ######
########################################

#########################################
#########  estimating layers ############
#########################################

LN2_LAYERS -help
LN2_LAYERS -rim rim.nii.gz -nr_layers 10 -equal_counts -equivol


###########################################################
######### Extracting layer signals as profiles ############
###########################################################
                
LN2_PROFILE 
LN2_PROFILE -input runAverage_condition-1.nii.gz -layers rim_layerbins_equivol.nii.gz -plot -output layer_profile_cond1.txt
LN2_PROFILE -input runAverage_condition-2.nii.gz -layers rim_layerbins_equivol.nii.gz -plot -output layer_profile_cond2.txt

#################################################
##### performing   ##############################
##### Statistical analysis of layers ############
##### in AFNI's PTA  ############################
#################################################
# we use ANI version 21.2.00

ml afni/21.2.00
PTA -prefix d1 -input d1.tbl -model 's(layer)+s(layer,by=Condition)+s(run,bs="re")' -vt run 's(run)' -Y Value -prediction p1.tbl

1dplot                                                                       \
    -one                                                                     \
    -xlabel      'layer'                                                     \
    -ylabel      'magnitude'                                                 \
    -plabel      'Layer plotting'                                            \
    -ok_1D_text                                                              \
    'd1-prediction.txt[4]{11..20}'                                           \
    'd1-prediction.txt[4]{1..10}'                                            \
    "1D: 10@0"


