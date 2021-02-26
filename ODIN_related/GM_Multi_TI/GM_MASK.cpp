   
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



void usage() { cout << "GM Mask <Bild 1 > <Bild 2> <Bild 3> <Bild 4> <Bild 5>  <Ti 1> <Ti 2> <Ti 3> <Ti 4> <Ti 5>  <cutoff> " << endl;}
 
 

int main(int argc,char* argv[]) {

  if (argc!=12) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);
  STD_string filename4(argv[4]);
  STD_string filename5(argv[5]);
  float ti1(atoi(argv[6]));
  float ti2(atoi(argv[7]));
  float ti3(atoi(argv[8]));
  float ti4(atoi(argv[9]));
  float ti5(atoi(argv[10]));
  float cutoff(atoi(argv[11])); 

//fürs Histogramm

 	double hist[250]  ; // von 1000 bis 6000 in 10er Schritten
	for (int i = 0; i< 250 ; i++) hist[i] = 0.; 
    ofstream outf("hist.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  



  float Mt0 = 0.;

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

  Data<float,4> file2;
  file2.autoread(filename2);

  Data<float,4> file3;
  file3.autoread(filename3);

  Data<float,4> file4;
  file4.autoread(filename4);

  Data<float,4> file5;
  file5.autoread(filename5);



  double dM[3][3]; 
  double adM[3][3]; 
  double test[3][3]; 
 for(int i = 0; i< 3 ; i ++){
	for(int j = 0; j < 3 ; j++){
	dM[i][j]= adM[i][j] = test[i][j] = 0.; 
	}
  }



//Einzulesende Daten preparieren z.B. steady state Bilder mitteln 
  Data<float,4> dataM0;
  dataM0.resize(1,sizeSlice,sizePhase,sizeRead);
  dataM0=0.0;

  Data<float,4> dataGM; 
  dataGM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataGM=0.0;

  Data<float,4> dataWM;
  dataWM.resize(1,sizeSlice,sizePhase,sizeRead);
  dataWM=0.0;

  Data<float,4> dataCSF;
  dataCSF.resize(1,sizeSlice,sizePhase,sizeRead);
  dataCSF=0.0;

 /* Data<float,4> dataError;
  dataError.resize(1,sizeSlice,sizePhase,sizeRead);
  dataError=0.0;

  Data<float,4> dataallS;
  dataallS.resize(4,sizeSlice,sizePhase,sizeRead);
  dataallS=0.0;
*/

  Data<float,4> datat1;
  datat1.resize(1,sizeSlice,sizePhase,sizeRead);
  datat1=0.0;

// Allozieren für Cracy fit
	Array<float,1> sig (5);
	Array<float,1> inversiontime (5);
	Array<float,1> ysigma (5);

cout << "nrep = " << nrep << endl; 

  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  
		dataM0(0,islice,iy,ix) = (file1(0,islice,iy,ix) + file2(0,islice,iy,ix) + file3(0,islice,iy,ix) + file4(0,islice,iy,ix) + file5(0,islice,iy,ix) )/5.;	
        }  
      }
    }

//cout << "Bis hier " << endl; 
  Data<float,4> dataS;
  dataS.resize(5,sizeSlice,sizePhase,sizeRead);
  dataS=0.0;



   float elements = (double) (nrep - 1)/2 ;

 for(int timestep = 1; timestep < nrep; timestep = timestep + 2){
 //cout << " timestep = " << timestep << endl; 
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		dataS(0,islice,iy,ix) = dataS(0,islice,iy,ix) - (file1(timestep,islice,iy,ix))/elements ;  // - stimmt nur für bestimmte TI
		dataS(1,islice,iy,ix) = dataS(1,islice,iy,ix) - (file2(timestep,islice,iy,ix))/elements ; 
		dataS(2,islice,iy,ix) = dataS(2,islice,iy,ix) - (file3(timestep,islice,iy,ix))/elements ; 
		dataS(3,islice,iy,ix) = dataS(3,islice,iy,ix) + (file4(timestep,islice,iy,ix))/elements ; 
		dataS(4,islice,iy,ix) = dataS(4,islice,iy,ix) + (file5(timestep,islice,iy,ix))/elements ; 
        }  
      } 
    }
  }
 
cout << " Hallo 1 " << endl; 

//Signal auf MO normieren 
   for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		dataS(0,islice,iy,ix) = dataS(0,islice,iy,ix)/dataM0(0,islice,iy,ix)  ;  // - stimmt nur für bestimmte TI
		dataS(1,islice,iy,ix) = dataS(1,islice,iy,ix)/dataM0(0,islice,iy,ix)  ; 
		dataS(2,islice,iy,ix) = dataS(2,islice,iy,ix)/dataM0(0,islice,iy,ix)  ; 
		dataS(3,islice,iy,ix) = dataS(3,islice,iy,ix)/dataM0(0,islice,iy,ix)  ; 
		dataS(4,islice,iy,ix) = dataS(4,islice,iy,ix)/dataM0(0,islice,iy,ix)  ; 
        }  
      } 
    }

// Durch null Teilen  Als Exp Zerfall darstellen
   for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		for(int t = 0; t < 5 ; t++){
			if(dataS(t,islice,iy,ix) > -1. && dataS(t,islice,iy,ix) < 1. ) dataS(t,islice,iy,ix) = dataS(t,islice,iy,ix)-1.; 
			else dataS(t,islice,iy,ix) = dataS(t,islice,iy,ix); 
		}
	}
      }
   }

cout << " Hallo 2 " << endl; 

//cout << " sizeSlice =  "<<sizeSlice<< "  sizePhase= "<< sizePhase << " sizeRead =  " << sizeRead << endl; 
//Files, in die später die Masken sein werden




 	//HAUPT SCHLEIFE 
    for(int islice=0; islice<sizeSlice; ++islice){
//cout << " islice = " << islice << endl; 
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
          if(dataM0(0,islice,iy,ix)>=cutoff && dataM0(0,islice,iy,ix) < 5000){




//cout << " Hallo 3 " << islice  << "   " << iy <<" " << sizePhase <<  endl; 
	
 /*

	//-------------- GSL Inversion ANFANG ---------------
double chisq;
       gsl_matrix *X, *cov;
       gsl_vector *y, *w, *c;
       int n = 4 ; 

       X = gsl_matrix_alloc (n, 4);
       y = gsl_vector_alloc (n);
       w = gsl_vector_alloc (n);
       c = gsl_vector_alloc (4);
       cov = gsl_matrix_alloc (4, 4);

	gsl_matrix_set (X, 0, 0, func_M_WM(ti1 + islice * echo_space)); //U_WM
	gsl_matrix_set (X, 1, 0, func_M_WM(ti2 + islice * echo_space));
	gsl_matrix_set (X, 2, 0, func_M_WM(ti3 + islice * echo_space));
	gsl_matrix_set (X, 3, 0, func_M_WM(ti4 + islice * echo_space));
	gsl_matrix_set (X, 0, 1, func_M_GM(ti1 + islice * echo_space)); //U_GM
	gsl_matrix_set (X, 1, 1, func_M_GM(ti2 + islice * echo_space));
	gsl_matrix_set (X, 2, 1, func_M_GM(ti3 + islice * echo_space));
	gsl_matrix_set (X, 3, 1, func_M_GM(ti4 + islice * echo_space));
	gsl_matrix_set (X, 0, 2, func_M_CSF(ti1 + islice * echo_space)); //U_CSF
	gsl_matrix_set (X, 1, 2, func_M_CSF(ti2 + islice * echo_space));
	gsl_matrix_set (X, 2, 2, func_M_CSF(ti3 + islice * echo_space));
	gsl_matrix_set (X, 3, 2, func_M_CSF(ti4 + islice * echo_space));
	gsl_matrix_set (X, 0, 3, 1.0); //const
	gsl_matrix_set (X, 1, 3, 1.0);
	gsl_matrix_set (X, 2, 3, 1.0);
	gsl_matrix_set (X, 3, 3, 1.0);
        gsl_vector_set (y, 0, dataS(0,islice,iy,ix));     //Gemessenes Signal
        gsl_vector_set (y, 1, dataS(1,islice,iy,ix));
        gsl_vector_set (y, 2, dataS(2,islice,iy,ix));
        gsl_vector_set (y, 3, dataS(3,islice,iy,ix));
        gsl_vector_set (w, 0, 1.0);    //Fehler Dummy
        gsl_vector_set (w, 1, 1.0);
        gsl_vector_set (w, 2, 1.0);
        gsl_vector_set (w, 3, 1.0);
     
       {
         gsl_multifit_linear_workspace * work  = gsl_multifit_linear_alloc (n, 4);
         gsl_multifit_wlinear (X, w, y, c, cov, &chisq, work);
         gsl_multifit_linear_free (work);
       }
     
     #define C(i) (gsl_vector_get(c,(i)))
     #define COV(i,j) (gsl_matrix_get(cov,(i),(j)))
     
       /*{
         printf ("# best fit: Y = %g a + %g b + %g c + %g d\n",   C(0), C(1), C(2), C(3));
         printf ("# covarianz matrix:\n");
         printf ("[ %+.5e, %+.5e, %+.5e , %+.5e \n", COV(0,0), COV(0,1), COV(0,2), COV(0,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e \n", COV(1,0), COV(1,1), COV(1,2), COV(1,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e \n", COV(2,0), COV(2,1), COV(2,2), COV(2,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e ]\n", COV(3,0), COV(3,1), COV(3,2), COV(3,3));
         printf ("# chisq = %g\n", chisq);
       }*/
     
/*
	dataWM(0,islice,iy,ix) = C(0);
	dataGM(0,islice,iy,ix) = C(1);
	dataCSF(0,islice,iy,ix) = C(2);

	
       gsl_matrix_free (X);
       gsl_vector_free (y);
       gsl_vector_free (w);
       gsl_vector_free (c);
       gsl_matrix_free (cov);

	// -------------- GSL Inversion ENDE ------------

	
//cout << " Hallo 3 " << endl; 

*/
	//---------- crazy T1-Fit ANFANG ------------
ExponentialFunction expf;
  FunctionFitDerivative expfit;
  expfit.init(expf,5);
  	ysigma(0) = 1.0;
  	ysigma(1) = 1.0;
  	ysigma(2) = 1.0;
  	ysigma(3) = 1.0;
  	ysigma(4) = 1.0;
//cout << " Hallo 4 " << endl;

	    sig (0) = dataS(0,islice,iy,ix);
	    sig (1) = dataS(1,islice,iy,ix);
	    sig (2) = dataS(2,islice,iy,ix);
	    sig (3) = dataS(3,islice,iy,ix); 
	    sig (4) = dataS(4,islice,iy,ix);
//if(sig (0) <=  0 ) sig (0) = 0.1; 
//if(sig (1) <=  0 ) sig (1) = 0.1; 
//if(sig (2) <=  0 ) sig (2) = 0.1; 
//if(sig (3) <=  0 ) sig (3) = 0.1; 
	inversiontime (0) = ti1+ echo_space * islice ;
	inversiontime (1) = ti2+ echo_space * islice;
	inversiontime (2) = ti3+ echo_space * islice;
	inversiontime (3) = ti4+ echo_space * islice;
	inversiontime (4) = ti5+ echo_space * islice;
	    expf.A.val = -1.; //Zuordnung
	    expf.lambda.val = -0.001;//Startwert lambda

//cout << " Hallo 5 " << endl;
	    expfit.fit(sig,ysigma,inversiontime);
cout << " Heisenberg Fehler " << endl;	
           datat1(0,islice,iy,ix)=  -1./expf.lambda.val ;

if (datat1(0,islice,iy,ix) < 0.   ) datat1(0,islice,iy,ix) = 0.;
if (datat1(0,islice,iy,ix) > 4000.) datat1(0,islice,iy,ix) = 0.;
	//---------- crazy T1-Fit ENDE ------------
cout << " Heisenberg Fehler " << endl; 
	//---------- T1-Histogramm ANFANG ------------ 
	
	if ((int)(datat1(0,islice,iy,ix)/20.) > 0.  && (int)(datat1(0,islice,iy,ix)/20.) < 4999.  ){ hist[(int)(datat1(0,islice,iy,ix)/20.)] ++ ; 
if (datat1(0,islice,iy,ix)/20. < 0. ) cout << " T1 = " << datat1(0,islice,iy,ix)/20. << endl; 
if (datat1(0,islice,iy,ix)/20. > 1000. ) cout << " T1 = " << datat1(0,islice,iy,ix)/20. << endl; 
 }
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
	/*
	//---------  DEBUG ----------------
	
	if (  iy >= 58 && iy <= 61 ){ //WM //&& ix >= 85 &&  ix <= 88 
	dataS(0,islice,iy,ix) = func_M_WM(ti1 + islice * echo_space);
	dataS(1,islice,iy,ix) = func_M_WM(ti2 + islice * echo_space);
	dataS(2,islice,iy,ix) = func_M_WM(ti3 + islice * echo_space);
	dataS(3,islice,iy,ix) = func_M_WM(ti4 + islice * echo_space);
	}
	if ( iy >= 39 && iy <= 42  ){ //GM  && ix >= 37 && ix <= 40
	dataS(0,islice,iy,ix) = func_M_GM(ti1 + islice * echo_space);
	dataS(1,islice,iy,ix) = func_M_GM(ti2 + islice * echo_space);
	dataS(2,islice,iy,ix) = func_M_GM(ti3 + islice * echo_space);
	dataS(3,islice,iy,ix) = func_M_GM(ti4 + islice * echo_space);
	}
	if (  iy >= 67 && iy <= 70  ){ //CSF  && ix >= 78 && ix <= 81 
	dataS(0,islice,iy,ix) = func_M_CSF(ti1 + islice * echo_space);
	dataS(1,islice,iy,ix) = func_M_CSF(ti2 + islice * echo_space);
	dataS(2,islice,iy,ix) = func_M_CSF(ti3 + islice * echo_space);
	dataS(3,islice,iy,ix) = func_M_CSF(ti4 + islice * echo_space);
	} // --------- DEBUG ENDE ------------
*/


          }//if-cutoff schleife zu 
		else {
			dataGM(0,islice,iy,ix) = 0;
			dataWM(0,islice,iy,ix) = 0;
			dataCSF(0,islice,iy,ix) = 0;
			datat1(0,islice,iy,ix) = 0.; 
		}

	
	//Backup check, ob summe der U's auch das gesammt Signal ergibt
	//dataError(0,islice,iy,ix) = abs(1. - dataWM(0,islice,iy,ix) - dataGM(0,islice,iy,ix) - dataCSF(0,islice,iy,ix));  
		
        }  
      }
    }


  dataGM.autowrite("GM_Mask.nii");
  dataWM.autowrite("WM_Mask.nii");
  dataCSF.autowrite("CSF_Mask.nii");
  dataM0.autowrite("M0_Bild.nii");
  dataS.autowrite("Sample.nii");
 // dataallS.autowrite("T1_map.nii");
  datat1.autowrite("T1.nii");


for(int i = 0; i< 250 ; i++){
	outf << i *20 << "  " << hist[i] << endl; 
	}
  outf.close();

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

