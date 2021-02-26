   
// Ausführen mit ./MAFI_COMPLEX S46_MAFI_1.nii S47_MAFI_1.nii 0.5 90 2000
 // mit make compilieren ... alles muss von pandamonium aus passieren

#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
#include <odindata/fitting.h>
#include <iostream>
#include <string>
#include <stdlib.h> 
 
 
#include <gsl/gsl_fit.h>
#include <gsl/gsl_multifit.h>

#define PI 3.14159265;
// Signals changes for every Voxel
  double S_14  = 0.; 
  double S_24  = 0.; 
  double S_34  = 0.; 

  double tg0 = 200. ; //unter Grenze vom WM
  double tg1 = 950. ; //ab hier fällt WM ab
  double tg2 = 1100. ; // Minimum zw. WM und GM
  double tg3 = 1200.;  //ab hier nur GM
  double tg4 = 1300. ; //ab hier auch SCF
  double tg5 = 1500. ; //ab hier nur CSF
  double tg6 = 5000. ; //ab hier nur Müll
 
double echo_space = 58.;   // bei 192 matrix Grappa 3 TE = 19
double T1_GM =  2200. ; 
double T1_WM =  1300. ; 
double T1_CSF =  5000. ;  
double TR =  1500. ;  

  double x_GM = exp(-5./55.); 
  double x_WM = exp(-5./45.); 
  double x_CSF = exp(-5./300.); 
//Signalanteile der verschiedenen Kompartments  U = rho * vol * exp(-TE/T*_2) * const
  double U_GM  = 0.; 
  double U_WM  = 0.; 
  double U_CSF = 0.; 



void usage() { cout << "Histo <Bild > <mask>  <cutoff with respect to mask > " << endl;}
 
 

int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  float cutoff(atoi(argv[3])); 


  
cout << " Heisenberg Fehler: " << endl; 
cout << " don't blink, the angles see you, Bitch !!! " << endl; 

  float Mt0 = 0.;

  Range all=Range::all();

  
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> file1;
  file1.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file1.extent(firstDim);
//löschdie nächste Zeile
  //nrep = 4; 
  int sizeSlice=file1.extent(secondDim);
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);

cout << " sizeSlice  " << sizeSlice << endl; 
cout << " sizePhase  " << sizePhase << endl; 
cout << " sizeRead  " << sizeRead << endl; 

  Data<float,4> mask;
  mask.autoread(filename1);


  Data<float,4> dataGM; 
  dataGM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataGM=0.0;

  Data<float,4> dataWM;
  dataWM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataWM=0.0;

  Data<float,4> dataCSF;
  dataCSF.resize(1,sizeSlice,sizePhase,sizeRead);
  dataCSF=0.0;

  Data<float,4> datat1;
  datat1.resize(1,sizeSlice,sizePhase,sizeRead);
  datat1=0.0;

// Allozieren für Cracy fit
	Array<float,1> sig (5);
	Array<float,1> inversiontime (5);
	Array<float,1> ysigma (5);

cout << "nrep = " << nrep << endl; 


// find min and max value 
float hist_nim = 10000;
float hist_max = -10000;

//fürs Histogramm
float number_of_bins = 250; 


   double hist[(int)number_of_bins]  ; // von 1000 bis 6000 in 10er Schritten
	for (int i = 0; i< number_of_bins ; i++) hist[i] = 0.; 
    ofstream outf("hist.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	    if(mask(0,islice,iy,ix)>=cutoff ){
	  	if ( file1(0,islice,iy,ix) < hist_nim) hist_nim = file1(0,islice,iy,ix); 
	  	if ( file1(0,islice,iy,ix) > hist_max) hist_max = file1(0,islice,iy,ix); 
	    }
        }  
      }
    }
float bin_width = (hist_max - hist_nim)/number_of_bins ; 
int T1_in_bins = 0;   
cout << "    min  = " << hist_nim << "    max = " << hist_max << "     Number of bins = " << number_of_bins << "    bin width  = " << bin_width  << endl;

 	//HAUPT SCHLEIFE 
    for(int islice=0; islice<sizeSlice; ++islice){
//cout << " islice = " << islice << endl; 
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
          if(mask(0,islice,iy,ix)>=cutoff ){


	//---------- crazy T1-Fit ENDE ------------
//cout << " Heisenberg Fehler " << endl; 
	//---------- T1-Histogramm ANFANG ------------ 
	
		T1_in_bins = (int)((file1(0,islice,iy,ix)-hist_nim)/bin_width);
//cout << datat1(0,islice,iy,ix) << "   " << T1_in_bins << endl; 
		hist[T1_in_bins] ++ ; 

 	
		//T1_Propability map
	if (datat1(0,islice,iy,ix) > tg0  && datat1(0,islice,iy,ix) < tg1 ) {
		dataWM(0,islice,iy,ix)  = 1.;
		dataGM(0,islice,iy,ix)  = 0;
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (datat1(0,islice,iy,ix) > tg1  && datat1(0,islice,iy,ix) < tg3 ) {
		dataWM(0,islice,iy,ix)  = 1./(exp((datat1(0,islice,iy,ix)-tg2)/(abs(tg3-tg1)*0.7))+1.);
		dataGM(0,islice,iy,ix)  = 1.-1./(exp((datat1(0,islice,iy,ix)-tg2)/(abs(tg3-tg1)*0.7))+1.);
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (datat1(0,islice,iy,ix) > tg3  && datat1(0,islice,iy,ix) < tg4 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 1.;
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (datat1(0,islice,iy,ix) > tg4  && datat1(0,islice,iy,ix) < tg5 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 1./(exp((datat1(0,islice,iy,ix)-(tg4+tg5)*0.5)/(abs(tg5-tg4)*0.7))+1.);
		dataCSF(0,islice,iy,ix) = 1.-1./(exp((datat1(0,islice,iy,ix)-(tg4+tg5)*0.5)/(abs(tg5-tg4)*0.7))+1.);
	}
	if (datat1(0,islice,iy,ix) > tg5  && datat1(0,islice,iy,ix) < tg6 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 0;
		dataCSF(0,islice,iy,ix) = 1.;
	}
	//---------- T1-Histogramm ENDE ------------


          }//if-cutoff schleife zu 
		else {
			dataGM(0,islice,iy,ix) = 0;
			dataWM(0,islice,iy,ix) = 0;
			dataCSF(0,islice,iy,ix) = 0;
		}

		
        }  
      }
    }

  dataGM.autowrite("GM_Mask.nii", wopts, &prot);
  dataWM.autowrite("WM_Mask.nii", wopts, &prot);
  dataCSF.autowrite("CSF_Mask.nii", wopts, &prot);


for(int i = 0; i< 250 ; i++){
	outf << hist_nim+i * bin_width << "  " << hist[i] << endl; 
	}


  outf.close();

  return 0;

}

