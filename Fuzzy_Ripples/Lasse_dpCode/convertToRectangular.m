function convertToRectangular(Pmagn_DP1,Pphase_DP1,Pmagn_DP2,Pphase_DP2)
%% Do motion correction separately for each polarity based on magnitude images
% To realign and reslice images from session 1:
% RealignAmpAndPhase('magn1','phase1','magn2','phase2')
% To realign images from session 2 and hereafter reslice them to the space of session 1 
% without reslicing the reference image again
% RealignAmpAndPhase('NORDICAmpBOLD2.nii','NORDICPhaseBOLD2.nii','','NORDICAmpBOLD1.nii')

%Scale to range 0 to 2 pi
info_magn1=niftiinfo(Pmagn_DP1);
Ymagn1=single(niftiread(Pmagn_DP1));

info_magn2=niftiinfo(Pmagn_DP2);
Ymagn2=single(niftiread(Pmagn_DP2));

info_phase1=niftiinfo(Pphase_DP1);
Yphase1=single(niftiread(Pphase_DP1));

info_phase2=niftiinfo(Pphase_DP2);
Yphase2=single(niftiread(Pphase_DP2));


%Make sure images are not scaled weirdly (scaling needs to be 0 or 1 and offset needs to be 0:
sprintf('magn scaling is %d, phase scaling is %d, magn offset is %d, phase offset is %d' ...
        ,info_magn1.MultiplicativeScaling,info_phase1.MultiplicativeScaling,...
         info_magn1.AdditiveOffset,info_phase1.AdditiveOffset)

sprintf('magn scaling is %d, phase scaling is %d, magn offset is %d, phase offset is %d' ...
        ,info_magn2.MultiplicativeScaling,info_phase2.MultiplicativeScaling,...
         info_magn2.AdditiveOffset,info_phase2.AdditiveOffset)

%Scale phase data to 0-2pi range
phaseRange=max(max([Yphase1(:) Yphase2(:)]))-min(min([Yphase1(:) Yphase2(:)]));
Yphase1=((Yphase1./phaseRange)*2*pi)+pi;
Yphase2=((Yphase2./phaseRange)*2*pi)+pi;


%Write scaled phase volume to check
% niftiwrite(Yphase1,['tmpScaled_' Pphase_DP1],info_phase1)
% niftiwrite(Yphase2,['tmpScaled_' Pphase_DP2],info_phase2)

%Convert to rectangular coordinates:
Yreal1=Ymagn1.*cos(Yphase1);
Yimag1=Ymagn1.*sin(Yphase1);

Yreal2=Ymagn2.*cos(Yphase2);
Yimag2=Ymagn2.*sin(Yphase2);

%Write rectangular images:
info_magn1.Datatype='single';
info_phase1.Datatype='single';
info_magn2.Datatype='single';
info_phase2.Datatype='single';

niftiwrite(Yreal1,['tmpReal_' Pmagn_DP1],info_magn1)
niftiwrite(Yimag1,['tmpImag_' Pmagn_DP1],info_magn1)

niftiwrite(Yreal2,['tmpReal_' Pmagn_DP2],info_magn2)
niftiwrite(Yimag2,['tmpImag_' Pmagn_DP2],info_magn2)

end
