

%%% RENZO %%%
%%% Spielwiese



clear;
addpath('/home/raid1/lhuber/Desktop/Mat_Spielwiese');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Paths, constants      %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read
path_Nulled     = './VASO_Basis.nii';
path_Not_Nulled = './BOLD_Basis.nii';

path_GM         = './GM_Mask.nii';
path_cluster    = './cluster.nii';

%write
pathVASOraus = './VASO_pure.nii';
pathBOLDraus = './BOLD_pure.nii';

pathVASOpara = './VASO_para.nii';
pathBOLDpara = './BOLD_para.nii';

pathdVASO = './dVASO.nii';
pathdBOLD = './dBOLD.nii';

%physiology
TR = 3.0;
CBVr = 0.055;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% %READ and ALLOCATE
addpath('./nifti_view/Nifti_view'); %%% for including of nii files %%%
Nulled = load_untouch_nii(path_Nulled);
Not_Nulled = load_untouch_nii(path_Not_Nulled);
cluster_nii = load_untouch_nii(path_cluster);
GM_mask_nii = load_untouch_nii(path_GM);
cluster = double(cluster_nii.img(:,:,:));
GM_mask = double(GM_mask_nii.img(:,:,:));
[phase_dim,read_dim,slice_dim,t_dim]=size(Nulled.img);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%BOLD correction
interpol_Nulled = double( Nulled.img(:,:,:,2:2:t_dim));
interpol_Not_Nulled = double(Not_Nulled.img(:,:,:,3:2:t_dim+1));
VASO = interpol_Nulled;
BOLD = interpol_Not_Nulled;

t_dim = (t_dim) / 2;

%interpol_VASO=interp1(t_dim_vec,VASO.img(:,:,:,:),t_dim_interpol_vec,'linear');

         % BOLD correction of nulled_and Notnulled images
         VASO(:,:,:,1)=interpol_Nulled(:,:,:,1)./interpol_Not_Nulled(:,:,:,1); 
         for i=2:t_dim-1
            VASO(:,:,:,i)=2*interpol_Nulled(:,:,:,i)./(interpol_Not_Nulled(:,:,:,i-1)+interpol_Not_Nulled(:,:,:,i+1)); 
         end;
         VASO(:,:,:,t_dim)=interpol_Nulled(:,:,:,t_dim)./interpol_Not_Nulled(:,:,:,t_dim-1);
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% % TO DO Signal drift correction
  
  % write out
    BOLDtest_nii=make_nii(BOLD,[],[],16);
    save_nii(BOLDtest_nii,pathBOLDraus);

    VASOtest_nii=make_nii(VASO,[],[],16);
    save_nii(VASOtest_nii,pathVASOraus);
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Average over N paradigmes in order to reduce voxelwise noise 
  N_para = 6;
  steps_in_para = t_dim / 6.;
  
  %allocate
  VASO_1para = zeros (phase_dim,read_dim,slice_dim,steps_in_para);
  BOLD_1para = zeros (phase_dim,read_dim,slice_dim,steps_in_para);
  
  
  for i=1:t_dim
   VASO_1para(:,:,:,mod(i,steps_in_para)+1) = VASO_1para(:,:,:,mod(i,steps_in_para)+1) +  VASO(:,:,:,i)/double(N_para);
   BOLD_1para(:,:,:,mod(i,steps_in_para)+1) = BOLD_1para(:,:,:,mod(i,steps_in_para)+1) +  BOLD(:,:,:,i)/double(N_para);
  end;
  %write out
   BOLDpara_nii=make_nii(BOLD_1para,[],[],16);
   save_nii(BOLDpara_nii,pathBOLDpara);
   VASOpara_nii=make_nii(VASO_1para,[],[],16);
   save_nii(VASOpara_nii,pathVASOpara)
  
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Voxel wise dCBV and dBOLD map
  
  %allocate
  dBOLD = zeros (phase_dim,read_dim,slice_dim);
  dVASO = zeros (phase_dim,read_dim,slice_dim);
  
meandCBV = 0;
meandBOLD = 0;
clustersize = 0.;

      for ix=1:phase_dim
          for iy=1:read_dim
              for islice = 1:slice_dim
                    dCBV =  - (mean(VASO_1para(ix,iy,islice,14:20))- mean(VASO_1para(ix,iy,islice,4:10)))/mean(VASO_1para(ix,iy,islice,4:10))*1/GM_mask(ix,iy,islice)*1/CBVr ; 
                  if (cluster(ix,iy,islice)>0 &  dCBV > 0.01 & dCBV < 0.8)
                    dBOLD(ix,iy,islice) = (mean(BOLD_1para(ix,iy,islice,14:20))- mean(BOLD_1para(ix,iy,islice,4:10)))/mean(BOLD_1para(ix,iy,islice,4:10));
                    dVASO(ix,iy,islice) = - (mean(VASO_1para(ix,iy,islice,14:20))- mean(VASO_1para(ix,iy,islice,4:10)))/mean(VASO_1para(ix,iy,islice,4:10))*1/GM_mask(ix,iy,islice)*1/CBVr;
                    meandCBV  = meandCBV + dVASO(ix,iy,islice);
                    meandBOLD = meandBOLD + dBOLD(ix,iy,islice);
                    clustersize = clustersize + 1 ;
                  else 
                    dBOLD(ix,iy,islice) = 0; 
                    dVASO(ix,iy,islice) = 0;
                
                  end; 
              end   
          end
      end;
mean_dCBV = meandCBV/clustersize
mean_dBOLD = meandBOLD/clustersize
  
%write out
    dBOLD_nii=make_nii(dBOLD,[],[],16);
    save_nii(dBOLD_nii,pathdBOLD);

    dVASO_nii=make_nii(dVASO,[],[],16);
    save_nii(dVASO_nii,pathdVASO);

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Timecourses in two ways, 1.) averaged over all clustered voxels during whole experiment and 2.) averaged over all clustered voxel averaged over 6 repetitions

%Allocation
VASO_timecourse = zeros(2,t_dim);
BOLD_timecourse = zeros(2,t_dim);
VASO_timecourse(1,:) = linspace(0,(t_dim-1)*TR,t_dim);    %VASO starts at t=0 
BOLD_timecourse(1,:) = linspace(TR/2,(t_dim-0.5)*TR,t_dim); %BOLD starts at t=TR/2
VASO_timecourse_para_m = zeros(N_para,steps_in_para);
BOLD_timecourse_para_m = zeros(N_para,steps_in_para);
VASO_timecourse_para = zeros(3,steps_in_para);
BOLD_timecourse_para = zeros(3,steps_in_para);
VASO_timecourse_para(1,:) = linspace(0,(steps_in_para-1)*TR,steps_in_para);
BOLD_timecourse_para(1,:) = linspace(TR/2,(steps_in_para-0.5)*TR,steps_in_para);

for i=1:t_dim
     for ix=1:phase_dim
          for iy=1:read_dim
              for islice = 1:slice_dim
                  if (dVASO(ix,iy,islice)>0)
                        
                     VASO_timecourse(2,i) = VASO_timecourse(2,i) + VASO(ix,iy,islice,i)/clustersize;
                     BOLD_timecourse(2,i) = BOLD_timecourse(2,i) + BOLD(ix,iy,islice,i)/clustersize;
                     
                     VASO_timecourse_para_m(uint16(i/steps_in_para+0.49999),mod(i,steps_in_para)+1) =  VASO_timecourse_para_m(uint16(i/steps_in_para+0.49999),mod(i,steps_in_para)+1) + VASO(ix,iy,islice,i)/clustersize;
                     BOLD_timecourse_para_m(uint16(i/steps_in_para+0.49999),mod(i,steps_in_para)+1) =  BOLD_timecourse_para_m(uint16(i/steps_in_para+0.49999),mod(i,steps_in_para)+1) + BOLD(ix,iy,islice,i)/clustersize;
                        %uint16(i/steps_in_para+0.49999) is expected to give me the time within one activation-rest-periode
                  end; 
              end; 
          end;
      end;
end;


VASO_timecourse_para(2,:) = mean(VASO_timecourse_para_m);
VASO_timecourse_para(3,:) = std(VASO_timecourse_para_m,0,1);  % is this implemented correctly? 
meanS_VASO = mean(VASO_timecourse_para(2,4:10));
VASO_timecourse_para(2,:) = VASO_timecourse_para(2,:)./meanS_VASO; % normalize signal change to 1 
VASO_timecourse_para(3,:) = VASO_timecourse_para(3,:)./meanS_VASO; % also errorbars must be scaled respectively 

BOLD_timecourse_para(2,:) = mean(BOLD_timecourse_para_m);
BOLD_timecourse_para(3,:) = std(BOLD_timecourse_para_m,0,1);
meanS_BOLD = mean(BOLD_timecourse_para(2,4:10));
BOLD_timecourse_para(2,:) = BOLD_timecourse_para(2,:)./meanS_BOLD;
BOLD_timecourse_para(3,:) = BOLD_timecourse_para(3,:)./meanS_BOLD;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% POLT timecourse

figure(1)
subplot(4,1,1)
errorbar(VASO_timecourse_para(1,:),VASO_timecourse_para(2,:),VASO_timecourse_para(3,:));
 title('VASO')
 xlabel('time in s')
 ylabel('Signal')
 subplot(4,1,2)
errorbar(BOLD_timecourse_para(1,:),BOLD_timecourse_para(2,:),BOLD_timecourse_para(3,:));
 title('BOLD')
 xlabel('time in s')
 ylabel('Signal')
 subplot(4,1,3)
plot(VASO_timecourse(1,:),VASO_timecourse(2,:));
 title('VASO all 6 paradigms')
 xlabel('time in s')
 ylabel('Signal')
 subplot(4,1,4)
plot(BOLD_timecourse(1,:),BOLD_timecourse(2,:));
 title('BOLD all 6 paradigms')
 xlabel('time in s')
 ylabel('Signal')



