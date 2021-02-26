
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

void usage() { cout << "GLOSSY_LAYERS  < 21 LAYERS to be glossed >" << endl;}





int main(int argc,char* argv[]) {

  if (argc!=2) {usage(); return 0;}
  STD_string filename1(argv[1]);




float kernal_size = 1; // corresponds to one voxel sice. 

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


  
  Data<int,4> glossy;
  glossy.resize(nrep,sizeSlice,sizePhase,sizeRead);
  glossy=0.0;

cout <<"  I assume integer layers between 0 and 21  "  << endl; 

  for(int timestep=0; timestep<nrep; ++timestep){
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  
	 
		glossy(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix);
 		if(glossy(timestep,islice,iy,ix) < 1)  glossy(timestep,islice,iy,ix) = 0; 
     		if(glossy(timestep,islice,iy,ix) > 21) glossy(timestep,islice,iy,ix) = 0;
	} 
     } 
    }
  }




   glossy.autowrite("glossy_equi_volume_layers.nii", wopts, &prot);

   

//cout << " bis hier4 " << endl; 

  return 0;

}

 
