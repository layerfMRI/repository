
  
#include <odindata/data.h>
#include <odindata/fileio.h>
#include <math.h> 
#include <cstdlib>
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>

#define PI 3.14159265; 

//#include "utils.hpp"

int N_rand = 1000;
double_t lower = -10;
double_t upper = 10;

double verteilung(double x);
typedef double (*Functions)(double);
Functions pFunc = verteilung;

double_t arb_pdf_num(int N_rand, double (*pFunc)(double), double_t lower, double_t upper);
double adjusted_rand_numbers(double mean, double stdev, double value );


void usage() { cout << "NOISE me  < Bild > " << endl;}


int main(int argc,char* argv[]) {

///// DEBUGGING /////
/*
  ofstream outf("data.dat"); // loog at the ditsribution with "plot 'data.dat' w points"
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  for (int i = 0; i < 10000 ; i++) {
  	//	outf<<verteilung(i)<< endl;
        outf<< adjusted_rand_numbers(100., 3., arb_pdf_num(N_rand, pFunc, lower, upper)) << "  " << i << endl;
        cout<< adjusted_rand_numbers(100., 3., arb_pdf_num(N_rand, pFunc, lower, upper)) << endl;
  }
*/


  if (argc!=2) {usage(); return 0;}
  STD_string filename1(argv[1]);


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

int Nrep = nrep ; 


  Data<float,4> tSNR_orig;
  tSNR_orig.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_orig=0.0;

  Data<float,4> VAR_orig;
  VAR_orig.resize(1,sizeSlice,sizePhase,sizeRead);
  VAR_orig=0.0;

  Data<float,4> mean_orig;
  mean_orig.resize(1,sizeSlice,sizePhase,sizeRead);
  mean_orig=0.0;

  Data<float,4> data_noise;
  data_noise.resize(Nrep,sizeSlice,sizePhase,sizeRead);
  data_noise=0.0;

  Data<float,4> tSNR_noise;
  tSNR_noise.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNR_noise=0.0;

  Data<float,4> mean_noise;
  mean_noise.resize(1,sizeSlice,sizePhase,sizeRead);
  mean_noise=0.0;

double vec_n[Nrep]  ;

cout << " nrep " <<  nrep  << endl; 


    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int timestep=0; timestep<Nrep ; timestep ++) {
			vec_n[(int)timestep]  = file1(timestep,islice,iy,ix); 
	   	 }
	    		tSNR_orig(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, Nrep) /gsl_stats_sd_m(vec_n, 1, Nrep,  gsl_stats_mean (vec_n, 1, Nrep));
	    	    	mean_orig(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, Nrep) ;
			VAR_orig(0,islice,iy,ix)  = gsl_stats_sd_m(vec_n, 1, Nrep,  gsl_stats_mean (vec_n, 1, Nrep));

          }
        }
      } 
     

cout << " Call me (lechz) " << endl; 
    
// NOISE the time series
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int timestep=0; timestep<Nrep ; timestep ++) {
			data_noise(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix) + adjusted_rand_numbers(0, VAR_orig(0,islice,iy,ix), arb_pdf_num(N_rand, pFunc, lower, upper)); 
			//data_noise(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix) + adjusted_rand_numbers(0, 0.03, arb_pdf_num(N_rand, pFunc, lower, upper)); 
	   	 }
          }
        }
      } 
     
cout << " Call me again " << endl; 



    for(int islice=0; islice<sizeSlice; ++islice){
cout << " slice  " <<islice << " of " << sizeSlice << endl;

      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int timestep=0; timestep<Nrep ; timestep ++) {
			vec_n[(int)timestep]  = data_noise(timestep,islice,iy,ix); 
	   	 }
	    		tSNR_noise(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, Nrep) /gsl_stats_sd_m(vec_n, 1, Nrep,  gsl_stats_mean (vec_n, 1, Nrep));
	    	    	mean_noise(0,islice,iy,ix) = gsl_stats_mean (vec_n, 1, Nrep) ;

          }
        }
      } 


//cout << " bis hier3 " << endl;
 
   VAR_orig.autowrite("VAR_orig_"+filename1, wopts, &prot);
   tSNR_orig.autowrite("tSNR_orig_"+filename1, wopts, &prot);
   mean_orig.autowrite("MEAN_orig_"+filename1, wopts, &prot);
   data_noise.autowrite("Noisier_"+filename1, wopts, &prot);
   tSNR_noise.autowrite("tSNR_noisy_"+filename1, wopts, &prot);
   mean_noise.autowrite("MEAN_noisy_"+filename1, wopts, &prot);


  return 0;

}

// Gauss     lower = -5 , upper = 5
double verteilung(double z){
    return exp(-z*z/(2.))*1./sqrt(2.*M_PI);
}


double_t arb_pdf_num(int N_rand, double (*pFunc)(double), double_t lower, double_t upper){
	double_t binwidth = (upper - lower)/(double_t)N_rand;
	double_t integral = 0.0 ;
	double_t rand_num = rand()/(double_t)RAND_MAX;
	int i;
	
	for (i = 0; integral < rand_num ; i++){
		integral += pFunc(lower + (double_t) i *binwidth)*binwidth ;
	
		if ((lower + (double_t) i*binwidth ) > upper ) {
		  cout << " upper limit, vielleicht sollte da limit angepasst werden "<< i << endl;
		 return lower + (double_t) i *binwidth ;
		}
	}
	return lower + (double_t) i *binwidth ;
}


double adjusted_rand_numbers(double mean, double stdev, double value ){
return value*stdev+mean;
}


