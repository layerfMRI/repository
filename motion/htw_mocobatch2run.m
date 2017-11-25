%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
%%
matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                    {
  './Basis_a.nii,1'
'./Basis_a.nii,2'
'./Basis_a.nii,3'
'./Basis_a.nii,4'
'./Basis_a.nii,5'
'./Basis_a.nii,6'
'./Basis_a.nii,7'
'./Basis_a.nii,8'
'./Basis_a.nii,9'
'./Basis_a.nii,10'
'./Basis_a.nii,11'
'./Basis_a.nii,12'
'./Basis_a.nii,13'
'./Basis_a.nii,14'
'./Basis_a.nii,15'
'./Basis_a.nii,16'
'./Basis_a.nii,17'
'./Basis_a.nii,18'
'./Basis_a.nii,19'
'./Basis_a.nii,20'
'./Basis_a.nii,21'
'./Basis_a.nii,22'
'./Basis_a.nii,23'
'./Basis_a.nii,24'
'./Basis_a.nii,25'
'./Basis_a.nii,26'
'./Basis_a.nii,27'
'./Basis_a.nii,28'
'./Basis_a.nii,29'
'./Basis_a.nii,30'
'./Basis_a.nii,31'
'./Basis_a.nii,32'
'./Basis_a.nii,33'
'./Basis_a.nii,34'
'./Basis_a.nii,35'
'./Basis_a.nii,36'
'./Basis_a.nii,37'
'./Basis_a.nii,38'
'./Basis_a.nii,39'
'./Basis_a.nii,40'
'./Basis_a.nii,41'
'./Basis_a.nii,42'
'./Basis_a.nii,43'
'./Basis_a.nii,44'
'./Basis_a.nii,45'
'./Basis_a.nii,46'
'./Basis_a.nii,47'
'./Basis_a.nii,48'
'./Basis_a.nii,49'
'./Basis_a.nii,50'
'./Basis_a.nii,51'
'./Basis_a.nii,52'
'./Basis_a.nii,53'
'./Basis_a.nii,54'
'./Basis_a.nii,55'
'./Basis_a.nii,56'
'./Basis_a.nii,57'
'./Basis_a.nii,58'
'./Basis_a.nii,59'
'./Basis_a.nii,60'
'./Basis_a.nii,61'
'./Basis_a.nii,62'
'./Basis_a.nii,63'
'./Basis_a.nii,64'
'./Basis_a.nii,65'
'./Basis_a.nii,66'
'./Basis_a.nii,67'
'./Basis_a.nii,68'
'./Basis_a.nii,69'
'./Basis_a.nii,70'
'./Basis_a.nii,71'
'./Basis_a.nii,72'
'./Basis_a.nii,73'
'./Basis_a.nii,74'
'./Basis_a.nii,75'
'./Basis_a.nii,76'
'./Basis_a.nii,77'
'./Basis_a.nii,78'
'./Basis_a.nii,79'
'./Basis_a.nii,80'
'./Basis_a.nii,81'
'./Basis_a.nii,82'
'./Basis_a.nii,83'
'./Basis_a.nii,84'
'./Basis_a.nii,85'
'./Basis_a.nii,86'
'./Basis_a.nii,87'
'./Basis_a.nii,88'
'./Basis_a.nii,89'
'./Basis_a.nii,90'
'./Basis_a.nii,91'
'./Basis_a.nii,92'
'./Basis_a.nii,93'
'./Basis_a.nii,94'
'./Basis_a.nii,95'
'./Basis_a.nii,96'
'./Basis_a.nii,97'
'./Basis_a.nii,98'
'./Basis_a.nii,99'
'./Basis_a.nii,100'
'./Basis_a.nii,101'
'./Basis_a.nii,102'
'./Basis_a.nii,103'
'./Basis_a.nii,104'
'./Basis_a.nii,105'
'./Basis_a.nii,106'
'./Basis_a.nii,107'
'./Basis_a.nii,108'
'./Basis_a.nii,109'
'./Basis_a.nii,110'
'./Basis_a.nii,111'
'./Basis_a.nii,112'
'./Basis_a.nii,113'
'./Basis_a.nii,114'
'./Basis_a.nii,115'
'./Basis_a.nii,116'
'./Basis_a.nii,117'
'./Basis_a.nii,118'
'./Basis_a.nii,119'
'./Basis_a.nii,120'
                                                    }
                                                    }';
%%
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 1.2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'MOCO_';
%%


% change defaults.cmdline=0 to defaults.cmdline=true in
%the spm_defaults.m in your SPM folder.
%in /Users/huberl/SPM/spm8/spm_defaults.m 
%addpath /Users/huberl/SPM/spm8/
spm('defaults','FMRI')
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

exit

