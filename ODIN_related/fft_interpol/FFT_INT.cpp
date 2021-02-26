
// Mittelwert micalc -mask GM_Mask1.nii.gz -if tSNR_map_trad.nii
 // mit make compilieren ... alles muss von pandamonium aus passieren
 

//mean in mask mit " micalc -mask maskfile.nii -if timeseries.nii "

#include <odindata/data.h>
#include <odindata/fileio.h>
#include <odindata/complexdata.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>
    #include <gsl/gsl_errno.h>
    #include <gsl/gsl_fft_real.h>
    #include <gsl/gsl_fft_halfcomplex.h>

#define PI 3.14159265; 


//#include "utils.hpp"

void usage() { cout << "FFT my data  <ampl Bild >  <cutoff> " << endl;}



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
  
  //nrep=64;
  int sizeSlice=file1.extent(secondDim);
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);



cout << " nrep " <<  nrep  << endl; 
cout << " sizePhase " <<  sizePhase  << endl; 
cout << " sizeRead " <<  sizeRead  << endl; 

// The first line in read and the las line in phase are 0. This makes some problems with respect to gibbs ringing. 
 for(int irep=0; irep<nrep; irep++) {
      for(int islice=0; islice<sizeSlice; ++islice){
	for(int iy=0; iy<sizePhase; ++iy){ 
		file1(irep,islice,iy,0) = file1(irep,islice,iy,1) ; 
 	}
	for(int ix=0; ix<sizeRead; ++ix){ 
		file1(irep,islice,sizePhase-1,ix) = file1(irep,islice,sizePhase-2,ix) ; 

 	}
	for(int iy=0; iy<sizePhase; ++iy){ 
		file1(irep,islice,iy,sizeRead-2) = file1(irep,islice,iy,sizeRead-1) ; 
 	}
	for(int ix=0; ix<sizeRead; ++ix){ 
		file1(irep,islice,0,ix) = file1(irep,islice,1,ix) ; 

 	}
      }
 }

  ComplexData<4> complex;
  complex.resize(1,1,sizePhase,sizeRead);
  

  Data<float,4> odin_out;
  odin_out.resize(nrep,sizeSlice,sizePhase,sizeRead); 
  


  TinyVector<int,4> fft_vector;
  fft_vector=(0,1,1,1);
  


// RESCALE
  int rescale_fac = 5 ;   
  int scal_sizePhase = sizePhase*rescale_fac ;
  int scal_sizeRead  =  sizeRead*rescale_fac ;

  cout << " scal_sizePhase " <<  scal_sizePhase  << endl; 
  cout << " scal_sizeRead " <<  scal_sizeRead  << endl; 
  int laufindex_x = 0;
  int laufindex_y = 0;


  Data<float,4> image_ampl_out;
  image_ampl_out.resize(nrep,sizeSlice,scal_sizePhase,scal_sizeRead); 
  
  
  ComplexData<4> scal_complex;
  scal_complex.resize(1,1,scal_sizePhase,scal_sizeRead);

	for(int iy=0; iy<scal_sizePhase; ++iy){
	  for(int ix=0; ix<scal_sizeRead; ++ix){
	    scal_complex(0,0,iy,ix) = STD_complex(0., 0.) ;
	  }
	}

   

   cout<< " start odin FFT  ... this might take 60 sec. " << endl; 
   
    for(int irep=0; irep<nrep; irep++) {
      for(int islice=0; islice<sizeSlice; ++islice){

   // I dont know, we I sould need this. may be wrong allocation?
	for(int iy=0; iy<scal_sizePhase; ++iy){ 
	  for(int ix=0; ix<scal_sizeRead; ++ix){
	    scal_complex(0,0,iy,ix) = STD_complex(0., 0.) ;
	  }
	}	


	for(int iy=0; iy<sizePhase; ++iy){
	  for(int ix=0; ix<sizeRead; ++ix){
	    
	    complex(0,0,iy,ix) = STD_complex(file1(irep,islice,iy,ix), file1(irep,islice,iy,ix)) ;
	    //cout << "complex(0,0,iy,ix)  " << complex(0,0,iy,ix) << endl; 
	    //odin_out_pha(irep,islice,iy,ix) = imag(complex(0,0,iy,ix)); // note that here I only write the abs of a complex number. 
	  }
	}
      
      complex.partial_fft(fft_vector,false,true);   // This is the part of the FFT
      //complex.partial_fft(fft_vector,true,true);

       for(int iy=0; iy<sizePhase; ++iy){
	  for(int ix=0; ix<sizeRead; ++ix){
	        odin_out(irep,islice,iy,ix) = abs(complex(0,0,iy,ix)); // note that here I only write the abs of a complex number. 
		
	  }
	}



	for(int iy=0; iy<sizePhase; ++iy){
 	  laufindex_y = (int)(iy+(rescale_fac-1.)/2.*sizePhase); 
	   //cout << endl <<  laufindex_y << "  "  ;

	  for(int ix=0; ix<sizeRead; ++ix){	   
 	    laufindex_x = (int)(ix+(rescale_fac-1.)/2.*sizeRead);
		//cout  <<  laufindex_x << "  "  ;
		
	    scal_complex(0,0,laufindex_y, laufindex_x)  =  complex(0,0,iy,ix) ;
	    
	  }
	}

	scal_complex.partial_fft(fft_vector,true,true);   // This is the part of the FFT
      
    
       for(int iy=0; iy<scal_sizePhase; ++iy){
	  for(int ix=0; ix<scal_sizeRead; ++ix){
	        image_ampl_out(irep,islice,iy,ix) =  abs(scal_complex(0,0,iy,ix)); // note that here I only write the abs of a complex number. 

	  }
	} 
	
	
      
      }
    }



  

  //odin_out=abs(complex);
  
  //image_ampl_out=where(Array<float,4>(odin_out) == Array<float,4>(odin_out), Array<float,4>(odin_out), (float)0 ); // exclude nan and set to zero
  image_ampl_out.autowrite("scaled_ampl"+filename1, wopts, &prot);
  

  


  odin_out=where(Array<float,4>(odin_out) == Array<float,4>(odin_out), Array<float,4>(odin_out), (float)0 ); // exclude nan and set to zero
  odin_out.autowrite("odin_FFT_"+filename1, wopts, &prot);
  


  return 0;

}
