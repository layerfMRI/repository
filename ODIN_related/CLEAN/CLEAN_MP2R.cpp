
// Mittelwert micalc -mask GM_Mask1.nii.gz -if tSNR_map_trad.nii
 // mit make compilieren ... alles muss von pandamonium aus passieren


//mean in mask mit " micalc -mask maskfile.nii -if timeseries.nii "

#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>

#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "Clean  < Bild > < mask > <cutoff> " << endl;}





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


    Data<float,4> mask;
  mask.autoread(filename2, FileReadOpts(), &prot);
  
  Data<float,4> data1;
  data1.resize(nrep,sizeSlice,sizePhase,sizeRead);
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


int N = nrep ; 



double vec_n[N]  ;
double vec_nn[N]  ;

cout << " nrep " <<  nrep  << endl; 
cout << " cutoff " <<  cutoff  << endl; 

	//ohne zwischen räume
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    if ( mask(0,islice,iy,ix) > cutoff   ){

            data1(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix);

         
	
//cout << " file1(timestep  ,islice,iy,ix) " << file1(timestep  ,islice,iy,ix) << endl; 
// debug
	  // data2(timestep/2,islice,iy,ix) = data2(timestep/2,islice,iy,ix) / BOLDa(timestep/2,islice,iy,ix);

	    }
	    else { 
	    	data1(timestep,islice,iy,ix)=  0.; 
	    }
        }
      }
    }
//cout << timestep << endl; 
   }

//cout << " bis hier2 " << endl; 




//cout << " bis hier3 " << endl; 


  data1.autowrite("cleaned"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
