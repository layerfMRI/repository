
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

void usage() { cout << "handle manual corrected rim  < surface >  < WM border > < corrected GM ribbon >  " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);


float kernal_size = 1; // corresponds to one voxel sice. 

  Range all=Range::all();
  
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> surfFile;
  surfFile.autoread(filename1, FileReadOpts(), &prot);
  int nrep=surfFile.extent(firstDim);
  int sizeSlice=surfFile.extent(secondDim);
  int sizePhase=surfFile.extent(thirdDim);
  int sizeRead=surfFile.extent(fourthDim);

  Data<float,4> wmFile;
  wmFile.autoread(filename2, FileReadOpts(), &prot);
  
  Data<float,4> RIBinFILE;
  RIBinFILE.autoread(filename3, FileReadOpts(), &prot);

  Data<int,4> rim;
  rim.resize(nrep,sizeSlice,sizePhase,sizeRead);
  rim=0.0;

  Data<int,4> WMfill;
  WMfill.resize(nrep,sizeSlice,sizePhase,sizeRead);
  WMfill=0.0;


  Data<int,4> CSFfill;
  CSFfill.resize(nrep,sizeSlice,sizePhase,sizeRead);
  CSFfill=0.0;


cout <<"  text  "  << endl; 


float x1g = 0.;
float y1g = 0.;

int vinc = 1;


int found = 0;
int stepp = 0;

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	   if (RIBinFILE(0,islice,iy,ix) == 0 && CSFfill(0,islice,iy,ix) == 0 && WMfill(0,islice,iy,ix) == 0 ){

		while (found ==0 && stepp <sizePhase) {

	    		for(int iy_i=max(0,iy-stepp); iy_i<=min(iy+stepp,sizePhase); ++iy_i){
	     		 for(int ix_i=max(0,ix-stepp); ix_i<=min(ix+stepp,sizeRead); ++ix_i){
				if (wmFile(0,islice,iy_i,ix_i) == 1 || WMfill(0,islice,iy_i,ix_i) == 1  ){
			 		WMfill(0,islice,iy,ix) = 1 ;
					found = 1; 
				}  
				if (surfFile(0,islice,iy_i,ix_i) == 1 || CSFfill(0,islice,iy_i,ix_i) == 1  ){
			 		CSFfill(0,islice,iy,ix) = 1 ;
					found = 1; 
				}  
	  		 }
	  		}
			//cout<< "stepp = " << stepp << endl ;
		     stepp = stepp + 1 ;
		}
		found = 0; 
		stepp = 0;
	   }

        }
      }
//cout<< " = " << sizeSlice << endl ;
     }

int GMnext = 0; 
int CSFnext = 0;
int WMnext = 0;

 for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){


	    	for(int iy_i=max(0,iy-vinc); iy_i<=min(iy+vinc,sizePhase); ++iy_i){
	     	 for(int ix_i=max(0,ix-vinc); ix_i<=min(ix+vinc,sizeRead); ++ix_i){
			if (WMfill(0,islice,iy_i,ix_i) == 1 ) WMnext = 1 ; 
			if (CSFfill(0,islice,iy_i,ix_i) == 1 ) CSFnext = 1 ; 
			if (RIBinFILE(0,islice,iy_i,ix_i) == 1 ) GMnext = 1 ; 
			
	  	 }
	  	}

	   if (RIBinFILE(0,islice,iy,ix) == 1 ) rim(0,islice,iy,ix) = 3;
	   if (CSFfill(0,islice,iy,ix) == 1 && GMnext == 1 ) rim(0,islice,iy,ix) = 1;
	   if (WMfill(0,islice,iy,ix) == 1 && GMnext == 1 ) rim(0,islice,iy,ix) = 2;

	  GMnext = 0; 
	  CSFnext = 0;
	  WMnext = 0;

        }
      }
    }

   WMfill.autowrite("WMfill.nii", wopts, &prot);
   CSFfill.autowrite("CSFfill.nii", wopts, &prot);
   rim.autowrite("rim.nii", wopts, &prot);

//cout << " bis hier4 " << endl; 

  return 0;

}

 
