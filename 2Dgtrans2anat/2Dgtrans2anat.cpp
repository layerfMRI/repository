
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




void usage() { cout << "Lauerme singele TR <corrected 2D grid mao in anat space>  <2D GRID mask> <cutoff> " << endl;}
 

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

cout << " nrep  " << nrep << endl; 
cout << " sizeSlice  " << sizeSlice << endl; 
cout << " sizePhase  " << sizePhase << endl; 
cout << " sizeRead  " << sizeRead << endl;



  
  Data<float,4> file2;
  file2.autoread(filename2);
  int nrep2=file2.extent(firstDim);
//löschdie nächste Zeile
  //nrep = 4; 
  int sizeSlice2=file2.extent(secondDim);
  int sizePhase2=file2.extent(thirdDim);
  int sizeRead2=file2.extent(fourthDim);

cout << " sizeSlice  " << sizeSlice2 << endl; 
cout << " number of columns  " << sizeRead2 << endl; 
cout << " number of layers  " << sizePhase2 << endl;  

  
  Data<float,4> data1;
  data1.resize(nrep2,sizeSlice,sizePhase,sizeRead);
  data1=0.0;

int dslice = sizeSlice - sizeSlice2; 

// Use mean Value in input data
  for(int itimestep = 0; itimestep < nrep2; itimestep++) {
    for(int islice=0; islice<sizeSlice2; ++islice){
	cout << " islice   " << islice << endl;

      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (file1(0,islice+dslice/2,iy,ix) > 0  ) {
			//cout <<  islice << "  "<< islice << "  "<< iy << "   " << ix <<  "    "  <<  file1(1,islice,iy,ix)  << "   "  << file1(0,islice,iy,ix) << endl;
			
		   data1(itimestep,islice+dslice/2,iy,ix) = file2(itimestep,islice,(int)(file1(1,islice+dslice/2,iy,ix)),(int)(file1(0,islice+dslice/2,iy,ix))); 
		} 

	}
      } 

    }
  }
  


cout << " Hallo 3 " << endl; 
  

  data1.autowrite("Grided2anat"+filename2, wopts, &prot);

	
	//outf  << i << "  " <<numb_voxels[i]  << "  " <<   mean_layers[i] << endl; 
	
  outf.close();

  return 0;

}



