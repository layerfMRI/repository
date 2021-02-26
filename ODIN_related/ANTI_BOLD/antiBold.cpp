
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

void usage() { cout << "AntiBold  < Bild VASO> <Bild BOLD> <cutoff>" << endl;}


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

  Data<float,4> file2;
  file2.autoread(filename2, FileReadOpts(), &prot);
  //int nrep=file2.extent(firstDim);
  //int sizeSlice=file2.extent(secondDim);
  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  

  cout << " nrep = " << nrep << endl; 


  cout << "out 1 " << endl; 
  
  Data<float,4> data2;
  data2.resize(nrep/2,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  cout << "out 2 " << endl; 

  Data<float,4> BOLD;
  BOLD.resize(nrep/2,sizeSlice,sizePhase,sizeRead);
  BOLD=0.0;

  cout << "out 3 " << endl; 
	//HAUPT SCHLEIFE 
   for(int timestep=1; timestep<(nrep); timestep = timestep + 2 ) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){

	
	//T1 bestimmen
	if(timestep < 1 ){
            data2(timestep,islice,iy,ix)= 0 ;
	}
	if(timestep == 1 ){
            data2(timestep/2,islice,iy,ix)= file1(timestep,islice,iy,ix)/file2(timestep+1,islice,iy,ix);
	}
	if(timestep > 1 && timestep < nrep  ){
            data2(timestep/2,islice,iy,ix)= file1(timestep,islice,iy,ix)*2./(file2(timestep+1,islice,iy,ix)+file2(timestep-1,islice,iy,ix)  ) ;
	}
	//if(timestep == 239 ){
        //    data1(timestep,islice,iy,ix)= file1(timestep,islice,iy,ix)*1./file2(timestep-1,islice,iy,ix) ;
	//}
	//data1(timestep + 1 ,islice,iy,ix) = data1(timestep,islice,iy,ix);


        }
      }
    }
   }

  cout << "out 2 " << endl; 



	//ohne zwischen räume
  for(int timestep=1; timestep<nrep; timestep = timestep + 2) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){


	    BOLD(timestep/2,islice,iy,ix)= file2(timestep+1,islice,iy,ix);
	    


    
        }
      }
    }
//cout << timestep << endl; 
   }

  cout << "out 3 " << endl; 
   
     for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    
	      data2(nrep/2-1,islice,iy,ix)= data2(nrep/2-2,islice,iy,ix);
	      BOLD(nrep/2-1,islice,iy,ix)= BOLD(nrep/2-2,islice,iy,ix);

	    }
	  }
       }
     
   
     cout << "out 4 " << endl; 

     
     /*
	//Signal Driffts rausrechenen
double vaso_anfang = 0.; 
double vaso_ende = 0.; 
double bold_anfang = 0.; 
double bold_ende = 0.; 
int N = nrep/2 ; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){


        for(int timestep=1; timestep < 21 ; timestep ++ ) {
	vaso_anfang = vaso_anfang + data2(timestep,islice,iy,ix) ; 
	bold_anfang = bold_anfang + BOLD(timestep,islice,iy,ix) ; 
        }
	for(int timestep=nrep/2 - 20; timestep < nrep/2 ; timestep ++ ) {
	vaso_ende = vaso_ende + data2(timestep,islice,iy,ix) ; 
	bold_ende = bold_ende + BOLD(timestep,islice,iy,ix) ; 
        }
	vaso_anfang = vaso_anfang/20.; 
	vaso_ende   = vaso_ende/20. ; 
	bold_anfang = bold_anfang/20. ; 
	bold_ende   = bold_ende/20. ; 
	
	for(int timestep=0; timestep < N ; timestep ++ ) {
	data2(timestep,islice,iy,ix)  =  (data2(timestep,islice,iy,ix)  - timestep * (vaso_ende - vaso_anfang) /(double)N); 
	BOLD(timestep,islice,iy,ix)  =  (BOLD(timestep,islice,iy,ix)  - timestep * (bold_ende - bold_anfang) /(double)N); 
	if (!(data2(timestep,islice,iy,ix) > -100000 && data2(timestep,islice,iy,ix) < 10000 )) data2(timestep,islice,iy,ix) = 0.; 
	if (!( BOLD(timestep,islice,iy,ix) > -100000 &&  BOLD(timestep,islice,iy,ix) < 100000 ))  BOLD(timestep,islice,iy,ix) = 0.; 

        }

	vaso_anfang = 0.; 
	vaso_ende   = 0.; 
	bold_anfang = 0.; 
	bold_ende   = 0.; 


	    }
	  }
       }
     */
    
      cout << "out 5 " << endl; 
    
  
  //cout << "HALLO bis HIER" << endl; 
  //angle.autowrite("RENZO_Test_"+filename_mag);

  data2.autowrite("Anti_BOLD_no_drift.nii", wopts, &prot);
  BOLD.autowrite("Bold_no_drift.nii", wopts, &prot);
  return 0;

}
