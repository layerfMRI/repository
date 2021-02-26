
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

void usage() { cout << "SM in mask  < layer1 > <layer2 > <cutoff> " << endl;}





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

  Data<float,4> mask1;
  mask1.autoread(filename1, FileReadOpts(), &prot);
  int nrep=mask1.extent(firstDim);
  int sizeSlice=mask1.extent(secondDim);
  int sizePhase=mask1.extent(thirdDim);
  int sizeRead=mask1.extent(fourthDim);

  Data<float,4> mask2;
  mask2.autoread(filename2, FileReadOpts(), &prot);

  
  Data<float,4> combined_layers;
  combined_layers.resize(nrep,sizeSlice,sizePhase,sizeRead);
  combined_layers=0.0;

 

cout << " nrep " <<  nrep  << endl; 



int numb_layers1 = 100.; // This is the maximal number of layers. I don't know how to allocate it dynamically.
int numb_layers2 = 100.; // This is the maximal number of layers. I don't know how to allocate it dynamically.

double numb_voxels1[numb_layers1] ; 
double mean_layers1[numb_layers1] ; 
double std_layers1[numb_layers1] ; 


double numb_voxels2[numb_layers2] ; 
double mean_layers2[numb_layers2] ; 
double std_layers2[numb_layers2] ; 

for (int i = 0; i < numb_layers1; i++) {
  mean_layers1[i] = 0.; 
   std_layers1[i] = 0.; 
  numb_voxels1[i] = 0.; 
}
for (int i = 0; i < numb_layers2; i++) {
  mean_layers2[i] = 0.; 
   std_layers2[i] = 0.; 
  numb_voxels2[i] = 0.; 
}

// count numer of voxels in every layer
  for(int i = 0; i < numb_layers1; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (mask1(0,islice,iy,ix) == i+1 )
		    numb_voxels1[i] ++; 
		
        }  
      } 
    }
  }

/// get actual number of layers.
for(int i = numb_layers1-1; i >= 0; i--) {
	if (numb_voxels1[i] == 0) numb_layers1 = i;
}

cout << " there are  " <<  numb_layers1  << " layers in the 1st mask " <<  endl; 

 for(int i = 0; i < numb_layers2; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (mask2(0,islice,iy,ix) == i+1 )
		    numb_voxels2[i] ++; 
		
        }  
      } 
    }
  }

/// get actual number of layers.
for(int i = numb_layers2-1; i >= 0; i--) {
	if (numb_voxels2[i] == 0) numb_layers2 = i;
}

cout << " there are  " <<  numb_layers2  << " layers in the 2nd mask " <<  endl; 

// Combination starts
  for(int timestep=0; timestep<nrep; ++timestep){
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	 
		if (mask1(timestep,islice,iy,ix) == 0 &&  mask2(timestep,islice,iy,ix) == 0 ) {
		    combined_layers(timestep,islice,iy,ix) = 0. ;
		}
		if (mask1(timestep,islice,iy,ix) != 0 &&  mask2(timestep,islice,iy,ix) == 0 ) {
		    combined_layers(timestep,islice,iy,ix) = mask1(timestep,islice,iy,ix)  ;
		}	 
		if (mask1(timestep,islice,iy,ix) == 0 &&  mask2(timestep,islice,iy,ix) != 0 ) {
		    combined_layers(timestep,islice,iy,ix) = numb_layers1 + mask2(timestep,islice,iy,ix)  ;
		}	
		if (mask1(timestep,islice,iy,ix) != 0 &&  mask2(timestep,islice,iy,ix) != 0 ) {
		    combined_layers(timestep,islice,iy,ix) = mask1(timestep,islice,iy,ix) ;
		}
        }
      } 
    }
  }

     
     
     




   combined_layers.autowrite("combined_Layers.nii", wopts, &prot);

   

//cout << " bis hier4 " << endl; 

  return 0;

}

  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float gaus (float distance, float sigma) {
    return 1./(sigma*sqrt(2.*3.141592))*exp (-0.5*distance*distance/(sigma*sigma));
  }



