   
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


void usage() { cout << "GM Mask <Bild 1 >  <cutoff> " << endl;}
 
 

int main(int argc,char* argv[]) {

  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  float cutoff(atoi(argv[2])); 

//fürs Histogramm

// 	double hist[250]  ; // von 1000 bis 6000 in 10er Schritten
//	for (int i = 0; i< 250 ; i++) hist[i] = 0.; 
//    ofstream outf("hist.dat");
//  if (!outf) {
//    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
//  }
  



  Range all=Range::all();

  Data<float,4> file1;
  file1.autoread(filename1);
  int nrep=file1.extent(firstDim);
//löschdie nächste Zeile
  //nrep = 4; 
  int sizeSlice=file1.extent(secondDim);
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);

cout << " sizeSlice  " << sizeSlice << endl; 
cout << " sizePhase  " << sizePhase << endl; 
cout << " sizeRead  " << sizeRead << endl; 

  

  Data<float,4> datat1;
  datat1.resize(1,sizeSlice,sizePhase,sizeRead);
  datat1=0.0;

  Data<float,4> datat2;
  datat2.resize(1,sizeSlice,sizePhase,sizeRead);
  datat2=0.0;

  Data<float,4> datat3;
  datat3.resize(1,sizeSlice,sizePhase,sizeRead);
  datat3=0.0;

// Allozieren für Cracy fit
	Array<float,1> sig (nrep);
	Array<float,1> echotime (nrep);
	Array<float,1> ysigma (nrep);

		for (int itimestep=0; itimestep<nrep; ++itimestep){
			ysigma(itimestep) = 1.0;
			echotime(itimestep) = 2.02+(double)itimestep*3.36;
		}

cout << "nrep = " << nrep << endl; 


	//---------- crazy T1-Fit ANFANG ------------
  ExponentialFunction expf;
  FunctionFitDerivative expfit;
  expfit.init(expf,nrep);



 	//HAUPT SCHLEIFE 
    for(int islice=0; islice<sizeSlice; ++islice){
      //cout << " islice = " << islice << endl; 
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
          
		for (int itimestep=0; itimestep<nrep; ++itimestep){
			sig (itimestep) = file1(itimestep,islice,iy,ix);
		}

		//for (int itimestep=0; itimestep<nrep; ++itimestep){
		//	cout << sig (itimestep) << "/" << echotime(itimestep) << " " ;
		//}

		//cout << endl;

	    expf.A.val = 200.; //Zuordnung
	    expf.lambda.val = -0.5;//Startwert lambda

//cout << " Hallo 5 " << endl;
	    expfit.fit(sig,ysigma,echotime);
//cout << " Heisenberg Fehler " << endl;	
           datat1(0,islice,iy,ix)=  -1./expf.lambda.val ;
           datat2(0,islice,iy,ix)=  expf.A.val ;
           datat3(0,islice,iy,ix)=  (expf.A.val*exp(echotime(0)*expf.lambda.val)-file1(0,islice,iy,ix))/expf.A.val ;

	//---------- crazy T1-Fit ENDE ------------
//cout << " Heisenberg Fehler " << endl; 
	//---------- T1-Histogramm ANFANG ------------ 
	
	//if ((int)(datat1(0,islice,iy,ix)/20.) > 0.  && (int)(datat1(0,islice,iy,ix)/20.) < 4999.  ){ hist[(int)(datat1(0,islice,iy,ix)/20.)] ++ ; 
	//	if (datat1(0,islice,iy,ix)/20. < 0. ) cout << " T1 = " << datat1(0,islice,iy,ix)/20. << endl; 
	//	if (datat1(0,islice,iy,ix)/20. > 1000. ) cout << " T1 = " << datat1(0,islice,iy,ix)/20. << endl; 
 	//}
	

	//Backup check, ob summe der U's auch das gesammt Signal ergibt
	//dataError(0,islice,iy,ix) = abs(1. - dataWM(0,islice,iy,ix) - dataGM(0,islice,iy,ix) - dataCSF(0,islice,iy,ix));  
		
        }  
      }
    }

cout << " Hallo 5 " << endl;
  datat2.autowrite("S0.nii");
 // dataallS.autowrite("T1_map.nii");
  datat1.autowrite("T2s.nii");
  datat3.autowrite("Non_linearity.nii");

//for(int i = 0; i< 250 ; i++){
//	outf << i *20 << "  " << hist[i] << endl; 
//	}
//  outf.close();

  return 0;

}

/*
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

*/

