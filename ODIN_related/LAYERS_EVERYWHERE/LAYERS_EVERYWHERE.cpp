
// Ausführen mit . ./layers border_example_resized.nii brain_maskexample_resized.nii 0

 // mit make compilieren ... alles muss von pandamonium aus passieren
 
#include <odindata/data.h> 
#include <odindata/complexdata.h> 
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     #include <gsl/gsl_multifit.h>


#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "file  < surface> " << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=2) {usage(); return 0;}
  STD_string filename1(argv[1]);


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
 //sizeSlice = 1; // only for debugging. tp make it faster 
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);


cout << "bis hier 2 " << endl; 

  Data<float,4> thickness;
  thickness.resize(1,sizeSlice,sizePhase,sizeRead);
  thickness=0.0;
  
  Data<float,4> distance2surf;
  distance2surf.resize(2,sizeSlice,sizePhase,sizeRead);
  distance2surf=0.0;

  Data<float,4> angle_data;
  angle_data.resize(1,sizeSlice,sizePhase,sizeRead);
  angle_data=0.0;

  Data<int,4> equi_dist_layers;
  equi_dist_layers.resize(1,sizeSlice,sizePhase,sizeRead);
  equi_dist_layers=0.0;

//koordinaten
float x1 = 0.;
float y1 = 0.;
float x2 = 0.;
float y2 = 0.;
float x3 = 0.;
float y3 = 0.;
float x4 = 0.;
float y4 = 0.;

float dist (float x1, float y1, float x2, float y2) ; 
float angle (float a, float b, float c) ; 

cout << "bis hier 2 " << endl; 


// Reduce mask to contain only Areas close to the curface. 
cout << " select GM regions .... " << endl; 

int vinc = 60; // This is the distance from every voxel that the algorythm is applied on. Just to make it faster and not loop over all voxels.


float dist_i = 0.; 
float dist_min = 0.;
float dist_min1 = 0.;
float dist_min2 = 0.;
float dist_min3 = 0.;
float dist_max = 0.;
float dist_p1 = 0.;


int number_of_layers = 20 ; 

Data<int,4> vol_dist_int;
vol_dist_int.resize(1,sizeSlice,sizePhase,sizeRead); 
vol_dist_int=0.0;

cout << " get equidistance  .... " << endl; 


//////////////////////////////////
/////get cortical thickness   /////////
//////////////////////////////////
    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){

	dist_min2 = 10000.;
	  x3 = 0.;
	  y3 = 0;
	   if (file1(0,islice,iy,ix) == 2){
	    for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (file1(0,islice,iy_i,ix_i) == 1){
		 
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min2 ){
		    dist_min2 = dist_i ; 
		    x3 = ix_i;
		    y3 = iy_i;
		    dist_p1 = dist_min2; 
		  }  
		}  
	      }
	    }
 	    thickness(0,islice,iy,ix) = dist((float)ix,(float)iy,x3,y3) ;
	   }

        }
      }
    }

//////////////////////////////////
/////Get  closest voxel  /////////
//////////////////////////////////
    for(int islice=0; islice<sizeSlice; ++islice){  
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl;  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){

	  
	  dist_min = 10000.;
	  x1 = 100000.;
	  y1 = 100000.;
		/// Find closest voxel at WM/GM border
	    for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (file1(0,islice,iy_i,ix_i) == 2){
		 
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min ){
		    dist_min = dist_i ; 
		    x1 = ix_i;
		    y1 = iy_i;
		    dist_p1 = dist_min; 
		  }  
		}  
	      }
	    }


	  distance2surf(0,islice,iy,ix) = dist((float)ix,(float)iy,x1,y1);

	  dist_min1 = 10000.;
	  x2 = 100000.;
	  y2 = 100000.;
		/// find closest GM/CSF voxel from this WM-border voxel
  	    for(int iy_i=max(0,(int)y1-vinc); iy_i<min((int)y1+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,(int)x1-vinc); ix_i<min((int)x1+vinc,sizeRead); ++ix_i){
		if (file1(0,islice,iy_i,ix_i) == 1){
		 
		  dist_i = dist((float)x1,(float)y1,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min1 ){
		    dist_min1 = dist_i ; 
		    x2 = ix_i;
		    y2 = iy_i;
		    dist_p1 = dist_min1; 
		  }  
		}  
	      }
	    }


	  dist_min3 = 10000.;
	  x3 = 100000.;
	  y3 = 100000.;
		/// find closest GM/CSF voxel from the current voxel
  	    for(int iy_i=max(0,(int)y2-vinc/2); iy_i<min((int)y2+vinc/2,sizePhase); ++iy_i){
	      for(int ix_i=max(0,(int)x2-vinc/2); ix_i<min((int)x2+vinc/2,sizeRead); ++ix_i){
		if (file1(0,islice,iy_i,ix_i) == 1){
		 
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min3 ){
		    dist_min3 = dist_i ; 
		    x3 = ix_i;
		    y3 = iy_i;
		    dist_p1 = dist_min3; 
		  }  
		}  
	      }
	    }


	  distance2surf(1,islice,iy,ix) = dist((float)ix,(float)iy,x3,y3);

	  
/*
 	  angle_data(0,islice,iy,ix) =  angle(distance2surf(0,islice,iy,ix), distance2surf(1,islice,iy,ix) ,  dist(x1,y1,x3,y3)) ;

 	  if (distance2surf(0,islice,iy,ix) + distance2surf(1,islice,iy,ix) > vinc ){
		 distance2surf(0,islice,iy,ix) = 0.;
 		 distance2surf(1,islice,iy,ix) = 0.;
		 angle_data(0,islice,iy,ix) = 0.; 
	  }
	 
*/
	  equi_dist_layers(0,islice,iy,ix) =  (int) (distance2surf(0,islice,iy,ix) /(distance2surf(0,islice,iy,ix) + distance2surf(1,islice,iy,ix))*(number_of_layers-1.) + 2. );
            	
        }
      }
    }


// Cleaning negative layers and layers ov more than 20

for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
		if (file1(0,islice,iy,ix) == 0 ) equi_dist_layers(0,islice,iy,ix) = 0.;
		if (file1(0,islice,iy,ix) == 2 ) equi_dist_layers(0,islice,iy,ix) = equi_dist_layers(0,islice,iy,ix) - 1. ;
	}
      }
}

//  distance2surf.autowrite("eq_dist.nii", wopts, &prot);
  

//angle_data.autowrite("angle.nii", wopts, &prot);

//thickness.autowrite("thickness.nii", wopts, &prot);
equi_dist_layers.autowrite("equi_dist_layers.nii", wopts, &prot);

 // koord.autowrite("koordinaten.nii", wopts, &prot);
  return 0;
}



  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float angle (float a, float b, float c) {
	if (a*a+b*b-c*c <= 0 ) return 3.141592 ;
    	else return acos((a*a+b*b-c*c)/(2.*a*b));
  }

