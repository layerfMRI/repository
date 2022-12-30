#!/bin/bash


echo "starting"

#just in case you are not in the nii folder already
cd nii

for file in *.nii.gz ; do mv $file ${file//_S00/_cbv} ; done
for file in *.json ; do mv $file ${file//_S00/_cbv} ; done

for file in *.nii.gz ; do mv $file ${file//_S01/_bold} ; done
for file in *.json ; do mv $file ${file//_S01/_bold} ; done

for file in *.nii.gz ; do mv $file ${file//_e1/} ; done
for file in *.json ; do mv $file ${file//_e1/} ; done

for file in *.nii.gz ; do mv $file ${file//_E00/} ; done
for file in *.json ; do mv $file ${file//_E00/} ; done

for file in *.nii.gz ; do mv $file ${file//_P_ph/_phase1} ; done
for file in *.json ; do mv $file ${file//_P_ph/_phase1} ; done

for file in *.nii.gz ; do mv $file ${file//_M/_magnitude1} ; done
for file in *.json ; do mv $file ${file//_M/_magnitude1} ; done


echo "and buy"

 
