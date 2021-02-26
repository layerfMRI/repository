
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
     #include <gsl/gsl_sort_vector.h>
     #include <gsl/gsl_sort.h>
#include <gsl/gsl_vector.h>
     
  //   #include <gsl/gsl_statistics_int.h>
   //  #include <gsl/gsl_statistics.h>
 
#define PI 3.14159265; 

//#include "utils.hpp"

void usage() { cout << "VAICA  < VASO > <BOLD>  <cutoff> " << endl;}





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

  Data<float,4> VASO;
  VASO.autoread(filename1, FileReadOpts(), &prot);
  int nrep=VASO.extent(firstDim);
  int sizeSlice=VASO.extent(secondDim);
  int sizePhase=VASO.extent(thirdDim);
  int sizeRead=VASO.extent(fourthDim);
  double numb_voxels=(int)(sizeSlice*sizePhase*sizeRead) ;

  Data<float,4> BOLD;
  BOLD.autoread(filename2, FileReadOpts(), &prot);

  Data<float,4> correl4d;
  correl4d.resize(1,sizeSlice,sizePhase,sizeRead);
  correl4d=0.0;

  Data<float,4> lambda4d;
  lambda4d.resize(1,sizeSlice,sizePhase,sizeRead);
  lambda4d=0.0;

  Data<float,4> sumsqs4d;
  sumsqs4d.resize(1,sizeSlice,sizePhase,sizeRead);
  sumsqs4d=0.0;

  Data<float,4> cov4d;
  cov4d.resize(1,sizeSlice,sizePhase,sizeRead);
  cov4d=0.0;

  

cout << " nrep = " <<  nrep    <<endl; 
  

// ALLOCATOPN AND INICIATION
double vec_VASO[nrep]  ;
double vec_BOLD[nrep]  ;

double vec_VASO_mean = 0  ;
double vec_BOLD_mean = 0 ;

double vec_BOLD_VASO_corr = 0  ;
double vec_index = 0  ;

double lambda = 0.; 
double cov11 = 0.; 
double sumsq = 0.; 

double	vec_lambda = 0 ;  
double	vec_cov11 = 0 ;  
double	vec_sumsq = 0;
double	vec_sorter =0 ;


		for(int timestep = 0 ; timestep < nrep ; timestep++){ 
			vec_VASO[timestep] = 0. ; 
			vec_BOLD[timestep] = 0. ; 
		}
	


// GET TIME-COURSES FOR ALL ICAS


    for(int islice=0; islice<sizeSlice; ++islice){
	cout << " Slice  = " <<  islice << "  of " << sizeSlice    <<endl; 
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int timestep = 0 ; timestep < nrep  ; timestep++) {
			vec_VASO[timestep]  = VASO(timestep,islice,iy,ix); 
			vec_BOLD[timestep]  = BOLD(timestep,islice,iy,ix); 
			vec_VASO_mean = vec_VASO_mean +  vec_VASO[timestep]/nrep  ;  
  			vec_BOLD_mean = vec_BOLD_mean +  vec_BOLD[timestep]/nrep  ; 
	  	}

		for(int timestep = 0 ; timestep < nrep ; timestep++) {
			vec_VASO[timestep] =  vec_VASO[timestep]/vec_VASO_mean-1.  ; 
			vec_BOLD[timestep] =  vec_BOLD[timestep]/vec_BOLD_mean-1. ; 
		}
	
		vec_BOLD_VASO_corr  = gsl_stats_correlation (vec_VASO,  1, vec_BOLD ,1, nrep );

		gsl_fit_mul (vec_VASO, 1, vec_BOLD, 1, nrep , &lambda, &cov11, &sumsq) ;
		lambda4d (0,islice,iy,ix) = lambda ; 
		correl4d (0,islice,iy,ix) = vec_BOLD_VASO_corr ; 
		sumsqs4d (0,islice,iy,ix) = sumsq ; 
		cov4d (0,islice,iy,ix) = cov11 ; 

		vec_VASO_mean = 0 ;
		vec_BOLD_mean = 0 ;
        }  
      } 
    }
  
  
  


  lambda4d.autowrite("lambda4d.nii", wopts, &prot);
  correl4d.autowrite("correl4d.nii", wopts, &prot);
  sumsqs4d.autowrite("sumsqs4d.nii", wopts, &prot);
  cov4d.autowrite("cov4d.nii", wopts, &prot);

//cout << " bis hier3 " << endl; 



//cout << " bis hier4 " << endl; 

  return 0;

}
