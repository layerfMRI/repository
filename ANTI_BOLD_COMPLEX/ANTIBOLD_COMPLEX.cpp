
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

void usage() { cout << "AntiBold  COMPLEX < AMPL> <PHASE>  <MASK>  <cutoff>" << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=5) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);
  float cutoff(atoi(argv[4]));

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

  Data<float,4> mask;
  mask.autoread(filename3, FileReadOpts(), &prot);

  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  

  cout << " nrep = " << nrep << endl; 

  Data<float,4> data1;
  data1.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  
  Data<float,4> data2;
  data2.resize(nrep/2,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> BOLD;
  BOLD.resize(nrep/2,sizeSlice,sizePhase,sizeRead);
  BOLD=0.0;

  cout << "out 1 " << endl; 

  int functNTR = nrep/2 ;
 
  cout << "functNTR " << functNTR << " nrep  " << nrep << endl;


  /**********************************************************************************/
  // creates complex data
  /**********************************************************************************/
  // stores the magnitude and phase data of each coil as a complex number
  ComplexData<5> ComplexTimeSeries(1,nrep,sizeSlice,sizePhase,sizeRead);
  ComplexTimeSeries(all,all,all,all,all)=0.0;

  ComplexData<5> ComplexMean(1,1,sizeSlice,sizePhase,sizeRead);
  ComplexMean(all,all,all,all,all)=0.0;

  ComplexData<5> ComplexVASOTimeSeries(1,functNTR,sizeSlice,sizePhase,sizeRead);
  ComplexVASOTimeSeries(all,all,all,all,all)=0.0;

  ComplexData<5> ComplexBOLDimeSeries(1,functNTR,sizeSlice,sizePhase,sizeRead);
  ComplexBOLDimeSeries(all,all,all,all,all)=0.0;

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

        for(int timestep=0; timestep<nrep-2; timestep = timestep + 2 ) {
	 ComplexBOLDimeSeries(0,timestep/2,islice,iy,ix)= ComplexTimeSeries(0,timestep,islice,iy,ix) ;
         ComplexVASOTimeSeries(0,timestep/2,islice,iy,ix)= ComplexTimeSeries(0,timestep+1,islice,iy,ix) * ComplexUnit(0,0,0,0,0)  /(ComplexTimeSeries(0,timestep,islice,iy,ix) + ComplexTimeSeries(0,timestep+2,islice,iy,ix) ) ;

	}
	//ComplexMean(0,0,islice,iy,ix)= ComplexMean(0,0,islice,iy,ix)/nrep;
      } 
    }
  }  



  Data<float,4> PhaseComplexMean;
  PhaseComplexMean.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  PhaseComplexMean=0.0;
  Data<float,4> AmplComplexMean;
  AmplComplexMean.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  AmplComplexMean=0.0;
  Data<float,4> VASOSmoothAmpl;
  VASOSmoothAmpl.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  VASOSmoothAmpl=0.0;
  Data<float,4> VASOSmoothPhase;
  VASOSmoothPhase.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  VASOSmoothPhase=0.0;
  Data<float,4> ImagBOLD;
  ImagBOLD.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  ImagBOLD=0.0;
 
  Data<float,4> correctecVASO;
  correctecVASO.resize(functNTR,sizeSlice,sizePhase,sizeRead);
  correctecVASO=0.0;


//////////////////////
// Get smoothed PHASE
//////////////////////
int kernal_size = 3 ;
int vinc = max(1.,3. * kernal_size ); // if voxel is too far away, I ignore it. 
float dist_i = 0.;
cout << " vinc " <<  vinc<<  endl; 
cout << " kernal_size " <<  kernal_size<<  endl; 
float dist (float x1, float y1, float x2, float y2) ;
float gaus (float distance, float sigma) ;


  ComplexData<5> smoothed(1,1,sizeSlice,sizePhase,sizeRead);
  Data<float,4> gaus_weigth(1,sizeSlice,sizePhase,sizeRead);
  ComplexData<5> smoothedVASO(1,functNTR,sizeSlice,sizePhase,sizeRead);
  smoothedVASO(all,all,all,all,all)=0.0;
  cout << "los gehts mim smoothen" <<  endl ; 

 for(int timestep=0; timestep<functNTR; ++timestep){
  smoothed(all,all,all,all,all)=0.0;
  gaus_weigth(all,all,all,all)=0.0;
 // cout << ", t=" <<  timestep ; 
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if (mask(0,islice,iy,ix) > 0 ){
	  
	   for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < vinc && mask(0,islice,iy_i,ix_i) > 0  ){

		    smoothed(0,0,islice,iy,ix) = smoothed(0,0,islice,iy,ix) + ComplexVASOTimeSeries(0,timestep,islice,iy_i,ix_i)* complex<float>(gaus(dist_i ,kernal_size ),0) ;
		    gaus_weigth(0,islice,iy,ix) = gaus_weigth(0,islice,iy,ix) + gaus(dist_i ,kernal_size ) ;
		  }
		}  
	      }
		smoothed(0,0,islice,iy,ix) = smoothed(0,0,islice,iy,ix)/complex<float>(gaus_weigth(0,islice,iy,ix),0);
		//bias_filt(timestep,islice,iy,ix) = file1(timestep,islice,iy,ix);
         }
        if (mask(0,islice,iy,ix) == 0 ){
		smoothed(0,0,islice,iy,ix) = ComplexVASOTimeSeries(0,timestep,islice,iy,ix);
		
	 }
	smoothedVASO(0,timestep,islice,iy,ix) = smoothed(0,0,islice,iy,ix);
        }
      } 
     }
    
  }




for(int timestep=0; timestep<functNTR; timestep = timestep + 1) {
  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	      ImagBOLD(timestep,islice,iy,ix)=abs(ComplexBOLDimeSeries(0,timestep,islice,iy,ix));
	      AmplComplexMean(timestep,islice,iy,ix)= abs(ComplexVASOTimeSeries(0,timestep,islice,iy,ix));
	      PhaseComplexMean(timestep,islice,iy,ix)= phase(ComplexVASOTimeSeries(0,timestep,islice,iy,ix));
	      VASOSmoothPhase(timestep,islice,iy,ix)= phase(smoothedVASO(0,timestep,islice,iy,ix));
	      VASOSmoothAmpl(timestep,islice,iy,ix)= abs(smoothedVASO(0,timestep,islice,iy,ix));
	      correctecVASO(timestep,islice,iy,ix)= (real(ComplexVASOTimeSeries(0,timestep,islice,iy,ix))*real(smoothedVASO(0,timestep,islice,iy,ix))+imag(ComplexVASOTimeSeries(0,timestep,islice,iy,ix))*imag(smoothedVASO(0,timestep,islice,iy,ix)))/sqrt((real(smoothedVASO(0,timestep,islice,iy,ix))*real(smoothedVASO(0,timestep,islice,iy,ix))+imag(smoothedVASO(0,timestep,islice,iy,ix))*imag(smoothedVASO(0,timestep,islice,iy,ix))));
	    }
	  }
       }
}

  //cout << "HALLO bis HIER" << endl; 
  //angle.autowrite("RENZO_Test_"+filename_mag);

  AmplComplexMean.autowrite("VASO.nii", wopts, &prot);
  ImagBOLD.autowrite("BOLD.nii", wopts, &prot);
  AmplComplexMean.autowrite("VASOorigAmpl.nii", wopts, &prot);
  PhaseComplexMean.autowrite("VASOorigPhase.nii", wopts, &prot);
  VASOSmoothPhase.autowrite("VASOSmoothPhase.nii", wopts, &prot);
  VASOSmoothAmpl.autowrite("VASOSmoothAmpl.nii", wopts, &prot);
  correctecVASO.autowrite("correctecVASO.nii", wopts, &prot);
  return 0;

}


 float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float gaus (float distance, float sigma) {
    return 1./(sigma*sqrt(2.*3.141592))*exp (-0.5*distance*distance/(sigma*sigma));
  }
