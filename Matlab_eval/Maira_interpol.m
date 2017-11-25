

% to run with:    matlab -nodesktop -nosplash -r "x='example';resize;x='example1';resize;quit"
%addpath('/scr/minze1/RENZO_SCR/Auswertung_SCR/Maria_Interpolation_method/'); % location of nii toolbox

addpath('/scr/malawi1/SCR_Maria/NIfTI_20140122/');

x='example';

Ima = load_untouch_nii([x '.nii']);
temp = imresize(Ima.img, [1328 1328], 'bilinear');  % bilinear
Ima = make_nii(temp,[0.796875 0.796875 1.5]);
save_nii(Ima, [x '_resized.nii']);
