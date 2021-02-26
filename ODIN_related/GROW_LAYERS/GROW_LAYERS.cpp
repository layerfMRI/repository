
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

  Data<float,4> growfromWM;
  growfromWM.resize(2,sizeSlice,sizePhase,sizeRead); //   
  growfromWM=0.0;

  Data<int,4> WMkoord;
   WMkoord.resize(4,sizeSlice,sizePhase,sizeRead); //   
   WMkoord=0.0;

  Data<float,4> growfromGM;
  growfromGM.resize(2,sizeSlice,sizePhase,sizeRead);
  growfromGM=0.0;

  Data<int,4> GMkoord;
  GMkoord.resize(4,sizeSlice,sizePhase,sizeRead); //   
  GMkoord=0.0;

  Data<float,4> angle_data;
  angle_data.resize(1,sizeSlice,sizePhase,sizeRead);
  angle_data=0.0;

  Data<float,4> distDebug;
  distDebug.resize(1,sizeSlice,sizePhase,sizeRead);
  distDebug=0.0;

  Data<int,4> equi_dist_layers;
  equi_dist_layers.resize(1,sizeSlice,sizePhase,sizeRead);
  equi_dist_layers=0.0;

//koordinaten


float x1g = 0.;
float y1g = 0.;
float x2g = 0.;
float y2g = 0.;
float x3g = 0.;
float y3g = 0.;

float dist (float x1, float y1, float x2, float y2) ; 
float angle (float a, float b, float c) ; 

cout << "bis hier 2 " << endl; 


// Reduce mask to contain only Areas close to the curface. 
cout << " select GM regions .... " << endl; 

int vinc = 80; // This is the distance from every voxel that the algorythm is applied on. Just to make it faster and not loop over all voxels.


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

cout << " start growing  from WM .... " << endl; 



//////////////////////////////////
/////grow from  WM       /////////
//////////////////////////////////

int grow_vinc = 2 ; 

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	 	if (file1(0,islice,iy,ix) == 2 ) {
			growfromWM(0,islice,iy,ix) = 1.; 
			WMkoord(0,islice,iy,ix) = ix ; 
			WMkoord(1,islice,iy,ix) = iy ; 
		}
        }
      }
    }

  for (int grow_i = 1 ; grow_i < vinc ; grow_i++ ){
    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){

	dist_min2 = 10000.;
	  x1g = 0;
	  y1g = 0;
	   if (file1(0,islice,iy,ix) == 3  && growfromWM(0,islice,iy,ix) == 0 ){
	    	for(int iy_i=max(0,iy-grow_vinc); iy_i<min(iy+grow_vinc,sizePhase); ++iy_i){
	     	 for(int ix_i=max(0,ix-grow_vinc); ix_i<min(ix+grow_vinc,sizeRead); ++ix_i){
			if (growfromWM(0,islice,iy_i,ix_i) == (float)grow_i){
		 
			  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i;
			    y1g = iy_i;
			    dist_p1 = dist_min2; 
			  }  
			}  
	  	 }
	  	}
		if ( dist_min2 < 1.4){
			distDebug(0,islice,iy,ix) = dist_min2 ; 
 	    		growfromWM(0,islice,iy,ix) = (float)grow_i+1 ;
			WMkoord(0,islice,iy,ix) = WMkoord(0,islice,(int)y1g,(int)x1g) ; 
			WMkoord(1,islice,iy,ix) = WMkoord(1,islice,(int)y1g,(int)x1g) ; 
		}
	   }

        }
      }
    }
 }


//////////////////////////////////
/////grow from  CSF       /////////
//////////////////////////////////

cout << " start growing from CSF .... " << endl; 

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	 	if (file1(0,islice,iy,ix) == 1 ) {
			growfromGM(0,islice,iy,ix) = 1.; 
			GMkoord(0,islice,iy,ix) = ix ; 
			GMkoord(1,islice,iy,ix) = iy ; 
		}
        }
      }
    }

  for (int grow_i = 1 ; grow_i < vinc ; grow_i++ ){
    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){

	dist_min2 = 10000.;
	  x1g = 0.;
	  y1g = 0;
	   if (file1(0,islice,iy,ix) == 3  && growfromGM(0,islice,iy,ix) == 0 ){
	    for(int iy_i=max(0,iy-grow_vinc); iy_i<min(iy+grow_vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-grow_vinc); ix_i<min(ix+grow_vinc,sizeRead); ++ix_i){
		if (growfromGM(0,islice,iy_i,ix_i) == (float)grow_i){
		 
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min2 ){
		    dist_min2 = dist_i ; 
		    x1g = ix_i;
		    y1g = iy_i;
		    dist_p1 = dist_min2; 
		  }  
		}  
	      }
	    }
		if ( dist_min2 < 1.4){
 	    		growfromGM(0,islice,iy,ix) = (float)grow_i+1 ;
			GMkoord(0,islice,iy,ix) = GMkoord(0,islice,(int)y1g,(int)x1g) ; 
			GMkoord(1,islice,iy,ix) = GMkoord(1,islice,(int)y1g,(int)x1g) ; 
		}
	   }

        }
      }
    }
 }


/////////////////////////////////////////////////////////////////////////////////////////////////////
///// wabble accross neigbouring voexles of closest WM to account for Pytagoras errors      /////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

cout << " correct for pytagoras error .... " << endl; 


    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
			growfromWM(1,islice,iy,ix) =  growfromWM(0,islice,iy,ix); 
			WMkoord(2,islice,iy,ix) = WMkoord(0,islice,iy,ix) ; 
			WMkoord(3,islice,iy,ix) = WMkoord(1,islice,iy,ix) ; 
        }
      }
    }

  for (int grow_i = 1 ; grow_i < vinc ; grow_i++ ){
    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	   if (WMkoord(1,islice,iy,ix) != 0 ){
		dist_min2 = 10000.;
	  	x1g = 0;
	  	y1g = 0;

	    	for(int iy_i=max(0,WMkoord(3,islice,iy,ix)-grow_vinc);   iy_i<min(WMkoord(3,islice,iy,ix)+grow_vinc,sizePhase); ++iy_i){
	    	  for(int ix_i=max(0,WMkoord(2,islice,iy,ix)-grow_vinc); ix_i<min(WMkoord(2,islice,iy,ix)+grow_vinc,sizeRead); ++ix_i){
			if (file1(0,islice,iy_i,ix_i) == 2){
			 
			  dist_i =  dist((float)ix,(float)iy,(float)ix_i,(float)iy_i);
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i;
			    y1g = iy_i;
			    dist_p1 = dist_min2; 
			  }  
			}  
		   }
		}

 	    	growfromWM(1,islice,iy,ix) =  dist((float)ix,(float)iy,(float)x1g,(float)y1g); 
		WMkoord(2,islice,iy,ix) = WMkoord(2,islice,(int)y1g,(int)x1g) ; 
		WMkoord(3,islice,iy,ix) = WMkoord(3,islice,(int)y1g,(int)x1g) ; 

	   }

        }
      }
    }
 }



/////////////////////////////////////////////////////////////////////////////////////////////////////
///// wabble accross neigbouring voexles of closest GM to account for Pytagoras errors      /////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
			growfromGM(1,islice,iy,ix) =  growfromGM(0,islice,iy,ix); 
			GMkoord(2,islice,iy,ix) = GMkoord(0,islice,iy,ix) ; 
			GMkoord(3,islice,iy,ix) = GMkoord(1,islice,iy,ix) ; 
        }
      }
    }

  for (int grow_i = 1 ; grow_i < vinc ; grow_i++ ){
    for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	   if (GMkoord(1,islice,iy,ix) != 0 ){
		dist_min2 = 10000.;
	  	x1g = 0;
	  	y1g = 0;

	    	for(int iy_i=max(0,GMkoord(3,islice,iy,ix)-grow_vinc);   iy_i<min(GMkoord(3,islice,iy,ix)+grow_vinc,sizePhase); ++iy_i){
	    	  for(int ix_i=max(0,GMkoord(2,islice,iy,ix)-grow_vinc); ix_i<min(GMkoord(2,islice,iy,ix)+grow_vinc,sizeRead); ++ix_i){
			if (file1(0,islice,iy_i,ix_i) == 1){
			 
			  dist_i =  dist((float)ix,(float)iy,(float)ix_i,(float)iy_i);
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i;
			    y1g = iy_i;
			    dist_p1 = dist_min2; 
			  }  
			}  
		   }
		}

 	    	growfromGM(1,islice,iy,ix) =  dist((float)ix,(float)iy,(float)x1g,(float)y1g); 
		GMkoord(2,islice,iy,ix) = GMkoord(2,islice,(int)y1g,(int)x1g) ; 
		GMkoord(3,islice,iy,ix) = GMkoord(3,islice,(int)y1g,(int)x1g) ;

	   }

        }
      }
    }
 }








for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
		if (file1(0,islice,iy,ix) == 3){
	  		equi_dist_layers(0,islice,iy,ix) =   19 * (1- dist((float)ix,(float)iy,(float)GMkoord(2,islice,iy,ix),(float)GMkoord(3,islice,iy,ix)) / (dist((float)ix,(float)iy,(float)GMkoord(2,islice,iy,ix),(float)GMkoord(3,islice,iy,ix)) + dist((float)ix,(float)iy,(float)WMkoord(2,islice,iy,ix),(float)WMkoord(3,islice,iy,ix)) )) + 2  ;
            	}
        }
      }
    }

// Cleaning negative layers and layers ov more than 20

for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
		if (file1(0,islice,iy,ix) == 1 && equi_dist_layers(0,islice,iy,ix) == 0  ){
	  		equi_dist_layers(0,islice,iy,ix) = 21 ;
            	}
		if (file1(0,islice,iy,ix) == 2 && equi_dist_layers(0,islice,iy,ix) == 0  ){
	  		equi_dist_layers(0,islice,iy,ix) = 1 ;
            	}
        }
      }
    }

//  distance2surf.autowrite("eq_dist.nii", wopts, &prot);
  

//angle_data.autowrite("angle.nii", wopts, &prot);
//distDebug.autowrite("distDebug.nii", wopts, &prot);
//growfromWM.autowrite("grownfromWM.nii", wopts, &prot);
//growfromGM.autowrite("grownfromGM.nii", wopts, &prot);
//WMkoord.autowrite("WMkoord.nii", wopts, &prot);
//GMkoord.autowrite("GMkoord.nii", wopts, &prot);
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

