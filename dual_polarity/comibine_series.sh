#!/bin/bash

basevol=1000 # TR indexing

n_vols=`PrintHeader MAG_series.nii | grep Dimens | cut -d ',' -f 4 | cut -d ']' -f 1`
#n_vols=45
nthvol=$(($basevol + $n_vols - 2)) # Zero indexing with last missing

ImageMath 4 vol_M_.nii TimeSeriesDisassemble MAG_series.nii # vol_M_1000.nii, vol_M_1001.nii ...
ImageMath 4 vol_P_.nii TimeSeriesDisassemble PHA_series.nii # vol_P_1000.nii, vol_P_1001.nii ...


for i in $(eval echo "{$basevol..$nthvol}");
do

ipo=$(($i + 1)) # Zero indexing with last missing

3dcalc -a vol_M_${i}.nii -b vol_M_${ipo}.nii -c  vol_P_${i}.nii -d vol_P_${ipo}.nii -overwrite -expr 'sqrt((a*cos(c/4095*2*PI)+b*cos(d/4095*2*PI))*(a*cos(c/4095*2*PI)+b*cos(d/4095*2*PI))+(a*sin(c/4095*2*PI)+b*sin(d/4095*2*PI))*(a*sin(c/4095*2*PI)+b*sin(d/4095*2*PI)))/2' -prefix mag_${i}.nii -datum float


done

ImageMath 4 combined_timeseries.nii TimeSeriesAssemble 4.5 0 mag_1*.nii

rm vol_M_1*.nii
rm vol_P_1*.nii
rm mag_1*.nii

3dTstat -tSNR -prefix tSNR_compl_com.nii -overwrite combined_timeseries.nii

#temp average 
3dcalc -a MAG_series.nii'[0..40(2)]' -b MAG_series.nii'[2..42(2)]' -overwrite -prefix mag_series_running_average.nii -expr '(a+b)/2'

3dTstat -tSNR -prefix tSNR_unipolar_running_average.nii -overwrite mag_series_running_average.nii'[0..$(2)]'
3dTstat -tSNR -prefix tSNR_unipolar.nii -overwrite MAG_series.nii'[0..$(2)]'


#3dCalc -prefix mag_even.nii -expr 'a/4095*2*PI' -a Mag.nii'[9..9]' -datum float -overwrite
#3dCalc -prefix mag_odd.nii  -expr 'a/4095*2*PI' -a Mag.nii'[10..10]' -datum float -overwrite
#3dCalc -prefix pha_even.nii -expr 'a/4095*2*PI' -a Pha.nii'[9..9]' -datum float -overwrite
#3dCalc -prefix pha_odd.nii  -expr 'a/4095*2*PI' -a Pha.nii'[10..10]' -datum float -overwrite

#3dCalc -a mag_even.nii -b mag_odd.nii -overwrite -expr '(a+b)/2' -prefix mag_magsum.nii -datum float

#3dCalc -a mag_even.nii -b mag_odd.nii -c pha_even.nii -d pha_odd.nii -overwrite -expr 'sqrt((a*cos(c/4095*2*PI)+b*cos(d/4095*2*PI))*(a*cos(c/4095*2*PI)+b*cos(d/4095*2*PI))+(a*sin(c/4095*2*PI)+b*sin(d/4095*2*PI))*(a*sin(c/4095*2*PI)+b*sin(d/4095*2*PI)))/2' -prefix mag_complsum.nii -datum float




