
%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%

root_dir = '/Users/huberl/NeuroDebian/160527_Javier_Ich/a_la_Barbara/EPI' ;
read_name = 'ampl.nii' ;



%%%%%%%%%%% END OF USER PARAMETERS %%%%%%%%%%%

read_file = fullfile(root_dir,read_name) ;
read_nii = load_untouch_nii(read_file) ;

% get dimensions
[phase_dim,read_dim,slice_dim,t_dim]=size(read_nii.img)


read_nii = double(read_nii.img(:,:,:));

     for ix=1:phase_dim
          for iy=1:read_dim
              for islice = 1:slice_dim
                  if (read_nii(ix,iy,islice,1)<0)
                    read_nii(ix,iy,islice,1) = 0 ;
                  end; 
              end   
          end
      end;



write_nii = make_nii(read_nii) ;


write_file = fullfile(root_dir, 'output_2.nii') ;
save_nii(write_nii, write_file) ;









