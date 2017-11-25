
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
    
     
  //   #include <gsl/gsl_statistics_int.h>
   //  #include <gsl/gsl_statistics.h>
 
#define PI 3.14159265; 

//#include "utils.hpp"

void usage() { cout << "Highest  < Bild > <cutoff> " << endl;}





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


  Data<int,4> data1;
  data1.resize(1,sizeSlice,sizePhase,sizeRead);
  data1=0.0;

 
  
  
  

 ofstream outf;
 outf.open("out.txt");
 


// count numer of voxels in every layer

int layer_of_max_correl = 0 ;
float max_correl = 0 ;


    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){

		for(int timestep = 0; timestep < nrep; timestep++) {
			if (max_correl < abs(file1(timestep,islice,iy,ix)) ) {
				layer_of_max_correl = timestep+1 ;
				max_correl = abs(file1(timestep,islice,iy,ix)) ;
			}
		}
		
		data1(0,islice,iy,ix) = layer_of_max_correl ;
		max_correl = 0;
		layer_of_max_correl = 0 ;
        }  
      } 
    }
  



 outf.close() ;
 //ofstream outf;
// outf.open("out.txt");
 //outf.close() ;
//cout << " bis hier3 " << endl; 

  data1.autowrite("Highest_"+filename1, wopts, &prot);
  
//cout << " bis hier4 " << endl; 

  return 0;

}
