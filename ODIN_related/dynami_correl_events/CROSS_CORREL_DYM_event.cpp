
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

  double pi = 3.1415927 ; 
  double B0 = 7. ;  // in T 
  double TE = 0.020; //in s 
  double dChi = 0.000000571 ; //  
  double _gamma = 42570000.* 2.* pi ; // Hz/T



void usage() { cout << "Layer_me <Bild 1 >   <mask with layers>  <cutoff> " << endl;}
 

int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename4(argv[2]);
  float cutoff(atoi(argv[3])); 

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


  Data<float,4> mask;
  mask.autoread(filename4); 

//nrep = 80 ; // only while debugging.
int ingnore = 0;



cout << "nrep = " << nrep << endl; 

int numb_layers = 100; // This is the maximal number of layers. I don't know how to allocate it dynamically.

double numb_voxels[numb_layers] ; 
double mean_layers[numb_layers] ; 
double std_layers[numb_layers] ; 

for (int i = 0; i < numb_layers; i++) {
  mean_layers[i] = 0.; 
   std_layers[i] = 0.; 
  numb_voxels[i] = 0.; 
}


// count numer of voxels in every layer
  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (mask(0,islice,iy,ix) == i+1 )
			//cout <<  "numb_layers " << i << endl; 
		    numb_voxels[i] ++; 
		
        }  
      } 
    }
  }

/// get actual number of layers.
for(int i = numb_layers-1; i >= 0; i--) {
	if (numb_voxels[i] == 0) numb_layers = i;
}

cout << " there are  " <<  numb_layers  << " layers in the mask " <<  endl; 

//////////////////////////
////////get mean time course for every layer 
////////////////////////

double vec_n[numb_layers][nrep] ;
for(int i = 0; i < numb_layers; i++) {
	for(int timestep = 0; timestep < nrep ; timestep++) {
		vec_n[i][timestep] = 0; 
	}
}


for(int timestep = 0 + ingnore; timestep < nrep  ; timestep++) {
// get mean in one time ste 
  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (mask(0,islice,iy,ix) == i+1 )
		    mean_layers[i]  = mean_layers[i] + file1(timestep,islice,iy,ix)/numb_voxels[i]; 
		
        }  
      } 
    }

   vec_n[i][timestep-ingnore] = mean_layers[i] ; 
   mean_layers[i] = 0.; 
  }

}

///////////
//// write out time courses of individuall layers is calculated
//////////

	for(int i = 0; i< numb_layers ; i++){
		cout  << " layer " << i << " hat " <<numb_voxels[i] << endl  ; 
	}

	
	for(int timestep = 0 ; timestep < nrep ; timestep++) {
		for(int i = 0; i< numb_layers ; i++){
		
			//cout   << timestep  << "  " <<  vec_n[i][timestep] ; 
			outtime   << timestep  << "  " << i  << "  " <<  vec_n[i][timestep] << endl ; 
		}
		//cout << endl;
		outtime << endl; 
	}


	for(int timestep = 0 ; timestep < nrep ; timestep++) {
		for(int i = 0; i< numb_layers ; i++){
		
			//cout   << timestep  << "  " <<  vec_n[i][timestep] ; 
			outfn   << timestep  << "  " << i  << "  " <<  vec_n[i][timestep]/gsl_stats_mean (vec_n[i],  1,nrep) << endl ; 
		}
		//cout << endl;
		outfn << endl; 
	}


for(int timestep = 0 ; timestep < nrep ; timestep++) {
		outftn   << timestep  ;
		for(int i = 0; i< numb_layers ; i++){
			//cout   << timestep  << "  " <<  vec_n[i][timestep] ; 
			outftn   << "  " <<  vec_n[i][timestep]/gsl_stats_mean (vec_n[i],  1,nrep) ; 
		}
		outftn << endl;
		 
	}
///////////
////calculate  corss correl matrix
//////////

double cross_correl[numb_layers][numb_layers] ; 
double cross_correl_norm[numb_layers][numb_layers] ; 
	for(int i = 0; i< numb_layers ; i++){
		for(int j = 0; j< numb_layers ; j++){
			cross_correl[i][j] = 0. ;
			cross_correl_norm[i][j] = 0. ;
		}
	}

	for(int i = 0; i< numb_layers ; i++){
		for(int j = 0; j< numb_layers ; j++){
			cross_correl[i][j] = gsl_stats_correlation (vec_n[i],  1, vec_n[j] ,1 , nrep-ingnore );
		}
	}

///////////
////write  corss correl matrix
//////////

	for(int i = 0; i< numb_layers ; i++){
		for(int j = 0; j< numb_layers ; j++){
			outf << 1*i << "  " << 1*j << "  " <<  cross_correl[i][j] <<  endl;
			outf << 1*i << "  " << 1*j+1 << "  " <<  cross_correl[i][j] <<  endl;
		}
		outf << endl; 
		for(int j = 0; j< numb_layers ; j++){
			outf << 1*i+1  << "  " << 1*j << "  " <<  cross_correl[i][j] <<  endl;
			outf << 1*i+1  << "  " << 1*j+1 << "  " <<  cross_correl[i][j] <<  endl;
		}
		outf << endl; 
	}


  outf.close();
  outfn.close();
  outtime.close();

///////////
////dynamic   corss correl matrix
//////////



// Parameters for dynamic cross correlation matrix
int lenght_ocorrelinter = 40; // in TR
int interval_between_correlPeriods = 5; //in TR 
int numb_ocorrels = (nrep - lenght_ocorrelinter)/interval_between_correlPeriods;
int running_intex = 0;
cout << "lenght_ocorrelinter=" << lenght_ocorrelinter << "   interval_between_correlPeriods="<< interval_between_correlPeriods << "  numb_ocorrels="<< numb_ocorrels << endl;  

double vec_nd[numb_layers][lenght_ocorrelinter] ;
for(int i = 0; i < numb_layers; i++) {
	for(int timestep = 0; timestep < lenght_ocorrelinter ; timestep++) {
		vec_nd[i][timestep] = 0; 
	}
}


  Data<float,4> correl_dym;
  correl_dym.resize(numb_ocorrels,1,numb_layers,numb_layers);
  correl_dym=0.0;

for (int time_ = 0 ; time_ < nrep-lenght_ocorrelinter ; time_ =  time_ + interval_between_correlPeriods ){

	running_intex = (time_)/interval_between_correlPeriods ; 
	for (int timestep = 0 ; timestep < lenght_ocorrelinter ; timestep =  timestep + 1 ){
		for(int i = 0; i< numb_layers ; i++){
			vec_nd[i][timestep] = vec_n[i][timestep+time_];
		}
	}

	for(int i = 0; i< numb_layers ; i++){
		for(int j = 0; j< numb_layers ; j++){
			correl_dym(running_intex,0,i,j) =  gsl_stats_correlation (vec_nd[i],  1, vec_nd[j] , 1, lenght_ocorrelinter );
		}
	}
 cout << " time_=" << time_ <<   "   running index=" << running_intex <<  endl;
}


///////////
//// Resting state event averaging
//////////
 cout << " starte mit events "  <<  endl;
int event_dur = 50 ;

double vec_event[numb_layers][event_dur] ;
for(int i = 0; i < numb_layers; i++) {
	for(int timestep = 0; timestep < event_dur ; timestep++) {
		vec_event[i][timestep] = 0; 
	}
}

int numb_of_event = 5 ; 
int event_times[numb_of_event] ; 
for(int timestep = 0; timestep < numb_of_event ; timestep++) {
		event_times[timestep] = 0; 
	}
// find events 
event_times[0] = 63;
event_times[1] = 94;
event_times[2] = 113;
event_times[3] = 132;
event_times[4] = 149;
for(int timestep = 0; timestep < numb_of_event ; timestep++) {
		event_times[timestep] = event_times[timestep] - 10 ; 
	}

for(int eventstep = 0; eventstep < numb_of_event ; eventstep++) {
	for (int timestep = 0 ; timestep < event_dur ; timestep =  timestep + 1 ){
		for(int i = 0; i< numb_layers ; i++){
				vec_event[i][timestep] = vec_event[i][timestep] + vec_n[i][timestep+event_times[eventstep]]/(double)numb_of_event;
		}
	}
}

 ofstream outevent("event_time_courses.dat");
  if (!outevent) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

for(int timestep = 0 ; timestep < event_dur ; timestep++) {
		outevent   << timestep  ;
		for(int i = 0; i< numb_layers ; i++){
			outevent   << "  " <<  vec_event[i][timestep]/gsl_stats_mean (vec_event[i],  1, event_dur) ; 
		}
		outevent << endl;
	}
outevent.close();


 ofstream outevent3dtime("event_time_courses_3d.dat");
  if (!outevent3dtime) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
	for(int timestep = 0 ; timestep < event_dur ; timestep++) {
		for(int i = 0; i< numb_layers ; i++){
			outevent3dtime   << timestep  << "  " << i  << "  " <<  vec_event[i][timestep]/gsl_stats_mean (vec_event[i],  1, event_dur) << endl ; 
		}
		outevent3dtime << endl; 
	}


outevent3dtime.close();
correl_dym.autowrite("Correlation_Matrix_Dym.nii");

  return 0;

}


