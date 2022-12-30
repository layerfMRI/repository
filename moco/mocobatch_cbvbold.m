%numRuns=length(dir('S*.nii'));
clear;
fileID = fopen('NT.txt','r');
nTRs = fscanf(fileID,'%f');

files=dir(['Basis_cbv_*.nii']);

allFiles=[]; allFiles_a=[];
for runs=1:length(files)
    nTR=nTRs(runs);
    nTR=nTR; %make it to be even number
    base=files(runs).name;
    for TR= 1:nTR
      inst={[base ',' num2str(TR)]};
      allFiles_a=[allFiles_a; inst];
    end
end
allFiles_a = allFiles_a(1:1:end,:);  % odd matrix

allFiles={allFiles_a};

        Dataprefix=['moco_'];

    bases=1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.data = allFiles;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.sep = 1.2;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
% if you want to use the first, use rtm = 0, if you want to use the mean use rtm = 1
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.interp = 4;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.weight = {'moma.nii.gz'};
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.prefix = Dataprefix;
    



spm('defaults','FMRI')
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);




files=dir(['Basis_bold_*.nii']);

allFiles=[]; allFiles_a=[];
for runs=1:length(files)
    nTR=nTRs(runs);
    nTR=nTR; %make it to be even number
    base=files(runs).name;
    for TR= 1:nTR
      inst={[base ',' num2str(TR)]};
      allFiles_a=[allFiles_a; inst];
    end
end
allFiles_a = allFiles_a(1:1:end,:);  % odd matrix

allFiles={allFiles_a};

        Dataprefix=['moco_'];

    bases=1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.data = allFiles;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.sep = 1.2;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
% if you want to use the first, use rtm = 0, if you want to use the mean use rtm = 1
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.interp = 4;
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{bases}.spm.spatial.realign.estwrite.eoptions.weight = {'moma.nii.gz'};
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{bases}.spm.spatial.realign.estwrite.roptions.prefix = Dataprefix;
    



spm('defaults','FMRI')
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);



exit















