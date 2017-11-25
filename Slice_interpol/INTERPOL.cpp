
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

  
  int sizeSlice_new = sizeSlice*2-1 ; 
  
  cout << " sizeSlice = " <<  sizeSlice  << "    sizeSlice_new = " <<  sizeSlice_new << endl; 

  Data<float,4> data1;
  data1.resize(nrep,sizeSlice_new,sizePhase,sizeRead);
  data1=0.0;
  




int N = nrep ; 




cout << " nrep " <<  nrep  << endl; 

  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice ){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    if ( file1(0,islice,iy,ix) > cutoff ){

            data1(timestep,islice*2,iy,ix) = file1(timestep,islice,iy,ix);

	    }
	    else { 
	    	data1(timestep,islice*2,iy,ix)=  0.; 
	    }
        }
      }
    }
    
    
     for(int islice=1; islice<sizeSlice_new; islice = islice + 2 ){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	

            data1(timestep,islice,iy,ix) = (data1(timestep,islice+1,iy,ix)+data1(timestep,islice-1,iy,ix))/2.;

	    

        }
      }
    }
    
    
    
    
    
    
  }
  
  
  
  
  
  

//cout << " bis hier2 " << endl; 

  



//cout << " bis hier3 " << endl; 

  data1=where(Array<float,4>(data1) == Array<float,4>(data1), Array<float,4>(data1), (float)0 );
  data1.autowrite("thin_"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
