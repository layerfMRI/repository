mv BOLD_zstat1.nii BOLD_zstat1_index.nii 
mv BOLD_zstat2.nii BOLD_zstat2_middle.nii 
mv BOLD_zstat3.nii BOLD_zstat3_ring.nii 
mv BOLD_zstat4.nii BOLD_zstat4_pinky.nii 
mv BOLD_zstat5.nii BOLD_zstat5_four.nii 

mv zstat1.nii VASO_zstat1_index.nii 
mv zstat2.nii VASO_zstat2_middle.nii 
mv zstat3.nii VASO_zstat3_ring.nii 
mv zstat4.nii VASO_zstat4_pinky.nii 
mv zstat5.nii VASO_zstat5_four.nii 

3dcalc -a VASO_zstat1_index.nii -overwrite -expr '-1*a' -prefix VASO_zstat1_index.nii
3dcalc -a VASO_zstat2_middle.nii -overwrite -expr '-1*a' -prefix VASO_zstat2_middle.nii
3dcalc -a VASO_zstat3_ring.nii -overwrite -expr '-1*a' -prefix VASO_zstat3_ring.nii
3dcalc -a VASO_zstat4_pinky.nii -overwrite -expr '-1*a' -prefix VASO_zstat4_pinky.nii
3dcalc -a VASO_zstat5_four.nii -overwrite -expr '-1*a' -prefix VASO_zstat5_four.nii

#3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -e VASO_zstat5_four.nii -overwrite -expr 'a/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix VASO_sc_norm_index.nii
#3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -e VASO_zstat5_four.nii -overwrite -expr 'b/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix VASO_sc_norm_middle.nii
#3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -e VASO_zstat5_four.nii -overwrite -expr 'c/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix VASO_sc_norm_ring.nii
#3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -e VASO_zstat5_four.nii -overwrite -expr 'd/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix VASO_sc_norm_pinky.nii

#3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -e BOLD_zstat5_four.nii -overwrite -expr 'a/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix BOLD_sc_norm_index.nii
#3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -e BOLD_zstat5_four.nii -overwrite -expr 'b/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix BOLD_sc_norm_middle.nii
#3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -e BOLD_zstat5_four.nii -overwrite -expr 'c/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix BOLD_sc_norm_ring.nii
#3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -e BOLD_zstat5_four.nii -overwrite -expr 'd/(posval(a)+posval(b)+posval(c)+posval(d))*e' -prefix BOLD_sc_norm_pinky.nii


3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -overwrite -expr 'posval(a/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix VASO_norm_index.nii
3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -overwrite -expr 'posval(b/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix VASO_norm_middle.nii
3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -overwrite -expr 'posval(c/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix VASO_norm_ring.nii
3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -overwrite -expr 'posval(d/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix VASO_norm_pinky.nii

3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -overwrite -expr 'posval(a/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix BOLD_norm_index.nii
3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -overwrite -expr 'posval(b/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix BOLD_norm_middle.nii
3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -overwrite -expr 'posval(c/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix BOLD_norm_ring.nii
3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -overwrite -expr 'posval(d/(posval(a)+posval(b)+posval(c)+posval(d)))' -prefix BOLD_norm_pinky.nii

3dcalc -a BOLD_zstat1_index.nii -b BOLD_zstat2_middle.nii -c BOLD_zstat3_ring.nii -d BOLD_zstat4_pinky.nii -overwrite -expr 'argmax(a,b,c,d)' -prefix -overwrite BOLD_winnermap.nii
3dcalc -a VASO_zstat1_index.nii -b VASO_zstat2_middle.nii -c VASO_zstat3_ring.nii -d VASO_zstat4_pinky.nii -overwrite -expr 'argmax(a,b,c,d)' -prefix -overwrite VASO_winnermap.nii


