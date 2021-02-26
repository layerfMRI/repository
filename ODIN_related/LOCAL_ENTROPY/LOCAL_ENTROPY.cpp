
// Ausführen mit . ./layers border_example_resized.nii brain_maskexample_resized.nii 0

 // mit make compilieren ... alles muss von pandamonium aus passieren
 
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

void usage() { cout << "file  < dataset >   <vincinity (int) > " << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  int vincinity(atoi(argv[2])); 

  Range all=Range::all();
  
  
  Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  
cout << "bis hier 1 " << endl; 

  Data<float,4> file1;
  file1.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file1.extent(firstDim);
  int sizeSlice=file1.extent(secondDim);
 //sizeSlice = 1; // only for debugging. tp make it faster 
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);


cout << "1nrep=" << nrep  << "  sizeSlice=" << sizeSlice  << "  sizePhase=" << sizePhase  << "  sizeRead=" << sizeRead  << endl; 

  Data<float,4> localMean;
  localMean.resize(1,sizeSlice,sizePhase,sizeRead);
  localMean=0.0;
  
  Data<float,4> localSTD;
  localSTD.resize(1,sizeSlice,sizePhase,sizeRead);
  localSTD=0.0;

  Data<float,4> localSNR0;
  localSNR0.resize(1,sizeSlice,sizePhase,sizeRead);
  localSNR0=0.0;



float dist (float x1, float y1, float x2, float y2) ; 


cout << "bis hier 2 " << endl; 


// Reduce mask to contain only Areas close to the curface. 



//////////////////////////////////
///// vector allocation     /////////
//////////////////////////////////


cout << "nrep = " << nrep << endl; 
int vincint =  vincinity  ; // 
int voxinvinc = (vincinity * 2 + 1) * (vincinity * 2 + 1); // 


cout << "voxinvinc = " << voxinvinc << endl;
cout << "vincint = " << vincint << endl;

double VecMean[voxinvinc] ; 
double VecDiff[voxinvinc] ; 

int dummy_index = 0; 

for (int i = 0; i < voxinvinc; i++) {
  VecMean[i] = 0.;

}

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		//cout << "6nrep=" << nrep  << "  sizeSlice=" << sizeSlice  << "  sizePhase=" << sizePhase  << "  sizeRead=" << sizeRead  << endl; 

		//cout << islice=" << islice <<  "  iy=" << iy <<  "  ix=" << ix <<  endl; 

		for (int l = 0; l < voxinvinc; l++) {
		   VecMean[l] = 0.; 
		}
		dummy_index = 0; 

	    	for(    int iy_i=max(0,iy-vincint); iy_i<min(iy+vincint,sizePhase); ++iy_i){
	     	    for(int ix_i=max(0,ix-vincint); ix_i<min(ix+vincint,sizeRead ); ++ix_i){

			VecMean[dummy_index] = file1(0,islice,iy_i,ix_i) ; 
			dummy_index++;  

	  	    }
	  	}
		
		localMean(0,islice,iy,ix) = gsl_stats_mean (VecMean,  1, dummy_index) ; 
	   	localSTD (0,islice,iy,ix) = gsl_stats_sd_m(VecMean, 1, dummy_index,  gsl_stats_mean (VecMean, 1, dummy_index)); 
		localSNR0(0,islice,iy,ix) = localMean(0,islice,iy,ix) / localSTD (0,islice,iy,ix) ; 

        }
//cout << "dummy_index " << dummy_index <<  " VecMean[dummy_index]  " << VecMean[dummy_index-1] <<  endl; 
      }
    }
 
//thickness.autowrite("thickness.nii", wopts, &prot);
localMean.autowrite("LocalMean_"+filename1, wopts, &prot);
localSTD.autowrite("LocalSTD_"+filename1, wopts, &prot);
//localSNR0.autowrite("LocalSNR0_"+filename1, wopts, &prot);
 // koord.autowrite("koordinaten.nii", wopts, &prot);
  return 0;
}



  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }


