
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
  double tg1 = 1300. ; //ab hier fällt WM ab
  double tg2 = 1350. ; // Minimum zw. WM und GM
  double tg3 = 1400.;  //ab hier nur GM
  double tg4 = 1900. ; //ab hier auch SCF
  double tg5 = 2200. ; //ab hier nur CSF
  double tg6 = 5000. ; //ab hier nur Müll


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



void usage() { cout << "GM Mask <T1 1 > <cutoff> " << endl;}
 
 double func_dM_GM(double ti) ;
 double func_dM_WM(double ti) ;
 double func_dM_CSF(double ti) ;
 double func_M_GM(double ti) ;
 double func_M_WM(double ti) ;
 double func_M_CSF(double ti) ;
 double P_WM (double x,double S_WM , double S_GM); 
 double P_GM (double x,double S_WM , double S_GM , double S_CSF); 
 double P_CSF(double x,double S_GM , double S_CSF); 
 int Inverse (double a[][3], double ainv[][3]) ; 

int main(int argc,char* argv[]) {

  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  float cutoff(atoi(argv[2])); 

//fürs Histogramm

 	double hist[250]  ; // von 1000 bis 6000 in 10er Schritten
	for (int i = 0; i< 250 ; i++) hist[i] = 0.; 
    ofstream outf("hist.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  


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


//Files, in die später die Masken sein werden
  Data<float,4> dataGM;
  dataGM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataGM=0.0;

  Data<float,4> dataWM;
  dataWM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataWM=0.0;

  Data<float,4> dataCSF;
  dataCSF.resize(1,sizeSlice,sizePhase,sizeRead);
  dataCSF=0.0;

 

 	//HAUPT SCHLEIFE 
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
          if(file1(0,islice,iy,ix)>=cutoff ){



	//---------- T1-Histogramm ANFANG ------------
	
if (file1(0,islice,iy,ix) > 0.  ){
	hist[(int)(file1(0,islice,iy,ix)/20.)] ++; 
}
		//T1_Propability map
	if (file1(0,islice,iy,ix) > tg0  && file1(0,islice,iy,ix) < tg1 ) {
		dataWM(0,islice,iy,ix)  = 1.;
		dataGM(0,islice,iy,ix)  = 0;
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (file1(0,islice,iy,ix) > tg1  && file1(0,islice,iy,ix) < tg3 ) {
		dataWM(0,islice,iy,ix)  = 1./(exp((file1(0,islice,iy,ix)-tg2)/(abs(tg3-tg1)*0.7))+1.);
		dataGM(0,islice,iy,ix)  = 1.-1./(exp((file1(0,islice,iy,ix)-tg2)/(abs(tg3-tg1)*0.7))+1.);
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (file1(0,islice,iy,ix) > tg3  && file1(0,islice,iy,ix) < tg4 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 1.;
		dataCSF(0,islice,iy,ix) = 0;
	}
	if (file1(0,islice,iy,ix) > tg4  && file1(0,islice,iy,ix) < tg5 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 1./(exp((file1(0,islice,iy,ix)-(tg4+tg5)*0.5)/(abs(tg5-tg4)*0.7))+1.);
		dataCSF(0,islice,iy,ix) = 1.-1./(exp((file1(0,islice,iy,ix)-(tg4+tg5)*0.5)/(abs(tg5-tg4)*0.7))+1.);
	}
	if (file1(0,islice,iy,ix) > tg5  && file1(0,islice,iy,ix) < tg6 ) {
		dataWM(0,islice,iy,ix)  = 0;
		dataGM(0,islice,iy,ix)  = 0;
		dataCSF(0,islice,iy,ix) = 1.;
	}


          }//if-cutoff schleife zu 
		else {
			dataGM(0,islice,iy,ix) = 0;
			dataWM(0,islice,iy,ix) = 0;
			dataCSF(0,islice,iy,ix) = 0;
		}
	//Backup check, ob summe der U's auch das gesammt Signal ergibt
	//dataError(0,islice,iy,ix) = abs(1. - dataWM(0,islice,iy,ix) - dataGM(0,islice,iy,ix) - dataCSF(0,islice,iy,ix));  
		
        }  
      }
    }

 
  dataGM.autowrite("GM_Mask.nii", wopts, &prot);
  dataWM.autowrite("WM_Mask.nii", wopts, &prot);
  dataCSF.autowrite("CSF_Mask.nii", wopts, &prot);
  

for(int i = 0; i< 250 ; i++){
	outf << i *20 << "  " << hist[i] << endl; 
	}
  outf.close();
  return 0;

}


 double func_dM_GM(double ti) {
 double ergebnis = - (1.+x_GM) * exp(- ti/T1_GM) ;
 return ergebnis ;
 }
 double func_dM_WM(double ti) {
 double ergebnis = - (1.+x_WM) * exp(- ti/T1_WM)  ;
 return ergebnis ;
 }
 double func_dM_CSF(double ti) {
 double ergebnis = - (1.+x_CSF) * exp(- ti/T1_CSF)  ;
 return ergebnis ;
 }
 double func_M_GM(double ti) {
 double ergebnis = - (1.+x_GM) * exp(- ti/T1_GM) + 1.+ x_WM * exp(-TR/T1_GM) ;
 return ergebnis ;
 }
 double func_M_WM(double ti) {
 double ergebnis = - (1.+x_WM) * exp(- ti/T1_WM) + 1.+ x_GM * exp(-TR/T1_WM) ;
 return ergebnis ;
 }
 double func_M_CSF(double ti) {
 double ergebnis = - (1.+x_CSF) * exp(- ti/T1_CSF) + 1.+ x_CSF * exp(-TR/T1_CSF) ;
 return ergebnis ;
 }



