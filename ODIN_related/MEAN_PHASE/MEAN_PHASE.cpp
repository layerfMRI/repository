
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

void usage() { cout << " MEAN_PHASE <AMPL> <PHASE> " << endl;}


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
  file2.autoread(filename2, FileReadOpts(), &prot);

  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  

  cout << " nrep = " << nrep << endl; 

  Data<float,4> data1;
  data1.resize(1,sizeSlice,sizePhase,sizeRead);
  data1=0.0;


  Data<float,4> data2;
  data2.resize(1,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  /**********************************************************************************/
  // creates complex data
  /**********************************************************************************/
  // stores the magnitude and phase data of each coil as a complex number
  ComplexData<5> ComplexTimeSeries(1,nrep,sizeSlice,sizePhase,sizeRead);
  ComplexTimeSeries(all,all,all,all,all)=0.0;

  ComplexData<5> ComplexMean(1,1,sizeSlice,sizePhase,sizeRead);
  ComplexMean(all,all,all,all,all)=0.0;

  ComplexData<5> ComplexUnit(1,1,1,1,1);
  ComplexUnit(0,0,0,0,0)=complex<float>(2,0);

for(int timestep=0; timestep<nrep; timestep ++ ) {
 for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
         ComplexTimeSeries(0,timestep,islice,iy,ix)=complex<float>( file1(timestep,islice,iy,ix) * cos( PII/4096.0*file2(timestep,islice,iy,ix)), file1(timestep,islice,iy,ix) * sin( PII/4096.0*file2(timestep,islice,iy,ix)));
      } 
    }
  }
}

 for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
        for(int timestep=0; timestep<nrep; timestep ++ ) {
         ComplexMean(0,0,islice,iy,ix)= ComplexMean(0,0,islice,iy,ix) + ComplexTimeSeries(0,timestep,islice,iy,ix) ;
	}
	//ComplexMean(0,0,islice,iy,ix)= ComplexMean(0,0,islice,iy,ix)/nrep;
      } 
    }
  }  

 



  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	      data1(0,islice,iy,ix)=abs(ComplexMean(0,0,islice,iy,ix))/(float)nrep;
	      data2(0,islice,iy,ix)=phase(ComplexMean(0,0,islice,iy,ix));
	      
	    }
	  }
       }


  //cout << "HALLO bis HIER" << endl; 
  //angle.autowrite("RENZO_Test_"+filename_mag);

  data2.autowrite("Mean_Phase.nii", wopts, &prot);
  data1.autowrite("Mean_Ampl.nii", wopts, &prot);
 
  return 0;

}


