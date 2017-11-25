
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




void usage() { cout << "Lauerme singele TR <Bild>  <Layer mask> <cutoff> " << endl;}
 

int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  float cutoff(atoi(argv[3])); 

//fürs Histogramm


    ofstream outf("layer.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  

  ofstream outfit("fit.dat");
  if (!outfit) {
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

cout << " nrep  " << nrep << endl; 
cout << " sizePhase  " << sizePhase << endl; 
cout << " sizeRead  " << sizeRead << endl;


  Data<float,4> layer_mask;
  layer_mask.autoread(filename2);
  
  
  
  Data<float,4> data1;
  data1.resize(samples,sizeSlice,sizePhase,sizeRead);
  data1=0.0;



// Use mean Value in input data
  for(int itimestep = 0; itimestep < nrep; itimestep++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		   data1(0,islice,iy,ix) = file1(0,islice,iy,ix); 
	}
      } 
    }
  }
  


cout << "nrep = " << nrep << endl; 

int numb_layers = 0;


// find number of layers

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(0,islice,iy,ix) >= numb_layers )
		   numb_layers = layer_mask(0,islice,iy,ix); 
		
        }  
      } 
    }
  


 cout << "There are " << numb_layers << " layers in the mask " << endl; 

int numb_voxels[numb_layers] ; 
double mean_layers[numb_layers]; 
double stdev_layers[numb_layers]; 
int dummy_index[numb_layers] ; 
  for(int i = 0; i < numb_layers; i++) {
      numb_voxels[i] = 0; 
      mean_layers[i] = 0.; 
      stdev_layers[i] = 0.; 
      dummy_index[i] = 0; 
  }

// count numer of voxels
  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(0,islice,iy,ix) == i+1 )
		    numb_voxels[i] ++; 
		
        }  
      } 
    }
  }
  
  
  // find max layer number
  int max_layer_number = 0 ; 
  int max_layer_number_layer = 0 ; 
   for(int i = 0; i < numb_layers; i++) {
    if (numb_voxels[i] >= max_layer_number ){
      max_layer_number =  numb_voxels[i];
      max_layer_number_layer = i; 
    }
  }
cout << " Layer  " <<   max_layer_number_layer << " hat mit " <<  max_layer_number << " am meisten voxel " << endl; 
  
  double vec1_n[numb_layers][max_layer_number]  ; 
  double vec1_std[numb_layers][max_layer_number]  ; 

  
  //Fill all the signal from all the voxels in one array
  
   for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(0,islice,iy,ix) == i+1 ) {
		  vec1_n[i][dummy_index[i]] = data1(0,islice,iy,ix) ; 
		  dummy_index[i] ++; 
		}
        }  
      } 
    }
  }
  
  //debug consistency check 
 // for(int i = 0; i < numb_layers; i++) {
  //    cout << "dummy_index[i]  =  " << dummy_index[i] << " =  " << numb_voxels[i] << " numb_voxels[i] " <<   endl; 
  //}
  

cout << " Hallo 1 " << endl; 

// get mean
  for(int i = 0; i < numb_layers; i++) {

		    mean_layers[i]  =  gsl_stats_mean (vec1_n[i], 1, numb_voxels[i])  ;
		    stdev_layers[i] =  gsl_stats_sd(vec1_n[i], 1, numb_voxels[i]);

  }
  
  
  for(int i = 0; i < numb_layers; i++) {
      cout << "There are " << numb_voxels[i] << " in layer " << i+1 << " with a mean signal of "<<  mean_layers[i] <<  " +/-  " << stdev_layers[i] << " with  " <<  numb_voxels[i] <<  " voxels " << endl; 
      outf << i+1 << "   "<<  mean_layers[i] <<  " " << stdev_layers[i] << "  " <<  numb_voxels[i] << endl; 
     // outf << i+2 << "   "<<  mean_layers[i] <<  " " << stdev_layers[i] << "  " <<  numb_voxels[i] << endl;
  }
cout << " Hallo 3 " << endl; 
  

  //datat1.autowrite("T1.nii");

	
	//outf  << i << "  " <<numb_voxels[i]  << "  " <<   mean_layers[i] << endl; 
	
  outf.close();
  outfit.close();
  return 0;

}



