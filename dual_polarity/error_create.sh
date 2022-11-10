#!/bin/bash



#3dcalc -cx2r REAL -a even_complex.nii -cx2r REAL -b odd_complex.nii -overwrite -expr '(a-b)' -prefix real_diff.nii 
#3dcalc -cx2r IMAG -a even_complex.nii -cx2r IMAG -b odd_complex.nii -overwrite -expr '(a-b)' -prefix imag_diff.nii 

#3dcalc -cx2r REAL -a even_complex.nii -cx2r REAL -b odd_complex.nii -cx2r IMAG -c even_complex.nii -cx2r IMAG -d odd_complex.nii -overwrite -expr 'sqrt((a-b)*(a-b)+(c-d)*(c-d))' -prefix imag_diff_again.nii 

# this cannot deal with negative real parts? 
#3dTwotoComplex -overwrite -RI -prefix complex_diff.nii real_diff.nii imag_diff.nii

#3dcalc -cx2r ABS -a complex_diff.nii -overwrite -expr '(a)' -prefix AMPL_diff.nii 
#3dcalc -cx2r PHASE -a complex_diff.nii -overwrite -expr '(a)' -prefix PHA_diff.nii 

#3dcalc -a mag_even.nii -b mag_odd.nii -overwrite -expr 'a-b' -prefix mag_diff.nii 

3dcalc  -a mag_even.nii  -b mag_odd.nii -c pha_even_rad.nii -d pha_odd_rad.nii -overwrite -expr '(a*cos(c)-b*cos(d))' -prefix real_diff.nii
3dcalc  -a mag_even.nii  -b mag_odd.nii -c pha_even_rad.nii -d pha_odd_rad.nii -overwrite -expr '(a*sin(c)-b*sin(d))' -prefix imag_diff.nii
3dcalc  -a real_diff.nii -b imag_diff.nii -prefix AMPL_diff.nii -overwrite -expr 'sqrt(a*a+b*b)'
