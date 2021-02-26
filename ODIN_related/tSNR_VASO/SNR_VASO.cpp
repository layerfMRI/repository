
// Mittelwert micalc -mask GM_Mask1.nii.gz -if tSNR_map_trad.nii
 // mit make compilieren ... alles muss von pandamonium aus passieren


//mean in mask mit " micalc -mask maskfile.nii -if timeseries.nii "
  
#include <odindata/data.h>
#include <odindata/fileio.h>
#include <math.h> 
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>

#define PI 3.14159265; 

//#include "utils.hpp"

void usage() { cout << "AntiBold  < Bild > <cutoff> " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  float cutoff(atoi(argv[2]));

  Range all=Range::all();
  
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> file1;
  file1.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file1.extent(firstDim);
  int sizeSlice=file1.extent(secondDim);
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);


int N = (nrep-3)/2. ; 


  Data<float,4> data1;
  data1.resize(N,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  

  Data<float,4> data2;
  data2.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> tSNR_nulled;
  tSNR_nulled.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_nulled=0.0;

  
   Data<float,4> mean;
  mean.resize(1,sizeSlice,sizePhase,sizeRead);
  mean=0.0;


double vec_n[N]  ;
double vec_nn[N]  ;

cout << " nrep " <<  nrep  << endl; 

	//ohne zwischen räume
  for(int timestep=0; timestep<nrep-3; timestep = timestep + 2) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    

            //data1(timestep/2,islice,iy,ix) = file1((timestep+2),islice,iy,ix);   // this is BOLD 
            data1(timestep/2,islice,iy,ix) = file1((timestep+3),islice,iy,ix);   // this is VASO 
         
	
//cout << " file1(timestep  ,islice,iy,ix) " << file1(timestep  ,islice,iy,ix) << endl; 
// debug
	  // data2(timestep/2,islice,iy,ix) = data2(timestep/2,islice,iy,ix) / BOLDa(timestep/2,islice,iy,ix);

	    
	   
        }
      }
    }
//cout << timestep << endl; 
   }

//cout << " bis hier2 " << endl; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	   if ( file1(0,islice,iy,ix) > cutoff &&  file1(0,islice,iy,ix) < 100000000){
		for(int timestep=0; timestep<N ; timestep ++) {

		vec_n[(int)timestep]  = data1(timestep,islice,iy,ix); 
	   	 }

	    tSNR_nulled(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, N) /gsl_stats_sd_m(vec_n, 1, N,  gsl_stats_mean (vec_n, 1, N));
	   //tSNR_nulled(0,islice,iy,ix) = gsl_stats_sd_m(vec_n, 1, N-2,  gsl_stats_mean (vec_n, 1, N-2));
		//cout << " tSNR_nulled(0,islice,iy,ix) " << tSNR_nulled(0,islice,iy,ix) << endl; 
		//gsl_vector_set_zero (my_gsl_vec_n);
	    	    mean(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, N) ;
          }
	 else 	{
		tSNR_nulled(0,islice,iy,ix)= 0.; 
		}
        }
      } 
     }


     
     
     

// Intensity correction: 


  Data<float,4> tSNR_intens;
  tSNR_intens.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_intens=0.0;

  
  Data<float,4> mean_intens;
  mean_intens.resize(1,sizeSlice,sizePhase,sizeRead);
  mean_intens=0.0;


double N_voxels_sl_tsnr = 0.; 
double intens_sl_tsnr = 0.; 
double intens_sl_mean = 0.; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    
	  if (file1(0,islice,iy,ix) > cutoff){
	    
	    intens_sl_tsnr = intens_sl_tsnr + tSNR_nulled(0,islice,iy,ix) ; 
	    intens_sl_mean = intens_sl_mean + mean(0,islice,iy,ix) ; 
	    N_voxels_sl_tsnr  = N_voxels_sl_tsnr + 1; 
	  
	  }
	}
      }
      
      cout << "slice " << islice << " has "<<   N_voxels_sl_tsnr<< " voxels  with mean  intensity " << intens_sl_tsnr/N_voxels_sl_tsnr << endl; 
      
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    
	  if (file1(0,islice,iy,ix) > cutoff){
	    
	   tSNR_intens(0,islice,iy,ix)  =  tSNR_nulled(0,islice,iy,ix) / (intens_sl_tsnr / N_voxels_sl_tsnr); 
	   mean_intens(0,islice,iy,ix)  =  mean(0,islice,iy,ix)        / (intens_sl_mean / N_voxels_sl_tsnr); 

	  
	  }
	}
      }
      
         N_voxels_sl_tsnr = 0.; 
	 intens_sl_tsnr = 0.; 
	 intens_sl_mean = 0.; 
      
    }

    
    
    




//cout << " bis hier3 " << endl; 

   //data1.autowrite("Debug_"+filename1, wopts, &prot);
   tSNR_nulled.autowrite("VASO_tSNR_"+filename1, wopts, &prot);
   mean.autowrite("VASO_MEAN_"+filename1, wopts, &prot);
   tSNR_intens.autowrite("VASO_intens"+filename1, wopts, &prot);
   //mean_intens.autowrite("VASO_MEAN_intens"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
