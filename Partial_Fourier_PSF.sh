#!/bin/bash
 
#creating nii out of nothing 

#rm float_im.nii  
#nifti_tool -make_im -prefix float_im.nii  -new_dims 3 44 212 212 0 0 0 0  -new_datatype 16 
#3drefit -zdel 0.9 -xdel 0.9 -ydel 0.9 -overwrite float_im.nii 

#addint point and renaming it o point.nii

#going to Ks-space



#in ms
readout_dur=54
#estimated based on GRAPPA 4, echo spacing 1.02, Matrix 212

# T2* in ms assumed
t2star=28

matrix=212


echo "_____________________> $ky_0"
echo "____________________ $t2star   $readout_dur"

# going to k-space
#LZ o means only 2D-transform
#-altIn means the k-space is in center
3dFFT  -input point.nii -prefix outfile_abs.nii -overwrite  -abs -altIN
3dFFT  -input point.nii -prefix outfile_phase.nii -overwrite  -phase  -altIN
#doing T2* weighting
3dcalc -a outfile_abs.nii -expr 'exp(-1*k/('`expr $matrix`')*'`expr $readout_dur`'/'`expr $t2star`')' -overwrite -prefix exponential.nii
3dcalc -a outfile_abs.nii -b exponential.nii -expr 'a*b' -overwrite -prefix outfile_abs_weighted.nii

#doin Partial Fourier
3dcalc -a outfile_abs_weighted.nii -b pf_mask.nii.gz -expr 'a*b' -overwrite -prefix outfile_abs_weighted.nii
3dcalc -a outfile_phase.nii -b pf_mask.nii.gz -expr 'a*b' -overwrite -prefix outfile_phase_weighted.nii
#combining k-space magn and phase to complex valued data
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_abs_weighted.nii outfile_phase.nii
#back to k-space
3dFFT  -input cpmlx.nii -prefix PSF.nii -overwrite -altin  -altOUT -inverse 
#clean up
#rm cpmlx.nii outfile_abs_weighted.nii outfile_phase.nii exponential.nii  outfile_abs.nii
