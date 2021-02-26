
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

void usage() { cout << "file  < layers>  < landmarks> " << endl;}


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
 //sizeSlice = 1; // only for debugging. tp make it faster 
  int sizePhase=file1.extent(thirdDim);
  int sizeRead=file1.extent(fourthDim);

  Data<float,4> landmarks;
  landmarks.autoread(filename2, FileReadOpts(), &prot);

cout << "bis hier 2 " << endl; 


  Data<float,4> renumerated;
  renumerated.resize(1,sizeSlice,sizePhase,sizeRead);
  renumerated=0.0;

int number_of_layers = 20 ; 

  for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){



		if (file1(0,islice,iy,ix) > 0) renumerated(0,islice,iy,ix) = 1. ;
		if (file1(0,islice,iy,ix) > number_of_layers/2-2 && file1(0,islice,iy,ix) < number_of_layers/2+2) renumerated(0,islice,iy,ix) = 2. ;  
		if (file1(0,islice,iy,ix) <= 0) renumerated(0,islice,iy,ix) = 0. ;

        }
      }
    }

  

  Data<float,4> grow1D;
  grow1D.resize(1,sizeSlice,sizePhase,sizeRead); //   
  grow1D=0.0;

  Data<float,4> grow2D;
  grow2D.resize(1,sizeSlice,sizePhase,sizeRead); //   
  grow2D=0.0;

  Data<float,4> patch;
  patch.resize(1,sizeSlice,sizePhase,sizeRead); //   
  patch=0.0;


//koordinaten

double dummy = 100.; 
int x1g = 0.;
int y1g = 0.;
float x2g = 0.;
float y2g = 0.;
float x3g = 0.;
float y3g = 0.;

float dist (float x1, float y1, float x2, float y2) ; 
float angle (float a, float b, float c) ; 
float gaus (float distance, float sigma) ;

cout << "bis hier 2 " << endl; 


// Reduce mask to contain only Areas close to the curface. 
cout << " select GM regions .... " << endl; 

int vinc = 20; // This is the distance from every voxel that the algorythm is applied on. Just to make it faster and not loop over all voxels.


float dist_i = 0.; 
float dist_min = 0.;
float dist_min1 = 0.;
float dist_min2 = 0.;
float dist_min3 = 0.;
float dist_max = 0.;
float dist_p1 = 0.;




Data<int,4> vol_dist_int;
vol_dist_int.resize(1,sizeSlice,sizePhase,sizeRead); 
vol_dist_int=0.0;

cout << " start growing  from WM .... " << endl; 





int landmark1_x = 0; 
int landmark1_y = 0; 
int landmark2_x = 0;
int landmark2_y = 0;
int landmark3_x = 0;
int landmark3_y = 0;
int cur_seed_x = 0;
int cur_seed_y = 0;
int max_x = 0;
int max_y = 0;
float val_of_seed = 0.;

int grow_vinc = 5 ; 
int grow_vinc_lat = 3 ; 
float landmark_dist = 0. ; 
float value_landmark1 = 0. ; 
float value_landmark2 = 0. ; 
float value_landmark3 = 0. ; 


int number_of_columns = 50 ;  

  Data<float,4> TWODGRID;
  TWODGRID.resize(2,sizeSlice,sizePhase,sizeRead); //   
  TWODGRID=0.0;

int number_touching_voxels = 0 ; 
///////////////////////////////////////
///// BIG slice loop START    /////////
///////////////////////////////////////

for(int islice=0; islice<sizeSlice; ++islice){   //     for(int islice=0; islice<sizeSlice; ++islice){  

 landmark1_x = 0; 
 landmark1_y = 0; 
 landmark2_x = 0;
 landmark2_y = 0;
 landmark3_x = 0;
 landmark3_y = 0;
value_landmark1 = 0. ; 
value_landmark2 = 0. ; 
value_landmark3 = 0. ; 
cur_seed_x = 0;
cur_seed_y = 0;
max_x = 0;
max_y = 0;
val_of_seed = 0.;

      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	 	if (landmarks(0,islice,iy,ix) == 1 && renumerated(0,islice,iy,ix) == 2 ) {
			landmark1_x = ix  ;
			landmark1_y = iy  ;
		}
	 	if (landmarks(0,islice,iy,ix) == 3 && renumerated(0,islice,iy,ix) == 2 ) {
			landmark2_x = ix  ;
			landmark2_y = iy  ;
		}
	 	if (landmarks(0,islice,iy,ix) == 2 && renumerated(0,islice,iy,ix) == 2 ) {
			landmark3_x = ix  ;
			landmark3_y = iy  ;
		}
        }
      }
    

landmark_dist = dist(landmark1_x,landmark1_y, landmark2_x , landmark2_y) ; 

cout << "Slice " << islice << "  landmark 1 [" << landmark1_x << "," << landmark1_y  << "]    landmark 2 [" << landmark2_x << "," << landmark2_y <<"]" << "    landmark 3 [" << landmark3_x << "," << landmark3_y <<"]    Landmark distance is " << landmark_dist <<   endl ; 



cur_seed_x = landmark1_x ;
cur_seed_y = landmark1_y ;
grow1D(0,islice,cur_seed_y,cur_seed_x) = 1.; 


/////////////////////////////////////////////////////////////
///// LOOP over grwoing iterations in middle layer    /////////
/////////////////////////////////////////////////////////////

   while  (value_landmark2 == 0  ){

	val_of_seed = grow1D(0,islice,cur_seed_y,cur_seed_x) ; 
	dist_max = 0; 

	for(int iy_i=max(0,cur_seed_y-grow_vinc); iy_i<min(cur_seed_y+grow_vinc+1,sizePhase); ++iy_i){
	    for(int ix_i=max(0,cur_seed_x-grow_vinc); ix_i<min(cur_seed_x+grow_vinc+1,sizeRead); ++ix_i){

		if (grow1D(0,islice,iy_i,ix_i) == 0 && renumerated(0,islice,iy_i,ix_i) == 2 && dist(ix_i,iy_i, landmark2_x, landmark2_y) <= landmark_dist  ){
//		if (grow1D(0,islice,iy_i,ix_i) == 0 && renumerated(0,islice,iy_i,ix_i) == 2 ){
			grow1D(0,islice,iy_i,ix_i) = dist(ix_i,iy_i, cur_seed_x , cur_seed_y)+val_of_seed ; 
			
			if ( grow1D(0,islice,iy_i,ix_i) >  dist_max ) {
				dist_max = grow1D(0,islice,iy_i,ix_i) ; 
				max_x = ix_i ;
				max_y = iy_i ; 
			}
			if ( iy_i ==  landmark1_y &&  ix_i ==  landmark1_x ) value_landmark1 = grow1D(0,islice,iy_i,ix_i) ; 
			if ( iy_i ==  landmark2_y &&  ix_i ==  landmark2_x ) value_landmark2 = grow1D(0,islice,iy_i,ix_i) ; 
			if ( iy_i ==  landmark3_y &&  ix_i ==  landmark3_x ) value_landmark3 = grow1D(0,islice,iy_i,ix_i) ; 
		} 

//cout <<  "curr seed =  " << cur_seed_x << "  " << cur_seed_y   <<  "     grow1D(0,islice,iy_i,ix_i) =  " << grow1D(0,islice,iy_i,ix_i)  << "  renumerated(0,islice,iy_i,ix_i)    " << renumerated(0,islice,iy_i,ix_i)  <<   endl ;
//cout <<  "dist(ix_i,iy_i, landmark2_x, landmark2_y) =  "<<  dist(ix_i,iy_i, landmark2_x, landmark2_y)   <<  "  landmark_dist =  " << landmark_dist  <<   endl ;
  
	   }
        }
	// define next seed 
	cur_seed_x = max_x ;
	cur_seed_y = max_y ;


	if (landmark2_x == 0 && landmark2_y == 0 )  value_landmark2 = 0.5 ; // otherwise while loop runs for ever
    }
//cout <<  "I get beyonf this while loop s "   <<   endl ; 



/////////////////////////////////////////////////////////////
///// get cortex patch     /////////
/////////////////////////////////////////////////////////////
//patch = grow1D; 
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if (grow1D(0,islice,iy,ix) > 0 ) {
			patch(0,islice,iy,ix) = 2; 
		}
        }
      }







  for(int ilayer=number_of_layers/2-2; ilayer>0; ilayer = ilayer - 1 ){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  dist_min2 = 10000.;
	  x1g = 0;
	  y1g = 0;
	   if (file1(0,islice,iy,ix) == ilayer  && patch(0,islice,iy,ix) == 0 ){
	    	for(int iy_i=max(0,iy-grow_vinc_lat); iy_i<min(iy+grow_vinc_lat,sizePhase); ++iy_i){
	     	 for(int ix_i=max(0,ix-grow_vinc_lat); ix_i<min(ix+grow_vinc_lat,sizeRead); ++ix_i){
			if (patch(0,islice,iy_i,ix_i) != 0 ){		 
			  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i; 
			    y1g = iy_i; 
			  }  
			}  
	  	 }
	  	}
		if ( dist_min2 <= grow_vinc_lat) patch(0,islice,iy,ix) =  2; 
	   }
        }
      }     
   }
   for(int ilayer=number_of_layers/2+2; ilayer < number_of_layers+2; ilayer = ilayer + 1 ){
     for(int iy=0; iy<sizePhase; ++iy){
       for(int ix=0; ix<sizeRead; ++ix){
	  dist_min2 = 10000.;
	  x1g = 0;
	  y1g = 0;
	   if (file1(0,islice,iy,ix) == ilayer  && patch(0,islice,iy,ix) == 0 ){
	    	for(int iy_i=max(0,iy-grow_vinc_lat); iy_i<min(iy+grow_vinc_lat,sizePhase); ++iy_i){
	     	 for(int ix_i=max(0,ix-grow_vinc_lat); ix_i<min(ix+grow_vinc_lat,sizeRead); ++ix_i){
			if (patch(0,islice,iy_i,ix_i) != 0  ){		 
			  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i; 
			    y1g = iy_i; 
			  }  
			}  
	  	 }
	  	}
		if ( dist_min2 <= grow_vinc_lat) patch(0,islice,iy,ix) = 2; 
	   }
        }
      }     
   }



/////////////////////////////////////////////////////////////
///// get rid of GM vis a vis     /////////
/////////////////////////////////////////////////////////////

      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if ( patch(0,islice,iy,ix) != 0 && ( file1(0,islice,iy,ix) == number_of_layers || file1(0,islice,iy,ix) == number_of_layers-1 ) )  {
			for(int iy_i=max(0,iy-1); iy_i<=min(iy+1,sizePhase); ++iy_i){
	     	 		for(int ix_i=max(0,ix-1); ix_i<=min(ix+1,sizeRead); ++ix_i){
					if (patch(0,islice,iy_i,ix_i) == 0  ) number_touching_voxels++ ;
	  	 		}
	  		}
			if (number_touching_voxels >= 3) patch(0,islice,iy,ix) = 0; 
			//patch(0,islice,iy,ix) = number_touching_voxels ;
			number_touching_voxels = 0.; 
		}
        }
      }


      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		if ( patch(0,islice,iy,ix) != 0 && ( file1(0,islice,iy,ix) == number_of_layers || file1(0,islice,iy,ix) == number_of_layers-1 ) )  {
			for(int iy_i=max(0,iy-1); iy_i<=min(iy+1,sizePhase); ++iy_i){
	     	 		for(int ix_i=max(0,ix-1); ix_i<=min(ix+1,sizeRead); ++ix_i){
					if (patch(0,islice,iy_i,ix_i) == 0  ) number_touching_voxels++ ;
	  	 		}
	  		}
			if (number_touching_voxels >= 3) patch(0,islice,iy,ix) = 0; 
			//patch(0,islice,iy,ix) = number_touching_voxels ;
			number_touching_voxels = 0.; 
		}
        }
      }



      for(int iy=1; iy<sizePhase-1; ++iy){
        for(int ix=1; ix<sizeRead-1; ++ix){
 
		if ( patch(0,islice,iy,ix) != 0 &&  file1(0,islice,iy,ix) == number_of_layers+1  )  {
			
			for(int iy_i=iy-1; iy_i<=iy+1; ++iy_i){
	     	 		for(int ix_i=ix-1; ix_i<=ix+1; ++ix_i){
					if (patch(0,islice,iy_i,ix_i) == 0  ) number_touching_voxels = number_touching_voxels + 1  ;
	  	 		}
	  		}

			if (number_touching_voxels > 4) patch(0,islice,iy,ix) = 0;
			//patch(0,islice,iy,ix) = 10 + number_touching_voxels; 

			number_touching_voxels = 0;
			
			//patch(0,islice,iy,ix) = 0; 
		}
        }
      }
   

////////////////////////////////////////////////////////////
///// extend to 2Dgrid     /////////
/////////////////////////////////////////////////////////////

     for(int iy=0; iy<sizePhase; ++iy){
       for(int ix=0; ix<sizeRead; ++ix){
	  dist_min2 = 10000.;
	  x1g = 0;
	  y1g = 0;
	   if (patch(0,islice,iy,ix) > 0 ){

	    	for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	     	 for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
			if (grow1D(0,islice,iy_i,ix_i) != 0 && dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < vinc ){		 
			  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
			  if (dist_i < dist_min2 ){
			    dist_min2 = dist_i ; 
			    x1g = ix_i; 
			    y1g = iy_i; 
			  }  
			}  
	  	 }
	  	}

		grow2D(0,islice,iy,ix) =  grow1D(0,islice,y1g,x1g); 
	   }
        }
      }     






//////////////////////////////////////////////////
///// normalizefor coordinate system     /////////
//////////////////////////////////////////////////
cout <<  "Slice " << islice << "    value_landmark1 = " << value_landmark1  << "    value_landmark2 = " << value_landmark2  << "   value_landmark3 = " << value_landmark3  <<   endl ; 
//dummy = grow2D(0,islice, landmark2_y,landmark2_x) ; 
//cout <<  "dummy " << dummy << endl; 
 

      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	
		if (grow2D(0,islice,iy,ix) > 2 && grow2D(0,islice,iy,ix) <  value_landmark3 ){
	  		TWODGRID(0,islice,iy,ix) =  (int) (grow2D(0,islice,iy,ix)/value_landmark3  * number_of_columns/2  )+1  ;
			TWODGRID(1,islice,iy,ix) = file1(0,islice,iy,ix) ; 
            	}
		if (grow2D(0,islice,iy,ix) >= value_landmark3 && grow2D(0,islice,iy,ix) <  value_landmark2-1 ){
	  		TWODGRID(0,islice,iy,ix) = (int)  ( (grow2D(0,islice,iy,ix)-value_landmark3)/(value_landmark2-value_landmark3) * number_of_columns/2   + 1 +  number_of_columns/2 ) ;// /(value_landmark2-value_landmark3) )+50  ;
			TWODGRID(1,islice,iy,ix) = file1(0,islice,iy,ix) ; 
            	}
	
		//if (grow2D(0,islice,iy,ix) > 0){
		//cout << grow2D(0,islice,iy,ix) << "  " << value_landmark2 << "   " <<   (float) grow2D(0,islice,iy,ix)/ value_landmark2 << endl;

 		//TWODGRID(0,islice,iy,ix) =   grow2D(0,islice,iy,ix) / grow2D(0,islice, landmark2_y,landmark2_x) *100 ;
		//} 
		
        }
      }
    


 }  //////////////////////////////////
///// BIG slice loop END     /////////
//////////////////////////////////


//GMkoord.autowrite("GMkoord.nii", wopts, &prot);
//thickness.autowrite("thickness.nii", wopts, &prot);

grow1D.autowrite("grow1D.nii", wopts, &prot);
grow2D.autowrite("grow2D.nii", wopts, &prot);
renumerated.autowrite("renumerated.nii", wopts, &prot);
patch.autowrite("patch.nii", wopts, &prot);
TWODGRID.autowrite("TWODGRID.nii", wopts, &prot);

  return 0;
}



  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }

  float angle (float a, float b, float c) {
	if (a*a+b*b-c*c <= 0 ) return 3.141592 ;
    	else return acos((a*a+b*b-c*c)/(2.*a*b));
  }


  float gaus (float distance, float sigma) {
    return 1./(sigma*sqrt(2.*3.141592))*exp (-0.5*distance*distance/(sigma*sigma));
  }

