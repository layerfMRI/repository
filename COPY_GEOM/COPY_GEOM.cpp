
// Ausführen mit ./MAFI_COMPLEX S46_MAFI_1.nii S47_MAFI_1.nii 0.5 90 2000
 // mit make compilieren ... alles muss von pandamonium aus passieren

#define ODIN_DEBUG
#include <tjutils/config.h>
#include <odindata/data.h> 
#include <odindata/complexdata.h> 
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     #include <gsl/gsl_multifit.h>


#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "COPY GEOM  < file to copy geom from> , file, whoos gom should be overwritten> " << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);


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

  Data<float,4> file2;
  file2.autoread(filename2);
  //int nrep=file2.extent(firstDim);
  //int sizeSlice=file2.extent(secondDim);
  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  

  cout << " nrep = " << nrep << endl; 

  file2.autowrite(filename2, wopts, &prot);
  return 0;

}
