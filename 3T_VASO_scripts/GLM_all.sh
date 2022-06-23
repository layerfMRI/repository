#!/bin/bash


echo "fange an"




for dir in ./*/
do
dir=${dir%*/}
cd ./$dir
echo  ${dir##*/}


cd M1 

cp ../../design.fsf  design_BOLD.fsf 

cd ..


sed -i '' 's/pathtodata/'"$dir"'/g' design_BOLD.fsf


cd ..


cd ..
done


echo "und tschuess"

 
