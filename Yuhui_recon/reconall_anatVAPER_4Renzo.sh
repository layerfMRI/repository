#!/bin/sh
dataDIR=~/Data/Audiovisual_motion
batchDir=~/Data/Audiovisual_motion/batch

cd ${dataDIR}

for patID in 190907LEE_MAY.renzo; do
{	
	echo "***************************** start with ${patID} *********************"
	patDIR=${dataDIR}/${patID}/vaso_wholebrain.sft
	cd ${patDIR}

	template=mean.vaso.masked.nii

	3dUnifize -input ${template} -prefix uni.${template} -overwrite

	DenoiseImage -d 3 -n Rician -i uni.${template} -o denoise.uni.${template}

	echo "++ brain2epi.nii is the mp2rage image in epi space"
	3dUnifize -input brain2epi.nii -prefix uni.brain2epi.nii -overwrite

	echo "++ add empty slices on each direction of vaso as the vaso coverage is too small to merge with mp2rage"
	3dZeropad -I 40 -S 40 -A 40 -P 40 -L 40 -R 40 -prefix pad0.denoise.uni.${template} denoise.uni.${template} -overwrite

	echo "++ resample brain into vaso resolution"
	3dresample -master pad0.denoise.uni.${template} -rmode Bk -overwrite -prefix resmp.uni.brain2epi.nii \
		-input uni.brain2epi.nii

	echo "++ add the missing brain part into vaso"
	# # check alignment betw input and MNI 
	# # tkregister2 --mgz --s Surf_denoise_addcerebellum --fstal
	3dcalc -a pad0.denoise.uni.${template} -b resmp.uni.brain2epi.nii -expr "a+b*iszero(a)" \
		-prefix recon.${template} -overwrite

	rm zeropadded.uni.${template} resmp.uni.brain2epi.nii uni.${template} uni.brain2epi.nii

	echo "++ run recon-all without skullstrip"
	export SUBJECTS_DIR=${patDIR}
	# A: If your skull-stripped volume does not have the cerebellum, then no. If it does, then yes, however you will have to run the data a bit differently.
	# First you must run only -autorecon1 like this: 
	# recon-all -autorecon1 -noskullstrip -s <subjid>
	recon-all -i recon.${template} -subjid Surf_denoise_addcerebellum -autorecon1 -noskullstrip -hires

	echo "++ check alignment betw input and MNI"
	# tkregister2 --mgz --s Surf_denoise_addcerebellum --fstal


	#@# Nu Intensity Correction Sat Oct 26 12:25:45 EDT 2019
	cd ${patDIR}/Surf_denoise_addcerebellum/mri
	mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --cm --n 2
	mri_add_xform_to_header -c ${patDIR}/Surf_denoise_addcerebellum/mri/transforms/talairach.xfm nu.mgz nu.mgz
	#@# Intensity Normalization Sat Oct 26 12:30:07 EDT 2019
	mri_normalize -g 1 -mprage -noconform nu.mgz T1.mgz

	cd ${patDIR}
	cp Surf_denoise_addcerebellum/mri/T1.mgz Surf_denoise_addcerebellum/mri/brainmask.auto.mgz
	cp Surf_denoise_addcerebellum/mri/T1.mgz Surf_denoise_addcerebellum/mri/brainmask.mgz

	# Then you will have to make a symbolic link or copy T1.mgz to brainmask.auto.mgz and a link from brainmask.auto.mgz to brainmask.mgz. 
	# Finally, open this brainmask.mgz file and check that it looks okay 
	# (there is no skull, cerebellum is intact; use the sample subject bert that comes with your FreeSurfer 
	# installation to make sure it looks comparable). From there you can run the final stages of recon-all: 
	# recon-all -autrecon2 -autorecon3 -s <subjid>
	recon-all -s Surf_denoise_addcerebellum -autorecon2 -autorecon3 -hires -parallel -openmp 3 #-xopts-overwrite -expert ${batchDir}/reconall.expert



}&
done
wait



