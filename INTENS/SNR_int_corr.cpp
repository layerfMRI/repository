
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

void usage() { cout << "AntiBold  < Bild Nulled > < Bild Not_Nulled > <cutoff> " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  float cutoff(atoi(argv[3]));

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

  Data<float,4> file2;
  file2.autoread(filename2, FileReadOpts(), &prot);

  
  Data<float,4> tSNR_nulled;
  tSNR_nulled.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_nulled=0.0;

  Data<float,4> tSNR_abs_nulled;
  tSNR_abs_nulled.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_abs_nulled=0.0;


  
   Data<float,4> mean;
  mean.resize(1,sizeSlice,sizePhase,sizeRead);
  mean=0.0;


int N = nrep ; 



double vec_n[N]  ;
double vec_nn[N]  ;


cout << " nrep " <<  nrep  << endl; 


//cout << " bis hier2 " << endl; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	   if ( file1(1,islice,iy,ix) > cutoff &&  file1(1,islice,iy,ix) < 100000000){
		for(int timestep=0; timestep<N-2 ; timestep = timestep + 2 ) {
			vec_n[(int)timestep]  = file1(timestep+1,islice,iy,ix); 
			vec_n[(int)timestep+1]  = file2(timestep+2,islice,iy,ix);
			vec_nn[(int)timestep/2] = file1(timestep+1,islice,iy,ix);

	   	 }

	    tSNR_nulled(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, N-2) /gsl_stats_sd_m(vec_n, 1, N-2,  gsl_stats_mean (vec_n, 1, N-2));
	    tSNR_abs_nulled(0,islice,iy,ix) = gsl_stats_mean (vec_nn, 1, (N-2)/2) /gsl_stats_sd_m(vec_nn, 1, (N-2)/2,  gsl_stats_mean (vec_nn, 1, (N-2)/2));
	   //tSNR_nulled(0,islice,iy,ix) = gsl_stats_sd_m(vec_n, 1, N-2,  gsl_stats_mean (vec_n, 1, N-2));
		//cout << " tSNR_nulled(0,islice,iy,ix) " << tSNR_nulled(0,islice,iy,ix) << endl; 
		//gsl_vector_set_zero (my_gsl_vec_n);
	    mean(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, N-2) ;
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
	    
	  if (mean(0,islice,iy,ix) > cutoff){
	    
	    intens_sl_tsnr = intens_sl_tsnr + tSNR_nulled(0,islice,iy,ix) ; 
	    intens_sl_mean = intens_sl_mean + mean(0,islice,iy,ix) ; 
	    N_voxels_sl_tsnr  = N_voxels_sl_tsnr + 1; 
	  
	  }
	}
      }
      
      cout << "slice " << islice << " has "<<   N_voxels_sl_tsnr<< " voxels  with mean  intensity " << intens_sl_tsnr/N_voxels_sl_tsnr << endl; 
      
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    
	  if (mean(0,islice,iy,ix) > cutoff){
	    
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


   tSNR_nulled.autowrite("T1_instability_"+filename1, wopts, &prot);
   tSNR_abs_nulled.autowrite("tSNR_"+filename1, wopts, &prot);
   mean.autowrite("MEAN_"+filename1, wopts, &prot);
   tSNR_intens.autowrite("T1_instability_intens"+filename1, wopts, &prot);
   mean_intens.autowrite("MEAN_intens"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
