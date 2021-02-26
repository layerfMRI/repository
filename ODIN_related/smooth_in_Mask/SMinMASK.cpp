
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

void usage() { cout << "SM in mask  < image > <mask > <kernal size x 10 in voxel size> " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  float kernal_size(atoi(argv[3]));
   kernal_size = kernal_size /10.;
 if ( kernal_size < 1. ) cout << "#########################  ERROR kennal size it 0 ##############################" << endl; 

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

  
  Data<float,4> smoothed;
  smoothed.resize(nrep,sizeSlice,sizePhase,sizeRead);
  smoothed=0.0;

  Data<float,4> gaus_weigth;
  gaus_weigth.resize(1,sizeSlice,sizePhase,sizeRead);
  gaus_weigth(all,all,all,all)=0.0;




float dist (float x1, float y1, float x2, float y2) ;
float gaus (float distance, float sigma) ;

cout << " nrep " <<  nrep  << endl; 

int vinc = max(1.,3. * kernal_size ); // if voxel is too far away, I ignore it. 
float dist_i = 0.;
cout << " vinc " <<  vinc<<  endl; 
cout << " kernal_size " <<  kernal_size<<  endl; 

 cout << "######################### NO, SM does not stad for that !!!! ##############################" << endl;



int numb_layers = 100.; // This is the maximal number of layers. I don't know how to allocate it dynamically.

double numb_voxels[numb_layers] ; 
double mean_layers[numb_layers] ; 
double std_layers[numb_layers] ; 

for (int i = 0; i < numb_layers; i++) {
  mean_layers[i] = 0.; 
   std_layers[i] = 0.; 
  numb_voxels[i] = 0.; 
}


// count numer of voxels in every layer
  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (mask(0,islice,iy,ix) == i+1 )
		    numb_voxels[i] ++; 
		
        }  
      } 
    }
  }

/// get actual number of layers.
for(int i = numb_layers-1; i >= 0; i--) {
	if (numb_voxels[i] == 0) numb_layers = i;
}

cout << " there are  " <<  numb_layers  << " layers in the mask " <<  endl; 



  for(int timestep=0; timestep<nrep; ++timestep){
  gaus_weigth(all,all,all,all)=0.0;
  cout << " timestep   " <<  timestep  << " of " <<  nrep << endl; 
   for (int ilayer = 0 ; ilayer < numb_layers ; ++ilayer){
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if (mask(0,islice,iy,ix) == ilayer+1 ){
	  
	   for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < vinc && mask(0,islice,iy_i,ix_i) == ilayer+1 ){

		    smoothed(timestep,islice,iy,ix) = smoothed(timestep,islice,iy,ix) + file1(timestep,islice,iy_i,ix_i)* gaus(dist_i ,kernal_size ) ;
		    gaus_weigth(0,islice,iy,ix) = gaus_weigth(0,islice,iy,ix) + gaus(dist_i ,kernal_size ) ;
		  }
		}  
	      }
  	   

		smoothed(timestep,islice,iy,ix) = smoothed(timestep,islice,iy,ix)/gaus_weigth(0,islice,iy,ix);
		//bias_filt(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix);
         }
        if (mask(0,islice,iy,ix) == 0 ){
		//smoothed(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix); //RENZO change this is you want clened figs.
		smoothed(timestep,islice,iy,ix) = 0.;
		
	 }
        }
      } 
     }
    }
  }

     
     
     




   smoothed.autowrite("smoothed_"+filename1, wopts, &prot);
   gaus_weigth.autowrite("gaus_weigth.nii", wopts, &prot);
   

//cout << " bis hier4 " << endl; 

  return 0;

}

  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float gaus (float distance, float sigma) {
    return 1./(sigma*sqrt(2.*3.141592))*exp (-0.5*distance*distance/(sigma*sigma));
  }



