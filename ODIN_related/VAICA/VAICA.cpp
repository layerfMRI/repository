
// Mittelwert micalc -mask GM_Mask1.nii.gz -if tSNR_map_trad.nii
 // mit make compilieren ... alles muss von pandamonium aus passieren


//mean in mask mit " micalc -mask maskfile.nii -if timeseries.nii "

#include <odindata/data.h>
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h> 
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>
     #include <gsl/gsl_sort_vector.h>
     #include <gsl/gsl_sort.h>
#include <gsl/gsl_vector.h>
     
  //   #include <gsl/gsl_statistics_int.h>
   //  #include <gsl/gsl_statistics.h>
 
#define PI 3.14159265; 

//#include "utils.hpp"

void usage() { cout << "VAICA  < VASO > <BOLD> <ICA maps from MELODIC> <cutoff> " << endl;}





int main(int argc,char* argv[]) {

  if (argc!=5) {usage(); return 0;}
  STD_string filename1(argv[1]);
  STD_string filename2(argv[2]);
  STD_string filename3(argv[3]);
  float cutoff(atoi(argv[4]));

  Range all=Range::all();
  
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> VASO;
  VASO.autoread(filename1, FileReadOpts(), &prot);
  int nrep=VASO.extent(firstDim);
  int sizeSlice=VASO.extent(secondDim);
  int sizePhase=VASO.extent(thirdDim);
  int sizeRead=VASO.extent(fourthDim);
  double numb_voxels=(int)(sizeSlice*sizePhase*sizeRead) ;

  Data<float,4> ICAmaps;
  ICAmaps.autoread(filename3, FileReadOpts(), &prot);

  Data<float,4> BOLD;
  BOLD.autoread(filename2, FileReadOpts(), &prot);

  int nICA=ICAmaps.extent(firstDim);
  
cout << " nrep " <<  nrep  << "    nICA " <<  nICA << endl; 


    ofstream outtime_B("ICA_time_courses_B.dat");
  if (!outtime_B) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

    ofstream outtime_V("ICA_time_courses_V.dat");
  if (!outtime_V) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }


    ofstream outtime_sc("remove_me.dat");
  if (!outtime_sc) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }

 ofstream outsc("scores.dat");
  if (!outsc) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
  
//cout << " nrep = " <<  nrep  << " zeile = " <<  zeile  << " inread[0] = " <<  inread[0]  <<endl; 
  

// ALLOCATOPN AND INICIATION
double vec_VASO[nICA][nrep]  ;
double vec_BOLD[nICA][nrep]  ;

double vec_VASO_mean[nICA]  ;
double vec_BOLD_mean[nICA]  ;

double vec_BOLD_VASO_corr[nICA]  ;
double vec_index[nICA]  ;

double lambda = 0.; 
double cov11 = 0.; 
double sumsq = 0.; 

double	vec_lambda[nICA] ;  
double	vec_cov11[nICA] ;  
double	vec_sumsq[nICA] ;
double	vec_sorter[nICA] ;

for(int i = 0; i< nICA ; i++) {
		for(int timestep = 0 ; timestep < nrep ; timestep++){ 
			vec_VASO[i][timestep] = 0. ; 
			vec_BOLD[i][timestep] = 0. ; 
		}
	vec_VASO_mean[i] = 0.;  
	vec_BOLD_mean[i] = 0.;  
	vec_BOLD_VASO_corr[i] = 0.;
	vec_index[i] = (double)(i)+1.;  
	vec_lambda[i] = 0.;  
	vec_cov11[i] = 0.;  
	vec_sumsq[i] = 0.;
	vec_sorter[i] = 0.;
}

gsl_vector * gslv_BOLD_VASO_corr = gsl_vector_alloc (nICA) ;
gsl_vector * gslv_index          = gsl_vector_alloc (nICA) ;
gsl_vector * gslv_lambda	 = gsl_vector_alloc (nICA) ;
gsl_vector * gslv_cov11          = gsl_vector_alloc (nICA) ;
gsl_vector * gslv_sumsq		 = gsl_vector_alloc (nICA) ;
gsl_vector * gslv_sorter	 = gsl_vector_alloc (nICA) ;


// GET TIME-COURSES FOR ALL ICAS
for(int timestep = 0 ; timestep < nrep  ; timestep++) {
  for(int i = 0; i < nICA; i++) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	  if (abs(ICAmaps(i,islice,iy,ix))> cutoff ){
		vec_VASO[i][timestep]  = vec_VASO[i][timestep] + VASO(timestep,islice,iy,ix)/numb_voxels*ICAmaps(i,islice,iy,ix); 
		vec_BOLD[i][timestep]  = vec_BOLD[i][timestep] + BOLD(timestep,islice,iy,ix)/numb_voxels*ICAmaps(i,islice,iy,ix); 
	  }
        }  
      } 
    }
  
  vec_VASO_mean[i] = vec_VASO_mean[i] +  vec_VASO[i][timestep]/nrep  ;  
  vec_BOLD_mean[i] = vec_BOLD_mean[i] +  vec_BOLD[i][timestep]/nrep  ; 
  }
}


// DEMEAN-TIME COURSES
for(int timestep = 0 ; timestep < nrep ; timestep++) {
		for(int i = 0; i< nICA ; i++){
			//cout   << timestep  << "  " <<  vec_n[i][timestep] ; 
			vec_VASO[i][timestep] =  vec_VASO[i][timestep]/vec_VASO_mean[i]-1.  ; 
			vec_BOLD[i][timestep] =  vec_BOLD[i][timestep]/vec_BOLD_mean[i]-1. ; 
		}

}

// Write out time courses
for(int timestep = 0 ; timestep < nrep ; timestep++) {
		for(int i = 0; i< nICA ; i++){

			outtime_V   <<  vec_VASO[i][timestep]  << "   " ; 
			outtime_B   <<  vec_BOLD[i][timestep]  << "   " ; 
		}
			outtime_V    << endl ; 
			outtime_B    << endl; 
}


// Calculate corelation of VASO and BOLD
for(int i = 0; i< nICA ; i++){
	vec_BOLD_VASO_corr[i]  = gsl_stats_correlation (vec_VASO[i],  1, vec_BOLD[i] ,1, nrep );
}


for(int i = 0; i< nICA ; i++){
	//gsl_fit_mul (const double * x, const size_t xstride, const double * y, const size_t ystride, size_t n, double * c1, double * cov11, double * sumsq)
	gsl_fit_mul (vec_VASO[i], 1, vec_BOLD[i], 1, nrep , &lambda, &cov11, &sumsq) ; 
	vec_lambda[i] = lambda;  
	vec_cov11[i] = cov11;  
	vec_sumsq[i] = sumsq;
	lambda = 0; 
	cov11 = 0; 
	sumsq = 0; 
//cout << i << "   lamda = " <<lambda << "     correl " << vec_BOLD_VASO_corr[i]  <<"      sumsq = " <<sumsq << "      cov11 = " <<cov11   <<endl;
}
//DEGUB
//for(int timestep = 0 ; timestep < nrep ; timestep++) {
//	outtime_sc  <<  vec_VASO[17][timestep]  << "   "  <<  vec_BOLD[17][timestep]  << endl ; 
//}
//gsl_fit_mul (vec_VASO[18], 1, vec_BOLD[18], 1, nrep , &lambda, &cov11, &sumsq) ;
//	cout << " #################### "  << lambda << endl;

// Prepare GSL vectors and refill them with the ICA values 
for(int i = 0; i< nICA ; i++){
	gsl_vector_set (gslv_BOLD_VASO_corr, i, vec_BOLD_VASO_corr[i] ); 
	gsl_vector_set (gslv_index, i, vec_index[i] ); 
	gsl_vector_set (gslv_lambda, i, vec_lambda[i] ); 
	gsl_vector_set (gslv_cov11, i, vec_cov11[i] ); 
	gsl_vector_set (gslv_sumsq, i, vec_sumsq[i] ); 
}


// DEBUGGING
//double vec_1 [10] = {1,2,3,4,5,6,7,8,9,10} ;
//double vec_2 [10] = {-2,-4,-6,-8,-10,-12,-14.5,-16,-18,-20} ;
//gsl_fit_mul (vec_1, 1, vec_2, 1, 10 , &lambda, &cov11, &sumsq) ; 
//cout  << "   lamda = " <<lambda << "      sumsq = " <<sumsq << "      cov11 = " <<cov11   <<endl;


for(int i = 0; i< nICA ; i++)  vec_sorter[i] = vec_sumsq[i]*(1-vec_BOLD_VASO_corr[i]);
//for(int i = 0; i< nICA ; i++)  vec_sorter[i] = vec_lambda[i];
for(int i = 0; i< nICA ; i++) gsl_vector_set (gslv_sorter, i, vec_sorter[i] );
gsl_sort_vector2( 	gslv_sorter , gslv_sumsq) ;
for(int i = 0; i< nICA ; i++) gsl_vector_set (gslv_sorter, i, vec_sorter[i] );
gsl_sort_vector2( 	gslv_sorter , gslv_cov11) ;
for(int i = 0; i< nICA ; i++) gsl_vector_set (gslv_sorter, i, vec_sorter[i] );
gsl_sort_vector2( 	gslv_sorter , gslv_BOLD_VASO_corr) ;
for(int i = 0; i< nICA ; i++) gsl_vector_set (gslv_sorter, i, vec_sorter[i] );
gsl_sort_vector2( 	gslv_sorter , gslv_lambda) ;
for(int i = 0; i< nICA ; i++) gsl_vector_set (gslv_sorter, i, vec_sorter[i] );
gsl_sort_vector2( 	gslv_sorter , gslv_index) ;



// WRITE out VASO BOLD correcponsece scores 
for(int i = 0; i< nICA ; i++){
	cout    <<setprecision(4)<< fixed	;
	cout    <<setw(8) << "  corr   = " << gsl_vector_get(gslv_BOLD_VASO_corr, i ) ;
	cout 	<<setw(8) << "  lamda  = " << gsl_vector_get(gslv_lambda        , i ) ;
	cout 	<<setw(8) << "  sumsq  = " << gsl_vector_get(gslv_sumsq         , i ) ;
	cout	<<setw(8) << "  cov11  = " << gsl_vector_get(gslv_cov11         , i ) ;
	cout	<<setw(8) << "  index  = " << gsl_vector_get(gslv_index         , i )-1 ;
	cout	<<setw(8) << "  neurallity score   = " << 1/(gsl_vector_get(gslv_sumsq, i) * (1 - gsl_vector_get(gslv_BOLD_VASO_corr, i ))) ;
	cout	<<setw(8) << "  vascular score  = " <<  gsl_vector_get(gslv_sumsq, i) * (gsl_vector_get(gslv_lambda        , i ) +1);
	cout 	<<  endl ; 
}

for(int i = 0; i< nICA ; i++){
	outsc    <<setprecision(4)<< fixed	;
	outsc    <<setw(8) << "   " <<gsl_vector_get(gslv_BOLD_VASO_corr, i ) ;
	outsc 	<<setw(8) << "   " <<gsl_vector_get(gslv_lambda        , i ) ;
	outsc 	<<setw(8) << "   " <<gsl_vector_get(gslv_sumsq         , i ) ;
	outsc	<<setw(8) << "   " <<gsl_vector_get(gslv_cov11         , i ) ;
	outsc	<<setw(8) << "   " <<gsl_vector_get(gslv_index         , i ) -1;
	outsc	<<setw(8) << "  " << 1/(gsl_vector_get(gslv_sumsq, i) * (1 - gsl_vector_get(gslv_BOLD_VASO_corr, i )))  ;
	outsc	<<setw(8) << "  " <<   gsl_vector_get(gslv_sumsq, i) * (gsl_vector_get(gslv_lambda        , i ) +1) ;
	outsc 	<<  endl ; 
}

cout << " exclude the following networks " << endl;
for(int i = nICA-1; i> nICA/2 ; i--){
cout << (int)(gsl_vector_get(gslv_index         , i ) -1) << "," ;
outtime_sc <<(int)(gsl_vector_get(gslv_index         , i ) -1) << "," ;
}
cout << endl;




 //ofstream outf;
// outf.open("out.txt");
 outtime_B.close() ;
 outtime_V.close() ;
 outsc.close() ;
 outtime_sc.close();
//cout << " bis hier3 " << endl; 



//cout << " bis hier4 " << endl; 

  return 0;

}
