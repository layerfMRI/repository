#!/bin/bash

#for filename in BOLD_1 BOLD_2 BOLD_3 VASO_1 VASO_2 VASO_3; do


  echo "XxXXXXXXXXXX '_'"
  #cp $filename.nii $filename_1.nii
 # 3dUpsample -prefix $1 -overwrite 2 BOLD_.nii
 # 3dcalc -expr 'a' -datum short -a $1 -overwrite -prefix $1
 # 3drefit -TR 2 $1

  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[0..10]'    -overwrite -prefix a_t1.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[32..42]'   -overwrite -prefix a_t2.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[40..50]'   -overwrite -prefix a_t3.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[56..66]'   -overwrite -prefix a_t4.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[80..90]'   -overwrite -prefix a_t5.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[88..98]'   -overwrite -prefix a_t6.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[96..106]'  -overwrite -prefix a_t7.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[112..122]' -overwrite -prefix a_t8.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[144..154]' -overwrite -prefix a_t9.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[152..162]' -overwrite -prefix a_t10.nii
  
  
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[8..18]'    -overwrite -prefix r_t1.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[16..26]'   -overwrite -prefix r_t2.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[24..34]'   -overwrite -prefix r_t3.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[48..58]'   -overwrite -prefix r_t4.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[64..74]'   -overwrite -prefix r_t5.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[72..82]'   -overwrite -prefix r_t6.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[104..114]' -overwrite -prefix r_t7.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[120..130]' -overwrite -prefix r_t8.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[128..138]' -overwrite -prefix r_t9.nii
  3dcalc -expr 'a' -datum short  -a MEAN_BOLD_A.nii'[136..146]' -overwrite -prefix r_t10.nii
   #VASO.volreg.nii'[1..$]'
   #VASO.volreg.nii'[1..$]'

3dMean -overwrite -prefix MEAN_BOLD_trial_alpha.nii a_t1.nii \
										 a_t2.nii \
										 a_t3.nii \
										 a_t4.nii \
										 a_t5.nii \
										 a_t6.nii \
										 a_t7.nii \
										 a_t8.nii \
										 a_t9.nii \
										 a_t10.nii
										 
3dMean -overwrite -prefix MEAN_BOLD_trial_rem.nii   r_t1.nii \
										 r_t2.nii \
										 r_t3.nii \
										 r_t4.nii \
										 r_t5.nii \
										 r_t6.nii \
										 r_t7.nii \
										 r_t8.nii \
										 r_t9.nii \
										 r_t10.nii 


3dTstat -mean -prefix rem_baseline.nii  -overwrite MEAN_BOLD_trial_rem.nii'[5..10]'
3dTstat -mean -prefix alph_baseline.nii -overwrite MEAN_BOLD_trial_alpha.nii'[5..10]'

#3dcalc -expr '(a-b+c-d)/(b+d)' -datum short -a rem_MEAN.nii'[3]' -b rem_MEAN.nii'[5]' -c alpha_MEAN.nii'[3]' -d alpha_MEAN.nii'[5]' -overwrite -prefix response.nii
3dcalc -expr '(a/b)' -datum short -a MEAN_BOLD_trial_rem.nii   -b rem_baseline.nii  -overwrite -prefix MEAN_BOLD_trial_rem_norm.nii
3dcalc -expr '(a/b)' -datum short -a MEAN_BOLD_trial_alpha.nii -b alph_baseline.nii -overwrite -prefix MEAN_BOLD_trial_alpha_norm.nii

#3dcalc -expr '(a-b)/(b)' -datum short -a response_MEAN.nii'[3]' -b response_MEAN.nii'[5]' -overwrite -prefix response.nii

rm rem_baseline.nii
rm alph_baseline.nii
rm r_t*.nii
rm a_t*.nii
# 3dMean -overwrite -prefix  T1_MEAN.nii T1_1.nii T1_2.nii  

#3dcalc 
#fslmerge -t BOLD_merged.nii BOLD_1.nii BOLD_2.nii BOLD_3.nii
#3dUpsample -prefix BOLD_merged_TR2.nii -overwrite 2 BOLD_merged.nii
#short_me.sh BOLD_merged_TR2.nii
#3drefit -TR 2 BOLD_merged_TR2.nii




  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[0..10]'    -overwrite -prefix a_t1.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[32..42]'   -overwrite -prefix a_t2.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[40..50]'   -overwrite -prefix a_t3.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[56..66]'   -overwrite -prefix a_t4.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[80..90]'   -overwrite -prefix a_t5.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[88..98]'   -overwrite -prefix a_t6.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[96..106]'  -overwrite -prefix a_t7.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[112..122]' -overwrite -prefix a_t8.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[144..154]' -overwrite -prefix a_t9.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[152..162]' -overwrite -prefix a_t10.nii
  
  
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[8..18]'    -overwrite -prefix r_t1.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[16..26]'   -overwrite -prefix r_t2.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[24..34]'   -overwrite -prefix r_t3.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[48..58]'   -overwrite -prefix r_t4.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[64..74]'   -overwrite -prefix r_t5.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[72..82]'   -overwrite -prefix r_t6.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[104..114]' -overwrite -prefix r_t7.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[120..130]' -overwrite -prefix r_t8.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[128..138]' -overwrite -prefix r_t9.nii
  3dcalc -expr 'a' -datum short  -a MEAN_VASO_A.nii'[136..146]' -overwrite -prefix r_t10.nii
   #VASO.volreg.nii'[1..$]'
   #VASO.volreg.nii'[1..$]'

3dMean -overwrite -prefix MEAN_VASO_trial_alpha.nii a_t1.nii \
										 a_t2.nii \
										 a_t3.nii \
										 a_t4.nii \
										 a_t5.nii \
										 a_t6.nii \
										 a_t7.nii \
										 a_t8.nii \
										 a_t9.nii \
										 a_t10.nii
										 
3dMean -overwrite -prefix MEAN_VASO_trial_rem.nii   r_t1.nii \
										 r_t2.nii \
										 r_t3.nii \
										 r_t4.nii \
										 r_t5.nii \
										 r_t6.nii \
										 r_t7.nii \
										 r_t8.nii \
										 r_t9.nii \
										 r_t10.nii 


3dTstat -mean -prefix rem_baseline.nii  -overwrite MEAN_VASO_trial_rem.nii'[5..10]'
3dTstat -mean -prefix alph_baseline.nii -overwrite MEAN_VASO_trial_alpha.nii'[5..10]'

#3dcalc -expr '(a-b+c-d)/(b+d)' -datum short -a rem_MEAN.nii'[3]' -b rem_MEAN.nii'[5]' -c alpha_MEAN.nii'[3]' -d alpha_MEAN.nii'[5]' -overwrite -prefix response.nii
3dcalc -expr '(a/b)' -datum short -a MEAN_VASO_trial_rem.nii   -b rem_baseline.nii  -overwrite -prefix MEAN_VASO_trial_rem_norm.nii
3dcalc -expr '(a/b)' -datum short -a MEAN_VASO_trial_alpha.nii -b alph_baseline.nii -overwrite -prefix MEAN_VASO_trial_alpha_norm.nii

#3dcalc -expr '(a-b)/(b)' -datum short -a response_MEAN.nii'[3]' -b response_MEAN.nii'[5]' -overwrite -prefix response.nii

rm rem_baseline.nii
rm alph_baseline.nii
rm r_t*.nii
rm a_t*.nii


#3dcalc -a output_BOLD.nii'[1]' -expr 'a' -prefix "B_encoding.nii" -overwrite
#3dcalc -a output_BOLD.nii'[2]' -expr 'a' -prefix "B_delay_rem.nii" -overwrite
#3dcalc -a output_BOLD.nii'[3]' -expr 'a' -prefix "B_del_alpha.nii" -overwrite
#3dcalc -a output_BOLD.nii'[4]' -expr 'a' -prefix "B_test_rem.nii" -overwrite
#3dcalc -a output_BOLD.nii'[5]' -expr 'a' -prefix "B_test_alpha.nii" -overwrite
#3dcalc -a output_BOLD.nii'[6]' -expr 'a' -prefix "B_test_catch.nii" -overwrite
#3dcalc -a output_BOLD.nii'[7]' -expr 'a' -prefix "B_resp_rem.nii" -overwrite
#3dcalc -a output_BOLD.nii'[8]' -expr 'a' -prefix "B_resp_alpha.nii" -overwrite


 
#3dDeconvolve -num_stimts 1 -stim_file 1 new_design.txt -input normaliced_BOLD.nii -cbucket output_on_off.nii -overwrite -polort 0 -x1D tmp.design.1D -fitts fitts_on_off.nii
