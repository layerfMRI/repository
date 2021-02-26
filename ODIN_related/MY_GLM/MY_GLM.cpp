
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

void usage() { cout << "AntiBold  < Bild > <1D time seires> <cutoff> " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  const char* filename2(argv[2]);
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


  Data<float,4> data1;
  data1.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  

  Data<float,4> data2;
  data2.resize(1,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> betaMAP;
  betaMAP.resize(1,sizeSlice,sizePhase,sizeRead);
  betaMAP=0.0;

  Data<float,4> cov11MAP;
  cov11MAP.resize(1,sizeSlice,sizePhase,sizeRead);
  cov11MAP=0.0;

  Data<float,4> sumsqMAP;
  sumsqMAP.resize(1,sizeSlice,sizePhase,sizeRead);
  sumsqMAP=0.0;


   ifstream infile0;
	infile0.open(filename2);
	if (!infile0 ) {
	cerr<<"Konnte die Datei nicht einlesen: "<<endl;
	return -1;
	} 

	
double inread[nrep] ; 
double number = 0.; 
int zeile = 0; 

while (infile0>>number) {

  inread[zeile] =  number; 
  //cout << "time  " << time << "   (int)(time/100)  " << (int)(time/100) << endl;  
 //   if  (time%100000 == 0 ) {
 //     cout << " M0[" << zeile <<"]["<< time <<"] = " << number << endl; 
 //   }
    zeile ++; 
}

if (zeile != nrep ) {
  cerr<<" ERROR: 1D file muss gleich dimension haben wie 4D datensatz "<<endl;
	return -1;
	} 
  
//cout << " nrep = " <<  nrep  << " zeile = " <<  zeile  << " inread[0] = " <<  inread[0]  <<endl; 
  
int N = nrep ; 



double vec_n[N]  ;
double vec_nn[N]  ;
//double work_[2*N]  ;

cout << " nrep " <<  nrep  << endl; 


//cout << " bis hier2 " << endl; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int timestep=0; timestep<N ; timestep ++) {
		vec_n[(int)timestep]  = file1(timestep,islice,iy,ix); 
	   	 }

		    data2(0,islice,iy,ix) = gsl_stats_correlation (vec_n,  1, inread,1, (N) ); 
		    //gsl_stats_correlation (const double data1[], const size_t stride1, const double data2[], const size_t stride2, const size_t n)
          

        }
      } 
     }

//##################################################
// DO GLM from hear
double vec_voxel[nrep] ;

	for(int timestep = 0 ; timestep < nrep ; timestep++){ 
			vec_voxel[timestep] = 0. ; 
		}


double lambda = 0.; 
double cov11 = 0.; 
double sumsq = 0.; 
double mean_voxel = 0.; 

		for(int timestep=0; timestep<N ; timestep ++) {
			mean_voxel = mean_voxel + inread[(int)timestep]/nrep ;
	   	 }
		for(int timestep=0; timestep<N ; timestep ++) {
			inread[(int)timestep] = (inread[(int)timestep]-mean_voxel)/mean_voxel ;
	   	 }

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){

		mean_voxel = 0;
		for(int timestep=0; timestep<N ; timestep ++) {
			vec_voxel[(int)timestep]  = file1(timestep,islice,iy,ix); 
			mean_voxel = mean_voxel + vec_voxel[(int)timestep]/nrep ; 
	   	 }

		for(int timestep=0; timestep<N ; timestep ++) {
			vec_voxel[(int)timestep]  = (vec_voxel[(int)timestep]-mean_voxel)/mean_voxel; 
			
	   	 }

		gsl_fit_mul (vec_voxel, 1, inread, 1, nrep , &lambda, &cov11, &sumsq) ; 
          	betaMAP(0,islice,iy,ix)  = lambda;
  		cov11MAP(0,islice,iy,ix) = cov11;
	  	sumsqMAP(0,islice,iy,ix) = sumsq;

        }
      } 
     }






  data2.autowrite("correl_"+filename1, wopts, &prot);
  betaMAP.autowrite("BETA_"+filename1, wopts, &prot);
  cov11MAP.autowrite("COV11_"+filename1, wopts, &prot);
  sumsqMAP.autowrite("SUMSQ_"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
