
// Ausführen mit . ./layers border_example_resized.nii brain_maskexample_resized.nii 0

 // mit make compilieren ... alles muss von pandamonium aus passieren
 
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

void usage() { cout << "PROFILE_ME  < smoothed Time course> <Layers> " << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=3) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);

   Range all=Range::all();
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  
cout << "bis hier 1 " << endl; 

  Data<float,4> file1;
  file1.autoread(filename1, FileReadOpts(), &prot);
  int nrep=file1.extent(firstDim);
  int sizeSlice=file1.extent(secondDim);
  //sizeSlice = 3; // only for debugging. tp make it faster 
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);

  Data<float,4> layerfile;
  layerfile.autoread(filename2, FileReadOpts(), &prot);

cout << "bis hier 2 " << endl; 

////////////////////////////////////////////////////
////// calculate how many layers there are /////////
////////////////////////////////////////////////////

int numb_layers = 100.; // This is the maximal number of layers. I don't know how to allocate it dynamically.

double numb_voxels[numb_layers] ; 
double mean_layers[numb_layers] ; 
double std_layers[numb_layers] ; 
int xcl[numb_layers] ; /// Kooridinates for closest voxel of respective layer
int ycl[numb_layers] ; 
float dist_min[numb_layers] ;


for (int i = 0; i < numb_layers; i++) {
  mean_layers[i] = 0.; 
   std_layers[i] = 0.; 
  numb_voxels[i] = 0.; 
	  xcl[i] = 0 ;
	  ycl[i] = 0 ;
     dist_min[i] = 0.; 
}

  for(int i = 0; i < numb_layers; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (layerfile(0,islice,iy,ix) == i+1 )
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




int vorlaeufig =  numb_layers; 

// Allocate Statistics parameters
double vec_n[numb_layers][nrep] ;
double vec_column_mean[nrep] ;
for(int timestep = 0; timestep < nrep ; timestep++) {
	for (int i = 0; i < numb_layers; i++){
		vec_n[i][timestep] = 0.; 
	}
	vec_column_mean[timestep] = 0.;
}


  Data<float,4> voxelprofile;
  voxelprofile.resize(vorlaeufig,sizeSlice,sizePhase,sizeRead); 
  voxelprofile=0.0;
  Data<int,4> closest_x;
  closest_x.resize(vorlaeufig,sizeSlice,sizePhase,sizeRead); 
  closest_x=0.0;
  Data<int,4> closest_y;
  closest_y.resize(vorlaeufig,sizeSlice,sizePhase,sizeRead); 
  closest_y=0.0;

float dist (float x1, float y1, float x2, float y2) ; 
float angle (float a, float b, float c) ; 

int vinc = 60; // This is the distance from every voxel that the algorythm is applied on. Just to make it faster and not loop over all voxels.
float dist_i = 0.; 




////////////////////////////////////////////////////
///// Big loop over all columns and voxels, respectively  ////////
////////////////////////////////////////////////////

    for(int islice=0; islice<sizeSlice; ++islice){  
      cout << "Slice " << islice +1 << " of " << sizeSlice << endl;
      for(int iy=0; iy<sizePhase; ++iy){
     cout << "Slice " << islice +1 << " of " << sizeSlice <<  "    phase" << double (iy)/ double(sizePhase) *100 << "%  "  << endl;
        for(int ix=0; ix<sizeRead-0; ++ix){
	  if (layerfile(0,islice,iy,ix) > 0 ){

		/////// get column for every voxel /////////
		for(int nlayer=0; nlayer<numb_layers; ++nlayer){
			dist_min[nlayer] = 10000.;
	  		xcl[nlayer] = 0;
	  		ycl[nlayer] = 0;

	  		  for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	   		   for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
				if (layerfile(0,islice,iy_i,ix_i) == nlayer+1){
		 
				  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
				  if (nlayer > 1 ) dist_i = dist_i + dist((float)xcl[nlayer-1],(float)ycl[nlayer-1],(float)ix_i,(float)iy_i); 
				  if (dist_i < dist_min[nlayer] ){
				    dist_min[nlayer] = dist_i ; 
				    xcl[nlayer] = ix_i;
				    ycl[nlayer] = iy_i;
				  }  
				}  
			      }
			    }
	   	}
		for(int nlayer=0; nlayer<numb_layers; ++nlayer){
		     closest_x(nlayer,islice,iy,ix) = xcl[nlayer] ; 
		     closest_y(nlayer,islice,iy,ix) = ycl[nlayer] ; 
		}

		////// get mean/layer-dependent signal variations across whole column //////
		/*		
		for(int timestep = 0 ; timestep < nrep ; timestep++) {
		    vec_column_mean[timestep] = 0.;
		    for(int nlayer =0; nlayer<numb_layers; ++nlayer){
		      vec_column_mean[timestep] = vec_column_mean[timestep] + file1(timestep,islice,ycl[nlayer],xcl[nlayer]);
		      vec_n[nlayer][timestep]  = file1(timestep,islice,ycl[nlayer],xcl[nlayer]) ; 

		    }
		}
		*/
		//////// calculate correlation of every layer with column mean  ////////
		for(int nlayer=0; nlayer<numb_layers; ++nlayer){		
			//voxelprofile(nlayer,islice,iy,ix) = gsl_stats_correlation (vec_n[nlayer],  1, vec_column_mean ,1 , nrep );
			voxelprofile(nlayer,islice,iy,ix) = file1(0,islice,ycl[nlayer],xcl[nlayer]);
		}
	  }
        }
      }
    }


  cout << " nur noch rausschreiben  .... " << endl; 
voxelprofile.autowrite("profiles"+filename1, wopts, &prot);
//closest_x.autowrite("xcoordinated.nii", wopts, &prot);
//closest_y.autowrite("ycoordinated.nii", wopts, &prot);

  return 0;
}



  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float angle (float a, float b, float c) {
	if (a*a+b*b-c*c <= 0 ) return 3.141592 ;
    	else return acos((a*a+b*b-c*c)/(2.*a*b));
  }

