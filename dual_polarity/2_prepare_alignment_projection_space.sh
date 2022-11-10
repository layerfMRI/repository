#!/bin/bash


3dcalc -prefix mag_even.nii -expr 'a' -a Mag.nii'[9..9]' -overwrite
3dcalc -prefix mag_odd.nii  -expr 'a' -a Mag.nii'[10..10]'  -overwrite
3dcalc -prefix pha_even_rad.nii -expr 'a/4095*2*PI' -a Pha.nii'[9..9]' -overwrite
3dcalc -prefix pha_odd_rad.nii  -expr 'a/4095*2*PI' -a Pha.nii'[10..10]'  -overwrite

3dcalc -a mag_even.nii -b mag_odd.nii -overwrite -expr '(a+b)/2' -prefix mag_magsum.nii 

3dcalc -a mag_even.nii -b mag_odd.nii -c pha_even_rad.nii -d pha_odd_rad.nii -overwrite -expr 'sqrt((a*cos(c)+b*cos(d))*(a*cos(c)+b*cos(d))+(a*sin(c)+b*sin(d))*(a*sin(c)+b*sin(d)))/2' -prefix mag_complsum.nii 


# going to k-space

#combining magntiude and phase in to complex-valued dataset
3dTwotoComplex -overwrite -MP -prefix even_complex.nii mag_even.nii pha_even_rad.nii
3dTwotoComplex -overwrite -MP -prefix odd_complex.nii mag_even.nii pha_odd_rad.nii

#LZ o means only 2D-transform
#-altIn means the k-space is in center
3dFFT  -input even_complex.nii -prefix even_complex_kspace.nii -overwrite  -complex -altIn -Lx 0
#3dFFT  -input even_complex.nii -prefix even_ampl_kspace.nii -overwrite  -abs 
#3dFFT  -input even_complex.nii -prefix even_phase_kspace.nii -overwrite  -phase 
#3dTwotoComplex -overwrite -MP -prefix even_complex_kspace_copy.nii even_ampl_kspace.nii even_phase_kspace.nii
#3dFFT  -overwrite -input even_complex_kspace.nii -prefix backtransformedampl.nii -overwrite -abs -inverse
#3dFFT  -overwrite -input even_complex_kspace_copy.nii -prefix backtransformedampl_copy.nii -overwrite -abs -inverse

#cp zyxt.nii even_complex_kspace.nii
3dFFT  -input odd_complex.nii  -prefix odd_complex_kspace.nii  -overwrite  -complex -altIN -Lx 0
#cp zyxt.nii odd_complex_kspace.nii

3dcalc -cx2r REAL -a even_complex_kspace.nii -cx2r REAL -b odd_complex_kspace.nii -overwrite -expr '(a+b)/2' -prefix real_complsum_kspace.nii 
3dcalc -cx2r IMAG -a even_complex_kspace.nii -cx2r IMAG -b odd_complex_kspace.nii -overwrite -expr '(a+b)/2' -prefix imag_complsum_kspace.nii 

3dTwotoComplex -overwrite -RI -prefix complex_sum.nii real_complsum_kspace.nii imag_complsum_kspace.nii

3dFFT -overwrite -input complex_sum.nii -prefix complex_sum_image_ampl_noFFT.nii -overwrite -abs -altOUT -inverse -Lx 0
