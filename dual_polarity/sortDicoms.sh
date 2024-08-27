#============= DICOM conversion ============#
subj="S01"
num_dummies=1
printf -v rootDir "/Volumes/china2/rhythmicVersusDiscrete/%s" ${subj}
rawDir=${rootDir}/DICOMS
runs=(01)
cd ${rawDir}

#Sort DICOMS with mripy-package:
sort_dicom.py -l

#Now insert the right numbers which specify the run number:
sort_dicom.py -o raw_fmri -c T1 5 3 4 bold01 8 bold01_phase 9 nulled 12 notNulled 14
mv ${rawDir}/raw_fmri ${rootDir}


#========== Dicom convert ===============#
mkdir ${rootDir}/results #non perpendicluar
outputNames=("MP2RAGE_UNI.nii" "MP2RAGE_INV1.nii" "MP2RAGE_INV2.nii" \
             "noNORDIC_bold_01.nii" "noNORDIC_bold_01phase.nii"      \
             "nulled.nii" "notNulled.nii")
counter=0
for data in "T101" "T102" "T103" \
            "bold01" "bold01_phase" \
            "nulled" "notNulled"; do
    cd ${rootDir}/raw_fmri/${data}
    dcm2niix . 
    mv ./*.nii ${rootDir}/results/${outputNames[${counter}]}
    counter=$(echo $(( ${counter} + 1 )) )
done


#========== Remove dummies ===============#
cd ${rootDir}/results
for run in ${runs[@]} ; do
3dTcat -prefix noNORDIC_bold_${run}.nii -overwrite noNORDIC_bold_${run}.nii"[${num_dummies}..$]"
3dTcat -prefix noNORDIC_bold_${run}phase.nii -overwrite noNORDIC_bold_${run}phase.nii"[${num_dummies}..$]"
done

#============= Divide into the two read directions (polarities) ============#
for run in ${runs[@]} ; do
3dcalc -short -prefix noNORDIC_bold_${run}_dp1.nii -a noNORDIC_bold_${run}.nii'[0..$(2)]' -expr 'a'
3dcalc -short -prefix noNORDIC_bold_${run}_dp2.nii -a noNORDIC_bold_${run}.nii'[1..$(2)]' -expr 'a' 

3dcalc -short -prefix noNORDIC_bold_${run}phase_dp1.nii -a noNORDIC_bold_${run}phase.nii'[0..$(2)]' -expr 'a'
3dcalc -short -prefix noNORDIC_bold_${run}phase_dp2.nii -a noNORDIC_bold_${run}phase.nii'[1..$(2)]' -expr 'a' 

3dcalc -short -prefix noNORDIC_bold_${run}phase.nii -a noNORDIC_bold_${run}phase.nii -expr 'a' -overwrite #Reduce file size
done

