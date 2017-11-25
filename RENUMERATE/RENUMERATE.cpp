
// Ausführen mit . ./layers border_example_resized.nii brain_maskexample_resized.nii 0


 
#include <odindata/data.h> 
#include <odindata/complexdata.h> 
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     #include <gsl/gsl_multifit.h>


#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "file  < mask> " << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=2) {usage(); return 0;}
  STD_string filename1(argv[1]);


  Range all=Range::all();
  
  
  Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  


  Data<float,4> file2;
  file2.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file2.extent(firstDim);
  int sizeSlice=file2.extent(secondDim);
 //sizeSlice = 1; // only for debugging. tp make it faster 
  int sizePhase=file2.extent(thirdDim);
  int sizeRead=file2.extent(fourthDim);


cout << "bis hier 2 " << endl; 

// first adapt the GM mask so it can be used as a stanrard script



  Data<float,4> file1;
  file1.resize(1,sizeSlice,sizePhase,sizeRead);
  file1=0.0;

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){


		if (file2(0,islice,iy,ix) == 1) file1(0,islice,iy,ix) = 1 ; 
		if (file2(0,islice,iy,ix) == 2) file1(0,islice,iy,ix) = 3 ; 
		if (file2(0,islice,iy,ix) == 3) file1(0,islice,iy,ix) = 2 ;

        }
      }
    }



//thickness.autowrite("thickness.nii", wopts, &prot);

file1.autowrite("renumerated_"+filename1, wopts, &prot);

 // koord.autowrite("koordinaten.nii", wopts, &prot);
  return 0;
}





