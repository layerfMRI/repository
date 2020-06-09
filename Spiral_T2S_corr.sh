#!/bin/bash


dkx_0=`3dinfo -ni $1`
dky_0=`3dinfo -nj $1`

ky_0=$(echo "($dkx_0 / 2)"|bc -l)
ky_0=$(echo "($dkx_0 / 2)"|bc -l)


#in ms
readout_dur=30
# T2* in ms
t2star=28

echo "_____________________> $ky_0"
echo "____________________ $t2star   $readout_dur"

# going to k-space
#LZ o means only 2D-transform
#-altIn means the k-space is in center
3dFFT  -input $1 -prefix outfile_abs.nii -overwrite  -abs -Lz 0 -altIN
3dFFT  -input $1 -prefix outfile_phase.nii -overwrite  -phase -Lz 0 -altIN
#fixing T2* weighting
3dcalc -a outfile_abs.nii -expr 'exp('`expr $readout_dur`'/80*sqrt((i-80)*(i-80)+(j-80)*(j-80))/('`expr $t2star`'))' -overwrite -prefix exponential.nii
3dcalc -a outfile_abs.nii -b exponential.nii -expr 'a*b' -overwrite -prefix outfile_abs_weighted.nii
#combining k-space magn and phase to complex valued data
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_abs_weighted.nii outfile_phase.nii
#back to k-space
3dFFT  -input cpmlx.nii -prefix back_trans_$1 -overwrite -altin  -altOUT -inverse  -Lz 0
#clean up
rm cpmlx.nii outfile_abs_weighted.nii outfile_phase.nii exponential.nii  outfile_abs.nii
