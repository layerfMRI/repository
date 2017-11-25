// for Samira to get CBV in units of BOLD signal change per mmHg end tidal C02

#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>

#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "HIST_ME  < Image 1 > < Image 2 > <mask>   " << endl;}


int main(int argc,char* argv[]) {

  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);
  



   double numb_bins1 = 100;


   
   double numb_bins2 = 100;



  
  // float cutoff(atoi(argv[2]));

  Range all=Range::all();
 
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> file1;
  file1.autoread(filename1 , FileReadOpts(), &prot);
  int nrep=file1.extent(firstDim);
  int sizeSlice=file1.extent(secondDim);
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);

  Data<float,4> file2;
  file2.autoread(filename2);
  
  Data<float,4> mask;
  mask.autoread(filename3);

  Data<float,4> data1;
  data1.resize(nrep,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  
  
  ofstream outf("points_file1.dat");
  if (!outf) {
  cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
  ofstream outf3d("3dhist.dat");
  if (!outf3d) {
  cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
cout << " nrep " <<  nrep  << endl; 

int numb_in_mask = 0; 

   for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if ( mask(0,islice,iy,ix) != 0 ) {
        numb_in_mask++; 	
	  }
        }
      }
    }

cout << numb_in_mask << " points in mask" << endl; 
    
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if ( mask(0,islice,iy,ix)!= 0 ) {
            outf <<  file1(0,islice,iy,ix) << "    " << file2(0,islice,iy,ix) << endl; 
	  }
        }
      }
    }
   
   outf.close();

   
   double min_val_1 = +100000; 
   double max_val_1 = -100000;
   double x_1 = 0; 

   double min_val_2 = +100000; 
   double max_val_2 = -1000000; //VASA = 3   // M = 0.10   // BOLD 0.08
   double x_2 = 0; 
   
   
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if ( mask(0,islice,iy,ix) != 0  ) {

		       if (file1(0,islice,iy,ix) > max_val_1)  max_val_1 = file1(0,islice,iy,ix) ; 
		       if (file1(0,islice,iy,ix) < min_val_1)  min_val_1 = file1(0,islice,iy,ix) ; 
		       if (file2(0,islice,iy,ix) > max_val_2)  max_val_2 = file2(0,islice,iy,ix) ; 
		       if (file2(0,islice,iy,ix) < min_val_2)  min_val_2 = file2(0,islice,iy,ix) ; 

	  }
        }
      }
    }
   
   
   
   cout << "max von "  <<  filename1 << " is " << max_val_1 << endl; 
   cout << "nim von "  <<  filename1 << " is " << min_val_1 << endl;
   cout << "max von "  <<  filename2 << " is " << max_val_2 << endl;
   cout << "min von "  <<  filename2 << " is " << min_val_2 << endl;
   
   double bin_size_1 = (max_val_1 -min_val_1 ) / numb_bins1;
   double bin_size_2 = (max_val_2 -min_val_2 ) / numb_bins2; 

   
   
   double three_D_hist [(int)numb_bins1][(int)numb_bins2] ;
     for(int i = 0; i <numb_bins1; ++i ){
        for(int j=0; j<numb_bins2; ++j ){
	  three_D_hist [i][j] = 0.;
	}
     }
   
   
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if ( mask(0,islice,iy,ix) != 0 ) {

	          for(int i=0; i<numb_bins1; ++i){
		    for(int j=0; j<numb_bins2; ++j){
		      
		      x_1 = min_val_1 + (double)i * bin_size_1 ; 
		      x_2 = min_val_2 + (double)j * bin_size_2 ; 
		      
		       if (file1(0,islice,iy,ix) > x_1 && file1(0,islice,iy,ix) <= x_1+ bin_size_1 && file2(0,islice,iy,ix) > x_2 && file2(0,islice,iy,ix) <= x_2+ bin_size_2){
			  three_D_hist [i][j] ++ ; 
		       }
		    }
		  }	
	  }
        }
      }
    }
   
     for(int i = 0; i <numb_bins1; ++i ){
        for(int j=0; j<numb_bins2; ++j ){
	  outf3d << i << "   " << j  << "   " <<  three_D_hist [i][j] << endl ;
	}
	 outf3d << endl; 
     }
   
   outf3d.close();
  //data1.autowrite("CVR_map_DeltaSig_per_mmHg.nii", wopts, &prot);

//cout << " bis hier4 " << endl; 


////////////////////////////////////////////////////////////////////
////////  calculate Correlation now  ///////////////////////////////
////////////////////////////////////////////////////////////////////

int numb_corr_voxels = 0; // This is the number of non zero voxels in mask, that are used for calculation of the correlation coefficient.
double thresh_min_M = 0. ;
double thresh_min_VasA = 0.0;

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	   if (file1(0,islice,iy,ix) > thresh_min_M && file2(0,islice,iy,ix) > thresh_min_VasA && mask(0,islice,iy,ix) != 0 ){
            numb_corr_voxels++ ;  
	   }
        }
      }
    }

   cout << "Correlation is calculated for  "  <<  numb_corr_voxels << " Voxels " << endl; 

double vec_1[numb_corr_voxels] ; 
double vec_2[numb_corr_voxels] ; 
int i_voxels = 0;

for (int i = 0; i < numb_corr_voxels; i++) {
  vec_1[i] = 0.; 
  vec_2[i] = 0.; 
}

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	   if (file1(0,islice,iy,ix) > thresh_min_M && file2(0,islice,iy,ix) > thresh_min_VasA  && mask(0,islice,iy,ix) != 0  ){

		vec_1[i_voxels] =  file1(0,islice,iy,ix) ; 
		vec_2[i_voxels] =  file2(0,islice,iy,ix) ;
		i_voxels++;
	   }
        }
      }
    }

cout << "Correlation is ============>  "  <<  2.*gsl_stats_correlation (vec_2,  1, vec_1 ,1 , numb_corr_voxels) << "  <=================="  << endl;

  return 0;

}
