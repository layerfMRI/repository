#!/bin/bash


echo "starte jetzt"
mkdir output_folder_BOLD

for filename in `ls $1*`; do
  echo ${filename}
 # 3drefit -space ORIG -view orig -TR 1.5 ${filename}


#3dTstat -mean -prefix mean_nulled_${filename} ${filename}'[3..$(2)]' -overwrite
#3dTstat -mean -prefix mean_notnulled_${filename} ${filename}'[2..$(2)]' -overwrite

done

# Run identifiers listed in the temporal order they were collected



for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  cp ./$1"$idx".nii   ./output_folder_BOLD/$idx.nii
done

cd output_folder_BOLD

 NumVol=`3dinfo -nv 0.nii`

echo "Number of TRs is $NumVol" 



for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -prefix Nulled_$idx.nii \
         -a      $idx.nii'[2..$(2)]' \
         -expr 'a' -overwrite
done

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dTstat -cvarinv -prefix tSNR_$idx.nii Nulled_$idx.nii -overwrite 
done

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dTstat -mean -prefix MEAN_$idx.nii Nulled_$idx.nii -overwrite 
done

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -a MEAN_$idx.nii -expr 'log(a)' -prefix logMEAN_$idx.nii  -overwrite 
done

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -a tSNR_$idx.nii -expr 'log(a)' -prefix logtSNR_$idx.nii  -overwrite 
done

# get tSNR combined

3dcalc -prefix combined_tSNR.nii \
         -a      tSNR_01.nii \
         -expr '0*a' -overwrite



3dcalc -prefix mean_tSNR.nii \
         -a      tSNR_01.nii \
         -expr '0*a' -overwrite


for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -prefix mean_tSNR.nii \
         -a       tSNR_$idx.nii \
	 -c 	mean_tSNR.nii \
         -expr 'a/32.0+c' -overwrite
done


for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -prefix combined_tSNR.nii \
         -a      tSNR_$idx.nii \
	 -b	 $idx.nii \
	 -c 	 combined_tSNR.nii \
	 -d 	 mean_tSNR.nii \
         -expr 'a/d*b+c' -overwrite

done


# get standard combined

3dcalc -prefix combined_stdrt.nii \
         -a      tSNR_01.nii \
         -expr '0*a' -overwrite

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  3dcalc -prefix combined_stdrt.nii \
         -a      $idx.nii \
	 -c 	 combined_stdrt.nii \
         -expr 'a*a+c' -overwrite
done


3dcalc -prefix combined_stdrt.nii \
         -a      combined_stdrt.nii \
         -expr 'sqrt(a)' -overwrite

#Aufraeumen

for idx in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64; do
  #rm $idx.nii
  #rm tSNR_$idx.nii
  #rm Nulled_$idx.nii
done


#for idx in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ; do
#   3dTstat -mean -prefix mean_nulled_${filename} ${filename}'[3..$(2)]' -overwrite         ./${RunIDs[$idx]}.nii
#done

#  3dvolreg -overwrite -prefix BOLD.volreg.nii -base mean_notnulled.nii \
#    -dfile BOLD.dfile.1D -1Dfile BOLD.mot.1D $1.nii'[2..$(2)]'
#  3dvolreg -overwrite -prefix Null.volreg.nii -base  mean_nulled.nii \
#    -dfile Null.dfile.1D -1Dfile Null.mot.1D $1.nii'[3..$(2)]'

#rm mean_nulled.nii
#rm mean_notnulled.nii

# Then calculate the mean, stdev, & cvarinv (detrended mean/stdev) for BOLD & Nulled volumes

# Calculate VASO!


  # The first vaso volume is first nulled volume divided by the 2nd BOLD volume
#  3dcalc -prefix tmp.VASO_vol1.nii \
#         -a      BOLD.volreg.nii'[1]' \
#         -b      Null.volreg.nii'[0]' \
#         -expr 'b/a' -overwrite

  # Calculate all VASO volumes after the first one
  # -a goes from the 2nd BOLD volume to the 2nd-to-last BOLD volume
  # -b goes from the 3rd BOLD volume to the last BOLD volume
  # -c goes from the 2nd Nulled volume to the last Nulled volume

 # NumVol=`3dinfo -nv BOLD.volreg.nii`
#  3dcalc -prefix tmp.VASO_othervols.nii \
#         -a      BOLD.volreg.nii'[1..'`expr $NumVol - 2`']' \
#         -b      BOLD.volreg.nii'[2..$]' \
#         -c      Null.volreg.nii'[1..$]' \
#         -expr 'c*2/(a+b)' -overwrite
 
   # concatinate the first VASO volume with the rest of the sequence
 #  3dTcat -overwrite -prefix VASO.volreg.nii tmp.VASO_vol1.nii tmp.VASO_othervols.nii


# Remove the temporary seprate files for the first VASO volume and the rest of the VASO volumes
#rm tmp.VASO_vol1*.nii tmp.VASO_othervols*.nii


# BOLD and VASO now have 3s or 312s TRs
# Use 3drefit to make this change in the file headers
#for filename in `ls *BOLD*.nii *VASO*.nii`; do
#  echo ${filename}
#  3drefit -TR 3.0 ${filename}
#done


