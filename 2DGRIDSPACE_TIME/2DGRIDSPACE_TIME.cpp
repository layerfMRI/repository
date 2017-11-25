
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




void usage() { cout << "time_resies_2D_GRID TR <Bild>  <2D GRID mask> <cutoff> " << endl;}
 

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


  Data<float,4> layer_mask;
  layer_mask.autoread(filename2);
  
  
  
//  Data<float,4> data1;
//  data1.resize(samples,sizeSlice,sizePhase,sizeRead);
//  data1=0.0;

// Use mean Value in input data
//  for(int itimestep = 0; itimestep < nrep; itimestep++) {
//#    for(int islice=0; islice<sizeSlice; ++islice){
//#      for(int iy=0; iy<sizePhase; ++iy){
//#        for(int ix=0; ix<sizeRead; ++ix){
//#		   data1(0,islice,iy,ix) = file1(itimestep,islice,iy,ix)/(double)nrep; 
//#	}
//#      } 
//#    }
//#  }
  

cout << "nrep = " << nrep << endl; 

int numb_layers = 0;
int numb_columns = 0;


// find number of layers

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(1,islice,iy,ix) >= numb_layers ) {
		   numb_layers = layer_mask(1,islice,iy,ix); 
		}
        }  
      } 
    }
  
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(0,islice,iy,ix) >= numb_columns ){
		   numb_columns = layer_mask(0,islice,iy,ix); 
		}
        }  
      } 
    }

 cout << "There are " << numb_layers << " layers in the mask " << endl; 
 cout << "There are " << numb_columns << " columns in the mask " << endl;
 cout << "There are " << sizeSlice << " sizeSlices in the mask " << endl;

 
int numb_voxels[numb_columns][numb_layers][sizeSlice] ; 
double mean_layers[numb_columns][numb_layers][sizeSlice]; 
double stdev_layers[numb_columns][numb_layers][sizeSlice]; 
int dummy_index[numb_columns][numb_layers][sizeSlice] ; 

for(int islice=0; islice<sizeSlice; islice++){
 for(int j = 0; j < numb_columns; j++) {
  for(int i = 0; i < numb_layers; i++) {
      numb_voxels[j][i][islice] = 0; 
      mean_layers[j][i][islice] = 0.; 
      stdev_layers[j][i][islice] = 0.; 
      dummy_index[j][i][islice] = 0; 
  }
 }
}
// count numer of voxels
 for(int j = 0; j < numb_columns; j++) {
  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layer_mask(0,islice,iy,ix) == j+1 && layer_mask(1,islice,iy,ix) == i+1 )
		    numb_voxels[j][i][islice] ++; 
		
        }  
      } 
    }
  }
 } 
  
  // find max layer number
	
  int max_layer_number = 0 ; 
  int max_layer_number_layer = 0 ;
  int max_columns_number_columns = 0 ; 
  int max_slices_number_slices = 0 ;
for(int j = 0; j < numb_columns; j++) {
   for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
	    if (numb_voxels[j][i][islice] >= max_layer_number ){
	      max_layer_number =  numb_voxels[j][i][islice];
	      max_layer_number_layer = i; 
	      max_columns_number_columns =  j ; 	
	      max_slices_number_slices = islice ;
	    }
    }
  }
}

max_layer_number = 80., 
cout << " Layer  " <<   max_layer_number_layer <<  " und  COLUMN " <<   max_columns_number_columns << "  in slice " <<  max_slices_number_slices <<  " hat mit " <<  max_layer_number << " am meisten voxel " << endl; 
  
cout << " numb_columns *numb_layers *sizeSlice * max_layer_number    " << numb_columns *numb_layers *sizeSlice * max_layer_number  << endl;


cout << " I see you  2a" << endl;

double vec1_n  [numb_columns][numb_layers][sizeSlice][max_layer_number]  ; 


cout << " I see you  3" << endl;

  Data<float,4> ValueinGRID;
  ValueinGRID.resize(nrep,sizeSlice,numb_layers,numb_columns);
  ValueinGRID=0.0;

for(int timestep = 0; timestep < nrep; timestep++) {
 cout << "timestep=" << timestep  << "  of " << nrep << endl;



  //Fill all the signal from all the voxels in one array
  for(int j = 0; j < numb_columns; j++) {
   for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
  		if (layer_mask(1,islice,iy,ix) == i+1 && layer_mask(0,islice,iy,ix) == j+1 && dummy_index[j][i][islice] < max_layer_number) {
  	 	  vec1_n[j][i][islice] [dummy_index[j][i][islice] ] = file1(timestep,islice,iy,ix) ; 
  		  dummy_index[j][i][islice]++; 
  		}
        }  
      }
     // cout << "j=" << j  << "   i=" << i  << "   islice=" << islice << endl;
    }
   }
  }
  
  //debug consistency check 
 // for(int i = 0; i < numb_layers; i++) {
  //    cout << "dummy_index[i]  =  " << dummy_index[i] << " =  " << numb_voxels[i] << " numb_voxels[i] " <<   endl; 
  //}
  

//cout << " Hallo 1 " << endl; 

// get mean
  for(int j = 0; j < numb_columns; j++) {
	for(int i = 0; i < numb_layers; i++) {
		for(int islice=0; islice<sizeSlice; ++islice){
		    mean_layers [j][i][islice]   =  gsl_stats_mean (vec1_n[j][i][islice] , 1, numb_voxels[j][i][islice] )  ;
		    stdev_layers[j][i][islice]   =  gsl_stats_sd   (vec1_n[j][i][islice] , 1, numb_voxels[j][i][islice] );
		}
	}
  }
  



    for(int j = 0; j < numb_columns; j++) {
	for(int i = 0; i < numb_layers; i++) {
		for(int islice=0; islice<sizeSlice; ++islice){
		    ValueinGRID (timestep,islice,i,j)   =  mean_layers [j][i][islice]  ;
		    //ValueinGRID (1,islice,i,j)   =  stdev_layers [j][i][islice]  ;
		    //ValueinGRID (2,islice,i,j)   =  numb_voxels[j][i][islice]  ;
		}
	}
  }



for(int islice=0; islice<sizeSlice; islice++){
 for(int j = 0; j < numb_columns; j++) {
  for(int i = 0; i < numb_layers; i++) {
      dummy_index[j][i][islice] = 0; 
  }
 }
}


}


// for(int i = 0; i < numb_layers; i++) {
//      cout << "There are " << numb_voxels[i] << " in layer " << i+1 << " with a mean signal of "<<  mean_layers[i] <<  " +/-  " << stdev_layers[i] << " with  " <<  numb_voxels[i] <<  " voxels " << endl; 
//      outf << i+1 << "   "<<  mean_layers[i] <<  " " << stdev_layers[i] << "  " <<  numb_voxels[i] << endl; 
//     // outf << i+2 << "   "<<  mean_layers[i] <<  " " << stdev_layers[i] << "  " <<  numb_voxels[i] << endl;
//  }
cout << " Hallo 3 " << endl; 
  

  ValueinGRID.autowrite("GRIDED_time"+filename1, wopts, &prot);

	
	//outf  << i << "  " <<numb_voxels[i]  << "  " <<   mean_layers[i] << endl; 
	
  outf.close();

  return 0;

}



