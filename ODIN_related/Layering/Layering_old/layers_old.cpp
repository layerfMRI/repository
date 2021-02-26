
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

void usage() { cout << "file  < surface> < brain mask> <cutoff>" << endl;}


int main(int argc,char* argv[]) {
 
  if (argc!=4) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  float cutoff(atoi(argv[3]));

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

  
  Data<float,4> file2;
  file2.autoread(filename2);
  //int nrep=file2.extent(firstDim);
  //int sizeSlice=file2.extent(secondDim);
  //int sizePhase=file2.extent(thirdDim);
  //int sizeRead=file2.extent(fourthDim);
  
cout << "bis hier 2 " << endl; 

  Data<float,4> data1;
  data1.resize(1,sizeSlice,sizePhase,sizeRead);
  data1=0.0;
  
  Data<float,4> data2;
  data2.resize(1,sizeSlice,sizePhase,sizeRead);
  data2=0.0;

  Data<float,4> surface;
  surface.resize(1,sizeSlice,sizePhase,sizeRead);
  surface=0.0;

  Data<float,4> curvature;
  curvature.resize(1,sizeSlice,sizePhase,sizeRead);
  curvature=0.0;

  Data<float,4> kruemm_radius;
  kruemm_radius.resize(1,sizeSlice,sizePhase,sizeRead);
  kruemm_radius=0.0;
  
  Data<float,4> kruemm_radius_smooth;
  kruemm_radius_smooth.resize(1,sizeSlice,sizePhase,sizeRead);
  kruemm_radius_smooth=0.0;

//koordinaten
float x1 = 0.;
float y1 = 0.;

  
float area (float x1, float y1, float x2, float y2, float x3, float y3) ; 
float dist (float x1, float y1, float x2, float y2) ; 
float angle (float a, float b, float c) ; 
float kruem_radius_fkt (float x1, float y1, float x2, float y2, float x3, float y3, float sizeRead) ; // sizeRead is the maximal
float vol_distfkt (float DistToSurf, float kuemmungsradius, float curvsture) ; 

cout << "bis hier 2 " << endl; 


// Reduce mask to contain only Areas close to the curface. 
cout << " select GM regions .... " << endl; 

int vinc = 14; // This is the distance from every voxel that the algorythm is applied on. Just to make it faster and not loop over all voxels.
/*
   for(int islice=0; islice<sizeSlice; ++islice){  //     for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	  if (file1(0,islice,iy,ix) > 0.8){
	    for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (file2(0,islice,iy_i,ix_i) > 0.8 && file1(0,islice,iy_i,ix_i) < 0.5){
		 file1(0,islice,iy_i,ix_i) = 0.5;		  
		}  
	      }
	    }
	  }
	}
      }
    }
*/

float dist_i = 0.; 
float dist_min = 0.;
float dist_max = 0.;
float dist_p1 = 0.;

cout << " get equidistance  .... " << endl; 

//////////////////////////////////
/////Get  closest voxel  /////////
//////////////////////////////////
    for(int islice=0; islice<sizeSlice; ++islice){  
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl;  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	    if (file2(0,islice,iy,ix) > .8){
	  
	  dist_min = 1000.;
	 
	    for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (file1(0,islice,iy_i,ix_i) > 0.8){
		 
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


	  data2(0,islice,iy,ix) = dist((float)ix,(float)iy,x1,y1);

	  float max_dist = 0.;

	    }
            if ( data2(0,islice,iy,ix) > vinc ) {
	  	data2(0,islice,iy,ix) = 0;
		}		
        }
      }
    }

  data2.autowrite("eq_dist.nii", wopts, &prot);
  
////////////////////////////////////
/////// estimate surface layer /////
////////////////////////////////////


cout << " get Surface layer  .... " << endl; 
   for(int islice=0; islice<sizeSlice; ++islice){  //     for(int islice=0; islice<sizeSlice; ++islice){
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl ;  //sizeSlice instead of 1.
      for(int iy=1; iy<sizePhase-1; ++iy){
        for(int ix=1; ix<sizeRead-1; ++ix){
		if ( data2(0,islice,iy,ix) == 1 ){
			if (file1(0,islice,iy-1,ix) == 1. && data2(0,islice,iy-1,ix) < 1.) surface(0,islice,iy-1,ix) = 1.;
			if (file1(0,islice,iy+1,ix) == 1. && data2(0,islice,iy+1,ix) < 1.) surface(0,islice,iy+1,ix) = 1.;  
			if (file1(0,islice,iy,ix-1) == 1. && data2(0,islice,iy,ix-1) < 1.) surface(0,islice,iy,ix-1) = 1.;
			if (file1(0,islice,iy,ix+1) == 1. && data2(0,islice,iy,ix+1) < 1.) surface(0,islice,iy,ix+1) = 1.;
		}
	}
      }
  }



/////// big loop to get Kruemmungsradius /////
cout << " Calculate Kruemmungsradius  .... " << endl; 

int nvinc_vox = 15; 
float cortical_thickness = 15; 
float curvature_angle = 0.; 
float a_ = 0.; 
float b_ = 0.; 
float c_ = 0.; 
float alpha_ = 0.; 
float betha_ = 0.; 
float gamma_ = 0.; 

int nvinc_vox_run_indx = 0; 
int vinc_vox_x[nvinc_vox];
int vinc_vox_y[nvinc_vox];
int kordinate_fst_x = 0;
int kordinate_fst_y = 0;
int kordinate_snd_x = 0;
int kordinate_snd_y = 0;

for (int i = 0; i < nvinc_vox ; i++)	vinc_vox_x[i] = vinc_vox_y[i] = 0;
float radius = 1.; 
int numb_of_surface_vox = 0;  
 
Data<int,4> closest_8;
closest_8.resize(2,sizeSlice,sizePhase,sizeRead); // for 
closest_8=0.0;


  for(int islice=0; islice<sizeSlice; ++islice){  //     for(int islice=0; islice<sizeSlice; ++islice){
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl ;  //sizeSlice instead of 1.
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	    if ( surface(0,islice,iy,ix) > 0. ){
	    //////////////////////////////////////////////////////
	    /////// find closest voxel that is 8 voxls away /////
	    //////////////////////////////////////////////////////	
	      dist_min = 1000.;
	      for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	       for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (data2(0,islice,iy_i,ix_i) > 8){
		 
		  dist_i = dist((float)ix,(float)iy,(float)ix_i,(float)iy_i); 
		  if (dist_i < dist_min ){
		    dist_min = dist_i ; 
		    x1 = ix_i;
		    y1 = iy_i; 
		  }  
		}  
	       }
	      }	
 	     //if( dist((float)ix,(float)iy,(float)x1,(float)y1) > vinc ) surface(0,islice,iy,ix) = 0; // just in case there is no 8voxel for this surfave voxel.
	     //// ok now the closest voxel with distant 8 has coordinates x1 and y1
		closest_8(0,islice,(int)y1,(int)x1) = 1.; // debuging to see where the 8voxels are
		closest_8(1,islice,(int)y1,(int)x1) = dist((float)ix,(float)iy,(float)x1,(float)y1);
		surface(0,islice,iy,ix) = dist((float)ix,(float)iy,(float)x1,(float)y1);
		//cout << "  dist from suface to 8voxel " << dist((float)ix,(float)iy,(float)x1,(float)y1) << endl; 
	     //// now find radius of closest 15 voxels 	
		/*		
		radius = 2.; 
		numb_of_surface_vox = 0;  
		while (numb_of_surface_vox < nvinc_vox){
		   numb_of_surface_vox= 0;
		   radius++;
			for(int iy_i=(int)max(0,(int)iy-(int)radius); iy_i<min((int)iy+(int)radius,sizePhase); ++iy_i){
	                  for(int ix_i=max(0,(int)ix-(int)radius); ix_i<min((int)ix+(int)radius,sizeRead); ++ix_i){
				if (surface(0,islice,iy_i,ix_i) > 0. && dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < radius){
					 numb_of_surface_vox ++; 
				}
			  }
			}
		 //if (radius > 50) cout << "radius = " << radius << "    numb_of_surface_vox  " << numb_of_surface_vox << endl; 
		}
		
		closest_8(1,islice,(int)y1,(int)x1) = radius; // debuging to see how the kruemmungsradius ist

	     /// now write out the coordinated of the 15 clostest voxels. 
		nvinc_vox_run_indx = 0;
		for(int iy_i=(int)max(0,(int)iy-(int)radius); iy_i<min((int)iy+(int)radius,sizePhase); ++iy_i){
	            for(int ix_i=max(0,(int)ix-(int)radius); ix_i<min((int)ix+(int)radius,sizeRead); ++ix_i){
			if (dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < radius  && surface(0,islice,iy_i,ix_i) > 0. && nvinc_vox_run_indx < nvinc_vox){
				vinc_vox_x[nvinc_vox_run_indx] = ix_i;
				vinc_vox_y[nvinc_vox_run_indx] = iy_i;
				nvinc_vox_run_indx = nvinc_vox_run_indx + 1;	 
			}
		    }
		}
		*/
		radius = 10 ; //just choose a value 

	    	//////////////////////////////////////////////////////	
              	///  get furthest voxel from 8th line//////////////////	
	    	//////////////////////////////////////////////////////	
		dist_max = 0.;
		kordinate_fst_x = ix;
		kordinate_fst_y = iy;

		  for(int iy_i=(int)max(0,(int)iy-(int)radius); iy_i<min((int)iy+(int)radius,sizePhase); ++iy_i){
	              for(int ix_i=max(0,(int)ix-(int)radius); ix_i<min((int)ix+(int)radius,sizeRead); ++ix_i){
			if (surface(0,islice,iy_i,ix_i) > 0. && dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < radius){
				dist_i = dist((float)x1,(float)y1,(float)ix_i,(float)iy_i); 
		  		if (dist_i > dist_max ){
		    	 		dist_max = dist_i ; 
		    	 		kordinate_fst_x = ix_i;
		    	 		kordinate_fst_y = iy_i;
		  		} 
			} 
		      }
		  }
		//cout << " dist 8 to farstest vox " << dist((float)x1,(float)y1,(float)kordinate_fst_x,(float)kordinate_fst_y) << "    and dist from suface to fursthest voxel " << dist((float)ix,(float)iy,(float)kordinate_fst_x,(float)kordinate_fst_y) << endl; 
		//if( dist((float)ix,(float)iy,(float)x1,(float)y1) > vinc ) surface(0,islice,iy,ix) = 0; // just in case there is no 8voxel for this surfave voxel.
	    	//////////////////////////////////////////////////////	
              	///  get closest coxel with maximum area///////////////
	    	//////////////////////////////////////////////////////	
		dist_max = 0.;
		kordinate_snd_x = ix;
		kordinate_snd_y = iy;

		  for(int iy_i=(int)max(0,(int)iy-(int)radius); iy_i<min((int)iy+(int)radius,sizePhase); ++iy_i){
	              for(int ix_i=max(0,(int)ix-(int)radius); ix_i<min((int)ix+(int)radius,sizeRead); ++ix_i){
			if (surface(0,islice,iy_i,ix_i) > 0. && dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < radius){
				dist_i = area((float)x1,(float)y1,(float)ix_i,(float)iy_i,(float)kordinate_fst_x,(float)kordinate_fst_y); 
		  		if (dist_i > dist_max ){
		    	 		dist_max = dist_i ; 
		    	 		kordinate_snd_x = ix_i;
		    	 		kordinate_snd_y = iy_i;
		  		} 
			} 
		      }
		  }
		//cout << " dist 8 to farstest vox " << dist((float)x1,(float)y1,(float)kordinate_fst_x,(float)kordinate_fst_y) << "    and dist from suface to fursthest voxel " << dist((float)ix,(float)iy,(float)kordinate_fst_x,(float)kordinate_fst_y) << endl;
		////////////////////////// 
		////// get curvature ///// 
		////////////////////////// 
		a_ = dist((float)x1,(float)y1,(float)kordinate_fst_x,(float)kordinate_fst_y); // a= 8-first
		b_ = dist((float)ix,(float)iy,(float)kordinate_fst_x,(float)kordinate_fst_y); // b = first-surf
		c_ = dist((float)x1,(float)y1,(float)ix,(float)iy); // c = surf - 8
		alpha_ = angle (a_ , b_ , c_ ); 

		a_ = dist((float)ix,(float)iy,(float)kordinate_snd_x,(float)kordinate_snd_y); // a= surf - second
		b_ = dist((float)x1,(float)y1,(float)kordinate_snd_x,(float)kordinate_snd_y); // b = second-8
		c_ = dist((float)x1,(float)y1,(float)ix,(float)iy); // c = surf - 8
		betha_ = angle (a_ , b_ , c_ );

		a_ = dist((float)x1,(float)y1,(float)kordinate_fst_x,(float)kordinate_fst_y); // a=  first - 8
		b_ = dist((float)x1,(float)y1,(float)kordinate_snd_x,(float)kordinate_snd_y); // b = second-8
		c_ = dist((float)kordinate_fst_x,(float)kordinate_fst_y,(float)kordinate_snd_x,(float)kordinate_snd_y); // c = second - first
		gamma_ = angle (a_ , b_ , c_ );
		
		curvature(0,islice,iy,ix) = abs(alpha_) + abs(betha_) + abs(gamma_) ; // cortex it convexs, if value is larger than PI .... cortex is convave when value is smaller than PI 
		
		/////////////////////////////////////////////////////////
		////// ultimately calcutale kreummuns radius ////////////
		/////////////////////////////////////////////////////////
		kruemm_radius(0,islice,iy,ix) = kruem_radius_fkt ((float) kordinate_fst_x, (float) kordinate_fst_y, (float) ix, (float) iy, (float) kordinate_snd_x, (float) kordinate_snd_y, (float) 5*nvinc_vox);

	    }
	}
      }
  }
 closest_8.autowrite("closest_8.nii", wopts, &prot);
 surface.autowrite("surface.nii", wopts, &prot);
 curvature.autowrite("curvature.nii", wopts, &prot);
 kruemm_radius.autowrite("kruemm_radius.nii", wopts, &prot);

//////////////////////////////////////////////////////////////////////////////////
///// get smooth distributions of kruemmungs radius to avoid residual singularities
///////////////////////////////////////// /////////////////////////////////////////
cout << "smoothing Kruemmungsradius " << endl; 


int inner_dist = 15; // in Kruemmungs radius smoothing
float numb_of_vox_in_inner_dist = 0. ; // in Kruemmungs radius smoothing
float mean_kruemmunfsradius_within_inner_dist = 0.; // in Kruemmungs radius smoothing

 for(int islice=0; islice<sizeSlice; ++islice){  
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl;  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	     if (kruemm_radius(0,islice,iy,ix) > 0 ) {

		  for(int iy_i=(int)max(0,(int)iy-(int)inner_dist); iy_i<min((int)iy+(int)inner_dist,sizePhase); ++iy_i){
	              for(int ix_i=max(0,(int)ix-(int)inner_dist); ix_i<min((int)ix+(int)inner_dist,sizeRead); ++ix_i){
			if (kruemm_radius(0,islice,iy,ix) > 0  && dist((float)ix,(float)iy,(float)ix_i,(float)iy_i) < inner_dist){
			 	numb_of_vox_in_inner_dist ++; 
		  		mean_kruemmunfsradius_within_inner_dist = mean_kruemmunfsradius_within_inner_dist + kruemm_radius(0,islice,iy_i,ix_i); 
			} 
		      }
		  }
		kruemm_radius_smooth(0,islice,iy,ix) = 0.5 * (kruemm_radius(0,islice,iy,ix)+ mean_kruemmunfsradius_within_inner_dist/ numb_of_vox_in_inner_dist); 
		numb_of_vox_in_inner_dist = 0.; 
		mean_kruemmunfsradius_within_inner_dist = 0.;


	     }
	}
      }
  }

kruemm_radius_smooth.autowrite("kruemm_radius_smooth.nii", wopts, &prot);

///////////////////////////////////
/////Get volumr distance  /////////
///////////////////////////////////

cout << "calculating the volume distance " << endl; 
Data<float,4> vol_dist;
vol_dist.resize(1,sizeSlice,sizePhase,sizeRead); // for 
vol_dist=0.0;


    for(int islice=0; islice<sizeSlice; ++islice){  
	 cout   << "slice "  << islice  << " of " << sizeSlice << ".... " << endl;  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	    if (file2(0,islice,iy,ix) > .8){
	  
	  dist_min = 1000.;
	 
	    for(int iy_i=max(0,iy-vinc); iy_i<min(iy+vinc,sizePhase); ++iy_i){
	      for(int ix_i=max(0,ix-vinc); ix_i<min(ix+vinc,sizeRead); ++ix_i){
		if (kruemm_radius(0,islice,iy_i,ix_i) >= 1.){
		 
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


	  vol_dist(0,islice,iy,ix) =  abs(vol_distfkt(dist((float)ix,(float)iy,x1,y1), kruemm_radius(0,islice,(int)y1,(int)x1), curvature(0,islice,(int)y1,(int)x1))  /  vol_distfkt(cortical_thickness, kruemm_radius(0,islice,(int)y1,(int)x1), curvature(0,islice,(int)y1,(int)x1)));

	    }
            if ( vol_dist(0,islice,iy,ix) > 3. ) vol_dist(0,islice,iy,ix) = 0;
 	    if ( data2(0,islice,iy,ix) == 0.   ) vol_dist(0,islice,iy,ix) = 0;
	  	
		
        }
      }
    }

 vol_dist.autowrite("equi_vol_dist.nii", wopts, &prot);


/////////////////////////////////////////
///// devide cortex in X layers /////////
/////////////////////////////////////////

int number_of_layers = 10 ; 

Data<int,4> vol_dist_int;
vol_dist_int.resize(1,sizeSlice,sizePhase,sizeRead); 
vol_dist_int=0.0;

 for(int islice=0; islice<sizeSlice; ++islice){  
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead-0; ++ix){
	     if (vol_dist(0,islice,iy,ix) > 0 && vol_dist(0,islice,iy,ix) <= 3. ) {
		vol_dist_int(0,islice,iy,ix) = (int) ((float)number_of_layers*vol_dist(0,islice,iy,ix))+1. ; 
	     }
	}
      }
  }

vol_dist_int.autowrite("equi_vol_layers.nii", wopts, &prot);

 // koord.autowrite("koordinaten.nii", wopts, &prot);
  return 0;
}

float area (float x1, float y1, float x2, float y2, float x3, float y3) {
    return 0.5* abs(x1*(y2-y3) + x2 *(y3-y1) + x3*(y1-y2) );
  }

  float dist (float x1, float y1, float x2, float y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }
  
  float angle (float a, float b, float c) {
    return acos((a*a+b*b-c*c)/(2.*a*b));
  }

 float kruem_radius_fkt (float x1, float y1, float x2, float y2, float x3, float y3, float sizeRead) {
	if (area (x1,y1,x2,y2,x3,y3) > 0 )  return (dist(x1,y1,x2,y2)*dist(x1,y1,x3,y3)*dist(x3,y3,x2,y2))/(4.*area (x1,y1,x2,y2,x3,y3));
	else return (float)sizeRead ; 
    //return (sqrt(((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))*((x2-x3)*(x2-x3)+(y2-y3)*(y2-y3))*((x3-x1)*(x3-x1)+(y3-y1)*(y3-y1))))/(2.*abs(x1*y2+x2*y3+x3*y1-x1*y3-x2*y1-x3*y1));
 }


 float vol_distfkt (float DistToSurf, float kuemmungsradius, float curvsture) {
	if (curvsture > 3.14159265  ) { // this is convex and bottom of sulcus  I use a small angle approximation here
		return  2. * DistToSurf - DistToSurf * DistToSurf / kuemmungsradius ;
		//return  2.  -   DistToSurf / kuemmungsradius ;
	}   
	if (curvsture <= 3.14159265 )  { // this is concave and top of gyrus I use a small angle approximation here
		return 2. * DistToSurf + DistToSurf * DistToSurf / kuemmungsradius  ;
		//return 2.  + DistToSurf  / kuemmungsradius  ;
	}   
 }


