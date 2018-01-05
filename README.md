# repository
this does everything: preprocessing, BOLD correction of VASO, motion correction, layering etc. Mostly C++ with a bit of Matlab here and there

90% of it is in C++, 
very little bit in matlab/SPM

Most of the C++ evaluations uses a nii O/I from ODIN. Since it is a bit involved to install I use it in a virtual box. 
My virtual box can be downloaded here: https://nimhactivecho.nimh.nih.gov/t/libijxy7

Example fMRI data of layer activity can be downloaded here: https://activecho.cit.nih.gov/t/i5d1hoj6

For example pipelines see www.layerfMRI.com

E.g.:
 
-> example on how to obtain layers in EPI-space see: https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/

-> example on a VASO evaluation scheme including BOLD correction and VASO-specific motion correction see: https://layerfmri.com/2017/11/25/motion-and-bold-correction/

-> A documentation on how to use the scand-alone C++ nifti-i/o can be found here: https://layerfmri.com/2017/11/30/using-a-standalone-nii-i-o-in-c/




