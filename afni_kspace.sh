#!/bin/bash

#3dFFT -abs -input filename.nii -prefix outputfilename.nii -overwrite -altIN

#the altIN makes that k-space center is in center if volume
#When you only whant it in one direction set -Lx 0 -Ly 0


#e.g. 3dFFT -abs -input filename.nii -prefix outputfilename.nii -overwrite -altIN -Lx 0 -Ly 0


#For doing back and forth calculation there are several steps necessary:
#Forward with: 
3dFFT  -input $1 -prefix outfile_abs.nii -overwrite  -abs 
3dFFT  -input $1 -prefix outfile_phase.nii -overwrite  -phase

#use "-Lx 0 -Ly 0" option , if the K-space transform should be done in 2 tim ownly

#combine to complex image: 
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_abs.nii outfile_phase.nii

#Back transform: 
3dFFT  -input cpmlx.nii -prefix back_transformed.nii -overwrite -altin  -altOUT -inverse

3dcalc -a xmask.nii -b outfile_abs.nii -prefix outfile_absx.nii -overwrite -expr '(1-a)*b'
3dcalc -a xmask.nii -b outfile_phase.nii -prefix outfile_phasex.nii -overwrite -expr '(1-a)*b'
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_absx.nii outfile_phasex.nii
3dFFT  -input cpmlx.nii -prefix back_transformed_x.nii -overwrite -altin  -altOUT -inverse

3dcalc -a ymask.nii -b outfile_abs.nii -prefix outfile_absy.nii -overwrite -expr '(1-a)*b'
3dcalc -a ymask.nii -b outfile_phase.nii -prefix outfile_phasey.nii -overwrite -expr '(1-a)*b'
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_absy.nii outfile_phasey.nii
3dFFT  -input cpmlx.nii -prefix back_transformed_y.nii -overwrite -altin  -altOUT -inverse

3dcalc -a ymask.nii -c xmask.nii -b outfile_abs.nii   -prefix outfile_absxy.nii   -overwrite -expr '(1-a)*(1-c)*b'
3dcalc -a ymask.nii -c xmask.nii -b outfile_phase.nii -prefix outfile_phasexy.nii -overwrite -expr '(1-a)*(1-c)*b'
3dTwotoComplex -MP -prefix cpmlx.nii -overwrite outfile_absxy.nii outfile_phasexy.nii
3dFFT  -input cpmlx.nii -prefix back_transformed_xy.nii -overwrite -altin  -altOUT -inverse
