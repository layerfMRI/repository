
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

void usage() { cout << "QUANT1  < Bild TI1> <Bild TI2> <Bild registered B1> <cutoff>" << endl;}


int main(int argc,char* argv[]) {
   
  float TR = 1500. ; 
  float TI = 1100. ; 
  float T1_ = 1800. ;
  float TIeff = 0. ; 
  float chi = 0.6;
  float alpha = 60. ; 
  int SMSfac = 2. ;
  float dTI = 50. ; 
  float t1ratio = 0.;


  float Sig_fst_TI_fkt (float T1, float TR, float TIeff, float chi, float alpha) ; 
  float Sig_snd_TI_fkt (float T1, float TR, float TIeff, float chi, float alpha) ; 
  float T1_from_sig (float ratio_exp,  float TR, float TIeff, float chi, float alpha) ;

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
  //int nrep=file2.extent(firstDim);
  //int sizeSlice=file2.extent(secondDim);
  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  
  Data<float,4> B1map;
  B1map.autoread(filename3, FileReadOpts(), &prot);

  cout << " nrep = " << nrep << endl; 

  Data<float,4> data1;
  data1.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  
  Data<float,4> data2;
  data2.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> BOLD;
  BOLD.resize(nrep,sizeSlice,sizePhase,sizeRead);
  BOLD=0.0;

  

  cout << "out 1 " << endl; 

 
  int slices_in_SMS_slab = sizeSlice/SMSfac ;
  cout << "There are " << slices_in_SMS_slab << " slices in each of the " << SMSfac << " slabs, making it a total of " << sizeSlice << endl;
	


  for(int islice=0; islice<sizeSlice; ++islice){

  cout << "  islice = " << islice  <<  "   islice proc slices_in_SMS_slab = " <<  islice%slices_in_SMS_slab  << endl;

  }


//HAUPT SCHLEIFE 
  for(int islice=0; islice<sizeSlice; ++islice){
    //for(int islice=6; islice<7; ++islice){

    TIeff = TI + (float)(islice%slices_in_SMS_slab) * dTI ; // here it matters if assending of desending
    cout << " slice " << islice << "   of "  << sizeSlice <<  "  TI is " << TIeff<<  endl; 
   

   for(int timestep=0; timestep<(nrep); timestep ++ ) {
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  t1ratio = file1(timestep,islice,iy,ix)/file2(timestep,islice,iy,ix) ;
          if(file1(timestep,islice,iy,ix)>=cutoff && t1ratio > 0. && t1ratio < 1.){
	
            	data1(timestep,islice,iy,ix)= t1ratio ;

    		data2(timestep,islice,iy,ix)= T1_from_sig ( t1ratio,   TR,  TIeff,  chi,  alpha * B1map(0,islice,iy,ix));
	  }
	  else {
		data1(timestep,islice,iy,ix) = 0;
		
	  }
        }
      }
    }
   }

  /////////////////////////////////////////
  ////// Teste my bloch equations
  /////////////////////////////////////////

    ofstream outf;
    outf.open("out.txt");
    if ( !outf) {
      cerr<<"Konnte die Datei nicht einlesen: "<<endl;
      return -1; 
    } 
    for(int i=100; i < 3000; i++ ) {
	//outf  << i << "   "  << Sig_fst_TI_fkt ( T1,  TR,  TI,  chi,  (float) i ) << "   "  << Sig_snd_TI_fkt ( T1,  TR,  TI,  chi,  (float) i ) << "  "   << Sig_fst_TI_fkt ( T1,  TR,  TI,  chi,  (float) i ) /  Sig_snd_TI_fkt ( T1,  TR,  TI,  chi,  (float) i ) << endl;
        outf  << i << "   "  << Sig_fst_TI_fkt ( (float) i,  TR,  TI,  chi, alpha ) << "   "  << Sig_snd_TI_fkt ((float) i ,  TR,  TI,  chi,  alpha  ) << "  "  << Sig_fst_TI_fkt ( (float) i,  TR,  TI,  chi, alpha ) / Sig_snd_TI_fkt ((float) i ,  TR,  TI,  chi,  alpha  ) << "  "  << Sig_fst_TI_fkt ( (float) i,  TR,  TI+200,  chi, alpha ) / Sig_snd_TI_fkt ((float) i ,  TR,  TI+200,  chi,  alpha  ) <<  endl; 
       // cout   << i << "   "  << Sig_fst_TI_fkt ( (float) i,  TR,  TI,  chi, alpha ) << "   "  << Sig_snd_TI_fkt ((float) i ,  TR,  TI,  chi,  alpha  ) << "  "  << Sig_fst_TI_fkt ( (float) i,  TR,  TI,  chi, alpha )/ Sig_snd_TI_fkt ((float) i ,  TR,  TI,  chi,  alpha  ) << endl; 
    }

  outf.close();
  

  cout << "out 2 " << endl; 

  
     
  //cout << "HALLO bis HIER" << endl; 
  //angle.autowrite("RENZO_Test_"+filename_mag);

  data1.autowrite("ratio.nii", wopts, &prot);
  data2.autowrite("T1MAP.nii", wopts, &prot);
  BOLD.autowrite("BOLD.nii", wopts, &prot);
  return 0;

}


  float Sig_fst_TI_fkt (float T1, float TR, float TIeff, float chi, float alpha) {

	return   ( 1. -(1. + chi)* exp(-TIeff/T1) + chi * exp(-TR/T1) - cos(alpha/360. * 2.* 3.141596)* exp(-TR/T1) + cos (alpha/360. * 2.* 3.141596) * exp(-2.*TR/T1)  )/(  1. + chi * cos (alpha/360. * 2.* 3.141596)*cos(alpha/360. * 2.* 3.141596)* exp(-2*TR/T1)   )  ;
	} 
  float Sig_snd_TI_fkt (float T1, float TR, float TIeff, float chi, float alpha) {

	return   1. -  exp(-TR/T1) * (   1. -  cos(alpha/360. * 2.* 3.141596) *Sig_fst_TI_fkt ( T1,  TR,  TIeff,  chi,  alpha) );
	}  
 float T1_from_sig (float ratio_exp,  float TR, float TIeff, float chi, float alpha) {
		 
		float difference = 0; 
		float min_diff = 1.;
		float T1_at_min = 0. ;  	
		float ratio_theo  = 0. ;

		for(int i=0; i < 5000; i = i + 20  ) {
		  ratio_theo = Sig_fst_TI_fkt ( (float) i,  TR,  TIeff,  chi, alpha ) / Sig_snd_TI_fkt ((float) i ,  TR,  TIeff,  chi,  alpha  ) ; 
		  difference = abs( ratio_exp - ratio_theo  ); 
		  if (difference < min_diff ){
		    T1_at_min = (float) i ;
		    min_diff = difference;
		  } 
		}

		//if ( ratio_exp < 0.24) T1_at_min + 6000. ;
		
		//if ( min_diff > 0.2 && ratio_exp >= 0.24) cout <<  "ATTENTION: poor T1 calculation.  min_diff = " <<  min_diff << " T1_at_min = " << T1_at_min <<"  ratio_exp  = "<< ratio_exp << endl; 
	
	return  T1_at_min  ;
	} 






