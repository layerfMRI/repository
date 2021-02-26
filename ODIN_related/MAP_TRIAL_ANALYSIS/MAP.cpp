
// Ausführen mit ./MAFI_COMPLEX S46_MAFI_1.nii S47_MAFI_1.nii 0.5 90 2000
 // mit make compilieren ... alles muss von pandamonium aus passieren

#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
#include <iostream>
#include <string>
#include <stdlib.h>

#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "CBV MAP  <VASO>  <BOLD>  <Mask>" << endl;}


int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);


  Range all=Range::all();
   
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";
  //  in datei schreiben
          double thresh = 0.2;
  ofstream outf("t_course.dat");
  if (!outf) {
  cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

   ofstream outfl("t_course_long.dat");
  if (!outfl) {
  cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

  Data<float,4> file_VASO;
  file_VASO.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file_VASO.extent(firstDim);
  int sizeSlice=file_VASO.extent(secondDim);
  int sizePhase=file_VASO.extent(thirdDim);
  int sizeRead=file_VASO.extent(fourthDim);


  Data<float,4> file_BOLD;
  file_BOLD.autoread(filename2);
  //int nrep=file2.extent(firstDim);
  //int sizeSlice=file2.extent(secondDim);
  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);

  Data<float,4> mask;
  mask.autoread(filename3);

  int N = nrep; //Anzahl der Zeitschritte
  double sig_up = 0. ; // Platouhöhe vom Signal
  double sig_base = 0. ; // Baseline vom Signal
  double CBVr = 0.055; 	

  double TR_in_s = 3.;
  int initial_rest = 0.; // in TR
    int para_size = 20; // in TR
  //double para_size = 20.; // in TR
  int N_paradigms = (double)(N - initial_rest)/((double)para_size); // in TR


cout << nrep <<" Zeitschritte" << endl; 
cout << (double)(N - initial_rest)/((double)para_size) << " paradigms " << endl;

nrep = N_paradigms * para_size ; 
N = nrep; 
cout << nrep <<"new  Zeitschritte" << endl; 
cout << (double)(N - initial_rest)/((double)para_size) << " new  paradigms " << endl;



  Data<float,4> data_VASO;
  data_VASO.resize( para_size ,sizeSlice,sizePhase,sizeRead);
  data_VASO=0.0;

cout << " bis hier " << endl; 

  Data<float,4> data_BOLD;
  data_BOLD.resize( para_size ,sizeSlice,sizePhase,sizeRead);
  data_BOLD=0.0;
  
  Data<float,4> data_un_VASO;
  data_un_VASO.resize( para_size ,sizeSlice,sizePhase,sizeRead);
  data_un_VASO=0.0;

  Data<float,4> data_un_BOLD;
  data_un_BOLD.resize( para_size ,sizeSlice,sizePhase,sizeRead);
  data_un_BOLD=0.0;



  Data<float,4> data_dBOLD;
  data_dBOLD.resize(1,sizeSlice,sizePhase,sizeRead);
  data_dBOLD=0.0;
  
    Data<float,4> data_dVASO;
  data_dVASO.resize(1,sizeSlice,sizePhase,sizeRead);
  data_dVASO=0.0;

cout << " Ich laufe bis hier 1 " << endl; 
  
double mean_rVASO = 0.; 
double mean_rBOLD = 0.; 

	//BILDER in einen Zeitverlauf schachteln
   for(int timestep=initial_rest; timestep < N ; timestep ++ ) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
	
	data_VASO((int(timestep-initial_rest) % int(para_size)),islice,iy,ix) = data_VASO((int(timestep-initial_rest) % int(para_size)),islice,iy,ix) + file_VASO(timestep,islice,iy,ix)/(double)N_paradigms; 
	data_BOLD((int(timestep-initial_rest) % int(para_size)),islice,iy,ix) = data_BOLD((int(timestep-initial_rest) % int(para_size)),islice,iy,ix) + file_BOLD(timestep,islice,iy,ix)/(double)N_paradigms; 

        }
      }
    }
//cout <<(int(timestep-initial_rest) % int(para_size))<< " renzo" << endl; 
   }
cout << " Ich laufe bis hier 2" << endl; 

	// unnormiert für spätere time courses
   for(int timestep = 0; timestep < para_size ; timestep ++ ) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
		data_un_VASO(timestep,islice,iy,ix) = data_VASO(timestep,islice,iy,ix);
		data_un_BOLD(timestep,islice,iy,ix) = data_BOLD(timestep,islice,iy,ix);
	}
       }
     }
    }

cout << " Ich laufe bis hier 2b" << endl; 

	//Normalisieren
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
		mean_rVASO  = (data_VASO(para_size/2-5,islice,iy,ix) + data_VASO(para_size/2-4,islice,iy,ix) + data_VASO(para_size/2-3,islice,iy,ix) + data_VASO(para_size/2-2,islice,iy,ix) + data_VASO(para_size/2-1,islice,iy,ix) )/6.; 
		mean_rBOLD  = (data_BOLD(para_size/2-5,islice,iy,ix) + data_BOLD(para_size/2-4,islice,iy,ix) + data_BOLD(para_size/2-5,islice,iy,ix) + data_BOLD(para_size/2-2,islice,iy,ix) + data_BOLD(para_size/2-1,islice,iy,ix) )/6.;

	  for(int timestep=0; timestep < int(para_size) ; timestep ++ ) {
	  data_VASO(timestep,islice,iy,ix) = data_VASO(timestep,islice,iy,ix);
	  data_BOLD(timestep,islice,iy,ix) = data_BOLD(timestep,islice,iy,ix);
	  }

        }
      }
    }   

cout << " Ich laufe bis hier 2c" << endl; 

	//dSignal Maps
double sup_VASO = 0.; 
double sup_BOLD = 0.; 
double slow_VASO = 0.; 
double slow_BOLD = 0.; 

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){

		sup_VASO =  data_VASO(para_size-1,islice,iy,ix) + data_VASO(para_size-2,islice,iy,ix) + data_VASO(para_size-3,islice,iy,ix) +  data_VASO(para_size-4,islice,iy,ix) ;
		sup_BOLD =  data_BOLD(para_size-1,islice,iy,ix) + data_BOLD(para_size-2,islice,iy,ix) + data_BOLD(para_size-3,islice,iy,ix) +  data_BOLD(para_size-4,islice,iy,ix) ;
		slow_VASO =  data_VASO(para_size/2-1,islice,iy,ix) + data_VASO(para_size/2-2,islice,iy,ix) + data_VASO(para_size/2-3,islice,iy,ix) +  data_VASO(para_size/2-4,islice,iy,ix) ;
		slow_BOLD =  data_BOLD(para_size/2-1,islice,iy,ix) + data_BOLD(para_size/2-2,islice,iy,ix) + data_BOLD(para_size/2-3,islice,iy,ix) +  data_BOLD(para_size/2-4,islice,iy,ix) ;


	  if ( mask(0,islice,iy,ix) >= thresh ){
	      data_dVASO(0,islice,iy,ix) = (sup_VASO-slow_VASO)/slow_VASO ;
	      data_dBOLD(0,islice,iy,ix) = (sup_BOLD-slow_BOLD)/slow_BOLD ;
	  }
	//if ( data_dVASO(0,islice,iy,ix) <= -0.005 || data_BOLD(0,islice,iy,ix) <= 0 ) mask(0, islice,iy,ix) = 0; 

        }
      }
    }
   
cout << " Ich laufe bis hier 3" << endl; 


//berechne reltive Signaländerung
	// Annahme: Signal Platou nach 12 sec. , und wieder nach 12 sec bei Baseline D.H TR 4-10 baseline 14-0 ist VASO_Abfall. 
/*
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
	   if (file2(0,islice,iy,ix) >= 0.1 ) {
		for(int timestep=0; timestep < N/6 ; timestep ++ ) {
			if (timestep >= 3 && timestep <= 8) sig_up   = sig_up   +  data1(timestep, islice,iy,ix) ; 
			if ((timestep >= 11 && timestep <= 16) || timestep == 0 )sig_base = sig_base +  data1(timestep, islice,iy,ix) ;	

        	}
			if ((1.-sig_base/sig_up)/CBVr * 1./(file2(0,islice,iy,ix)) < 0.8 && (1.-sig_base/sig_up)/CBVr * 1./(file2(0,islice,iy,ix)) > 0.01 ){
			data2(0, islice,iy,ix) = (1.-sig_base/sig_up)/CBVr *  1./(file2(0,islice,iy,ix)); 
			}
			if ((1.-sig_base/sig_up)/CBVr * 1./(file2(0,islice,iy,ix)) >= 0.8  ){
			data2(0, islice,iy,ix) = 0.8 ; 
			}
			if ( (1.-sig_base/sig_up)/CBVr * 1./(file2(0,islice,iy,ix)) <= 0.025 ){
			data2(0, islice,iy,ix) = 0.; 
			}
			sig_up = 0.; 
			sig_base = 0.;
			//DEBUG
			// data2(0, islice,iy,ix) = file2(0,islice,iy,ix); 
	   }
	}
     }
    }
*/

// Number of voxels in MAS
int N_voxels = 0;  
//nehme nur signifikante Voxels 
// suche cluster mit den meisten Voxeln 


double cluster_number = 0.; 
  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
	  if (mask(0, islice,iy,ix) >= thresh ){
		N_voxels ++; 
		
	  }
     }
    }
  }

cout << " Number of Voxels in Mask = " << N_voxels << endl; 


//Time courses 
double t_VASO[int(para_size)] ; 
double t_BOLD[int(para_size)] ; 
for(int t = 0; t < para_size ; t++){
t_VASO[t] = 0.; 
t_BOLD[t] = 0.; 
  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
	    if (mask(0, islice,iy,ix) >= thresh ){
		t_VASO[t] = t_VASO[t] + data_un_VASO(t, islice,iy,ix); 
		t_BOLD[t] = t_BOLD[t] + data_un_BOLD(t, islice,iy,ix); 
	
       }
     }
    }
  }
//outf << t << "   " << t_VASO[t] << "  "   << t_BOLD[t]  << endl; 
}


//cout << " Ich laufe bis hier 2 " << endl;  
//standard abweichung 

double std_vaso[(int)para_size] ; 
double std_bold[(int)para_size] ; 
for(int t = 0; t <(int)para_size ; t++){
std_vaso[t] = 0. ; 
std_bold[t] = 0. ;
}
double Xi_vaso[(int)N_paradigms *(int)para_size ] ; 
double Xi_bold[(int)N_paradigms *(int)para_size ] ; 

int teff = 0;
for(int t = (int)initial_rest; t < N ; t++){
teff = t -(int)initial_rest ;
Xi_vaso[teff] = 0.; 
Xi_bold[teff] = 0.; 
  for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy)   {
        for(int ix=0; ix<sizeRead; ++ix){
	    if (mask(0, islice,iy,ix) >= thresh  ){
		Xi_vaso[teff] = Xi_vaso[teff] + file_VASO(t, islice,iy,ix); 
		Xi_bold[teff] = Xi_bold[teff] + file_BOLD(t, islice,iy,ix); 
	
       }
     }
    }
  }
}

 teff = 0; 

for(int t = initial_rest; t< N ; t++ ){
teff = (t-(int)initial_rest)%(int)para_size; 
std_vaso[teff] = std_vaso[teff] + (t_VASO[teff] - Xi_vaso[t-(int)initial_rest]) * (t_VASO[teff] - Xi_vaso[t-(int)initial_rest])/(para_size-1.); 
std_bold[teff] = std_bold[teff] + (t_BOLD[teff] - Xi_bold[t-(int)initial_rest]) * (t_BOLD[teff] - Xi_bold[t-(int)initial_rest])/(para_size-1.);
//outf << teff << "   " << std_vaso[teff]<< "  "   << std_bold[teff]  << endl; 
}

for(int t = 0; t< para_size ; t++ ){
std_vaso[t] = sqrt(std_vaso[t]); 
std_bold[t] = sqrt(std_bold[t]); 
}




//normieren 
double baseline_vaso = 0.; 
double baseline_bold = 0.; 
baseline_vaso = ( t_VASO[(int)para_size/2-1] + t_VASO[(int)para_size/2-2] + t_VASO[(int)para_size/2-3] + t_VASO[(int)para_size/2-4]   ) / 4. ; 
baseline_bold = ( t_BOLD[(int)para_size/2-1] + t_BOLD[(int)para_size/2-2] + t_BOLD[(int)para_size/2-3] + t_BOLD[(int)para_size/2-4]   ) / 4. ; 


	for (int t = 0 ; t < para_size ; t++ ) {
	t_VASO[t] = t_VASO[t] / baseline_vaso; 
	t_BOLD[t] = t_BOLD[t] / baseline_bold; 
	std_vaso[t] = std_vaso[t] / baseline_vaso; 
	std_bold[t] = std_bold[t] / baseline_bold; 
	}

//outf << -3. * TR_in_s << "  " << -3. * TR_in_s+ TR_in_s/2. << "   " << t_VASO[(int)para_size-4] << "  "   << t_BOLD[(int)para_size-4]  << "   " << std_vaso[(int)para_size-4] << "   " << std_bold[(int)para_size-4] << endl;
//outf << -2. * TR_in_s << "  " << -2. * TR_in_s+ TR_in_s/2. << "   " << t_VASO[(int)para_size-3] << "  "   << t_BOLD[(int)para_size-3]  << "   " << std_vaso[(int)para_size-3] << "   " << std_bold[(int)para_size-3] << endl;
//outf << -1. * TR_in_s << "  " << -1. * TR_in_s+ TR_in_s/2. << "   " << t_VASO[(int)para_size-2] << "  "   << t_BOLD[(int)para_size-2]  << "   " << std_vaso[(int)para_size-2] << "   " << std_bold[(int)para_size-2] << endl;
//outf << -0. * TR_in_s << "  " << -0. * TR_in_s+ TR_in_s/2. << "   " << t_VASO[(int)para_size-1] << "  "   << t_BOLD[(int)para_size-1]  << "   " << std_vaso[(int)para_size-1] << "   " << std_bold[(int)para_size-1] << endl;

	for (int t = 3 ; t < para_size ; t++ ) {
	  outf << (t+1) * TR_in_s << "  " << (t+1) * TR_in_s + TR_in_s/2. << "   " << t_VASO[t] << "  "   << t_BOLD[t]  << "   " << std_vaso[t] << "   " << std_bold[t] << endl; 
	}
	for (int t = 0 ; t < 9 ; t++ ) {
	  outf << (para_size+t+1) * TR_in_s << "  " << (para_size+t+1) * TR_in_s + TR_in_s/2. << "   " << t_VASO[t] << "  "   << t_BOLD[t]  << "   " << std_vaso[t] << "   " << std_bold[t] << endl; 
	}


  sup_VASO =   t_VASO[para_size/2-4]    + t_VASO[para_size/2-3]   + t_VASO[para_size/2-2]   + t_VASO[para_size/2-1]   + t_VASO[para_size/2]  ; 
  slow_VASO =   t_VASO[para_size-4] + t_VASO[para_size-3] + t_VASO[para_size-2] + t_VASO[para_size-1] + t_VASO[0] ;  
  sup_BOLD =  t_BOLD[para_size-4] + t_BOLD[para_size-3] + t_BOLD[para_size-2] + t_BOLD[para_size-1] + t_BOLD[0]  ; 
  slow_BOLD =  t_BOLD[para_size/2-4] + t_BOLD[para_size/2-3] + t_BOLD[para_size/2-2] + t_BOLD[para_size/2-1] + t_BOLD[para_size/2]  ;

cout << " dVASO [%] = " << (sup_VASO -slow_VASO)/ slow_VASO * 100. << endl; 
cout << " dBOLD [%] = " << (sup_BOLD -slow_BOLD)/ slow_BOLD * 100. << endl; 




for(int t = 0; t< N-initial_rest ; t++ ){
 outfl << t << "   " << Xi_vaso[t]/baseline_vaso << "  "   << Xi_bold[t]/baseline_bold  << "   " << std_vaso[t%para_size] << "   " << std_bold[t%para_size] <<   endl; 
}



outf.close(); 
outfl.close(); 


  data_dBOLD.autowrite("dBOLD.nii", wopts, &prot);
  data_un_VASO.autowrite("Average_VASO.nii", wopts, &prot);
  data_un_BOLD.autowrite("Average_BOLD.nii", wopts, &prot);
  data_dVASO.autowrite("dVASO.nii", wopts, &prot);

  return 0;

}
