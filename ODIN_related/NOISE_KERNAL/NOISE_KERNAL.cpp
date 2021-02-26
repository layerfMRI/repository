
// Ausführen mit ./MAFI_COMPLEX S46_MAFI_1.nii S47_MAFI_1.nii 0.5 90 2000
 // mit make compilieren ... alles muss von pandamonium aus passieren

//#include <odindata/data.h>
//#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
#include <odindata/fitting.h>
#include <iostream>
#include <string>
#include <stdlib.h>
 
 
#include <gsl/gsl_fit.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_statistics_double.h>

#define PI 3.14159265;
// Signals changes for every Voxel
 int samples = 10; 





void usage() { cout << "Layer_me <Bild 1 >" << endl;}
 

int main(int argc,char* argv[]) {

  if (argc!=2) {usage(); return 0;}
  STD_string filename1(argv[1]);


//fürs Histogramm

 	
    ofstream outf("layer.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
    ofstream outfn("time_norm.dat");
  if (!outfn) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

    ofstream outtime("time_courses.dat");
  if (!outtime) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

    ofstream outftn("time_coarses_plot.dat");
  if (!outftn) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

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


//nrep = 100 ; // only while debugging.
int ingnore = 0;


cout << "nrep = " << nrep << endl; 

int kernal_size = 13; // This is the maximal number of layers. I don't know how to allocate it dynamically.

double Nkernal[kernal_size][kernal_size] ; 

int Number_of_averages = 0; 

double Number_AVERAG[kernal_size][kernal_size] ; 

  Data<float,4> nii_kernal;
  nii_kernal.resize(1,1,kernal_size,kernal_size);
  nii_kernal=0.0;

cout << " kernal_size " <<  kernal_size << " kernal_size/2 " <<  kernal_size/2 <<   endl; 

//////////////////////////
////////allokate and se zero 
////////////////////////

double vec_n[nrep] ;
double vec_nn[nrep] ;

	for(int timestep = 0; timestep < nrep ; timestep++) {
		vec_n[timestep] = 0; 
		vec_nn[timestep] = 0; 
	}



for(int i = 0; i < kernal_size; i++) {
	for(int j = 0; j < kernal_size ; j++) {
		Nkernal[i][j] = 0; 
		Number_AVERAG[i][j] = 0; 
	}
}



 
// get mean in one time ste 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=kernal_size/2+1; iy<sizePhase-kernal_size/2-1; ++iy){
        for(int ix=kernal_size/2+1; ix<sizeRead-kernal_size/2-1; ++ix){

		for(int timestep = 0 ; timestep < nrep  ; timestep++) {
		   vec_n[timestep] = file1(timestep,islice,iy,ix) ;
        	}
		
		 for(int kernaly=0; kernaly<kernal_size; ++kernaly){
        		for(int kernalx=0; kernalx<kernal_size; ++kernalx){
		
				for(int timestep = 0 ; timestep < nrep  ; timestep++) {
		  		 	vec_nn[timestep] = file1(timestep,islice,iy-kernal_size/2+kernaly,ix-kernal_size/2+kernalx) ;
        			}
				//if (gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep) > -1 &&gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep) < 1 && gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep) != 0 ){

				if (gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep) == gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep) ){
				Nkernal[kernalx][kernaly] = Nkernal[kernalx][kernaly] +  gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep);
				//cout << " iy= " << iy << " ix= " << ix <<  " kernaly= " << iy-kernal_size/2+kernaly << " kernalx= " << ix-kernal_size/2+kernalx << " correl=" << gsl_stats_correlation (vec_n, 1, vec_nn , 1, nrep)<<   endl;
				Number_AVERAG[kernalx][kernaly] = Number_AVERAG[kernalx][kernaly] +1; 
				}
 
				
			}
		}

		Number_of_averages = Number_of_averages+1 ;
      } 
    }
  }

cout << " Number_of_averages " << Number_of_averages  <<   endl; 

for(int i = 0; i < kernal_size; i++) {
	for(int j = 0; j < kernal_size ; j++) {
		Nkernal[i][j] = Nkernal[i][j]/Number_AVERAG[i][j] ; 
		nii_kernal(0,0,i,j) = Nkernal[i][j] ; 
	}
}

		//Nkernal[kernal_size/2][kernal_size/2] = 0.5; 

///////////
////get corss correl matrix
//////////




	for(int i = 0; i< kernal_size ; i++){
		for(int j = 0; j< kernal_size ; j++){
			outf << 1*i << "  " << 1*j << "  " <<  Nkernal[i][j] <<  endl;
			outf << 1*i << "  " << 1*j+1 << "  " <<  Nkernal[i][j] <<  endl;
		}
		outf << endl; 
		for(int j = 0; j< kernal_size ; j++){
			outf << 1*i+1  << "  " << 1*j << "  " <<  Nkernal[i][j] <<  endl;
			outf << 1*i+1  << "  " << 1*j+1 << "  " <<  Nkernal[i][j] <<  endl;
		}
		outf << endl; 
	}

nii_kernal.autowrite("Kernal"+filename);


  outf.close();
  outfn.close();
  outtime.close();

  return 0;

}


