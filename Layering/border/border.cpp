
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

void usage() { cout << "write_time_course  < Bild > <cutoff suggestion : 79 > " << endl;} // For adam 73





int main(int argc,char* argv[]) {

  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  float cutoff(atoi(argv[2]));
  cutoff = cutoff / 100.;

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

  
  

  Data<float,4> data2;
  data2.resize(1,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> brain_mask;
  brain_mask.resize(1,sizeSlice,sizePhase,sizeRead);
  brain_mask=0.0;


int N = nrep ; 


//    ofstream outf;
//    outf.open("out.txt");
//if ( !outf) {
//cerr<<"Konnte die Datei nicht einlesen: "<<endl;
//return -1;
//} 


cout << " nrep " <<  nrep  << endl; 

	//ohne zwischen räume
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    if ( file1(0,islice,iy,ix) < cutoff ){
    
	      data2(0,islice,iy,ix) = 1; 
         
	
//cout << " file1(timestep  ,islice,iy,ix) " << file1(timestep  ,islice,iy,ix) << endl; 
// debug
	  // data2(timestep/2,islice,iy,ix) = data2(timestep/2,islice,iy,ix) / BOLDa(timestep/2,islice,iy,ix);

	    }
	   if (  file1(0,islice,iy,ix) > cutoff && file1(0,islice,iy,ix) < 2){
		brain_mask(0,islice,iy,ix) = 1.; 
	   }
        }
      }
    }
//cout << timestep << endl; 
   



//cout << " bis hier3 " << endl; 
  
  brain_mask.autowrite("brain_mask"+filename1, wopts, &prot);

  data2.autowrite("border_"+filename1, wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}
