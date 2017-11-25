
// bei standard GRAPPA 2 datensatz, dauert es damit ca. 15 h. 
// 

#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     #include <gsl/gsl_multifit.h>
     #include <gsl/gsl_statistics_double.h>
#include <time.h>
#define PI 3.14159265;

//#include "utils.hpp"

void usage() { cout << "tSNR  < Bild 1 > < Bild 2 > < Bild 3 > < Bild 4 > < Bild 5 > < Bild 6 > < Bild 7 > < Bild 8 > < Bild 9 > < Bild 10 > < Bild 11 > < Bild 12 > < Bild 13 > < Bild 14 > < Bild 15 > < Bild 16 > < Bild 17 > < Bild 18 > < Bild 19 > < Bild 20 > < Bild 21 > < Bild 22 > < Bild 23 > < Bild 24 >< Bild 25 > < Bild 26 > < Bild 27 > < Bild 28 > < Bild 29 > < Bild 30 > < Bild 31 > < Bild 32 > <cutoff> " << endl;}

int main(int argc,char* argv[]) {
int N_coils = 32;
int null_init = 1 ;  // use 0, if you want to optimize BOLD,  and use 1 if you want to optimize for VASO. 

  if (argc!=34) {usage(); return 0;}
  STD_string filename0(argv[1]);
  STD_string filename1(argv[2]);
  STD_string filename2(argv[3]);
  STD_string filename3(argv[4]);
  STD_string filename4(argv[5]);
  STD_string filename5(argv[6]);
  STD_string filename6(argv[7]);
  STD_string filename7(argv[8]);
  STD_string filename8(argv[9]);
  STD_string filename9(argv[10]);
  STD_string filename10(argv[11]);
  STD_string filename11(argv[12]);
  STD_string filename12(argv[13]);
  STD_string filename13(argv[14]);
  STD_string filename14(argv[15]);
  STD_string filename15(argv[16]);
  STD_string filename16(argv[17]);
  STD_string filename17(argv[18]);
  STD_string filename18(argv[19]);
  STD_string filename19(argv[20]);
  STD_string filename20(argv[21]);
  STD_string filename21(argv[22]);
  STD_string filename22(argv[23]);
  STD_string filename23(argv[24]);
  STD_string filename24(argv[25]);
  STD_string filename25(argv[26]);
  STD_string filename26(argv[27]);
  STD_string filename27(argv[28]);
  STD_string filename28(argv[29]);
  STD_string filename29(argv[30]);
  STD_string filename30(argv[31]);
  STD_string filename31(argv[32]);
  float cutoff(atoi(argv[33]));

  Range all=Range::all();
 
   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";

  Data<float,4> file0;
  file0.autoread(filename0, FileReadOpts(), &prot);
  int nrep= file0.extent(firstDim);
  int sizeSlice=file0.extent(secondDim);
  int sizePhase=file0.extent(thirdDim);
  int sizeRead=file0.extent(fourthDim);

  Data<float,4> file1;
  file1.autoread(filename1);
  Data<float,4> file2;
  file2.autoread(filename2);
  Data<float,4> file3;
  file3.autoread(filename3);
  Data<float,4> file4;
  file4.autoread(filename4);
  Data<float,4> file5;
  file5.autoread(filename5);
  Data<float,4> file6;
  file6.autoread(filename6);
  Data<float,4> file7;
  file7.autoread(filename7);
  Data<float,4> file8;
  file8.autoread(filename8);
  Data<float,4> file9;
  file9.autoread(filename9);
  Data<float,4> file10;
  file10.autoread(filename10);
  Data<float,4> file11;
  file11.autoread(filename11);
  Data<float,4> file12;
  file12.autoread(filename12);
  Data<float,4> file13;
  file13.autoread(filename13);
  Data<float,4> file14;
  file14.autoread(filename14);
  Data<float,4> file15;
  file15.autoread(filename15);
  Data<float,4> file16;
  file16.autoread(filename16);
  Data<float,4> file17;
  file17.autoread(filename17);
  Data<float,4> file18;
  file18.autoread(filename18);
  Data<float,4> file19;
  file19.autoread(filename19);
  Data<float,4> file20;
  file20.autoread(filename20);
  Data<float,4> file21;
  file21.autoread(filename21);
  Data<float,4> file22;
  file22.autoread(filename22);
  Data<float,4> file23;
  file23.autoread(filename23);
  Data<float,4> file24;
  file24.autoread(filename24);
  Data<float,4> file25;
  file25.autoread(filename25);
  Data<float,4> file26;
  file26.autoread(filename26);
  Data<float,4> file27;
  file27.autoread(filename27);
  Data<float,4> file28;
  file28.autoread(filename28);
  Data<float,4> file29;
  file29.autoread(filename29);
  Data<float,4> file30;
  file30.autoread(filename30);
  Data<float,4> file31;
  file31.autoread(filename31);


  Data<float,4> Combined;
  Combined.resize(nrep,sizeSlice,sizePhase,sizeRead);
  Combined=0.0;

  Data<float,5> bigbigdata;
  bigbigdata.resize(N_coils,nrep,sizeSlice,sizePhase,sizeRead);
  bigbigdata=0.0;

  Data<float,4> My_SIEMENS_SOS;
  My_SIEMENS_SOS.resize(nrep,sizeSlice,sizePhase,sizeRead);
  My_SIEMENS_SOS=0.0;

  Data<float,4> tSNRMy_SIEMENS_SOS;
  tSNRMy_SIEMENS_SOS.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNRMy_SIEMENS_SOS=0.0;

  Data<float,4> weightedtSNRCombined;
  weightedtSNRCombined.resize(nrep,sizeSlice,sizePhase,sizeRead);
  weightedtSNRCombined=0.0;

  Data<float,4> tSNRweightedtSNRCombined;
  tSNRweightedtSNRCombined.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNRweightedtSNRCombined=0.0;

  Data<float,4> tSNR_coil;
  tSNR_coil.resize(N_coils,sizeSlice,sizePhase,sizeRead);
  tSNR_coil=0.0;

  Data<float,4> coil_weightings;
  coil_weightings.resize(N_coils,sizeSlice,sizePhase,sizeRead);
  coil_weightings=0.0;

  Data<float,4> finalcoil_weightings;
  finalcoil_weightings.resize(N_coils,sizeSlice,sizePhase,sizeRead);
  finalcoil_weightings=0.0;

  Data<float,4> additional_weighting;
  additional_weighting.resize(N_coils,sizeSlice,sizePhase,sizeRead);
  additional_weighting=0.0;

  Data<float,4> weightedOptiCombined;
  weightedOptiCombined.resize(nrep,sizeSlice,sizePhase,sizeRead);
  weightedOptiCombined=0.0;

  Data<float,4> tSNRweightedOptiCombined;
  tSNRweightedOptiCombined.resize(1,sizeSlice,sizePhase,sizeRead);
  tSNRweightedOptiCombined=0.0;

  Data<float,4> meanOpt;
  meanOpt.resize(1,sizeSlice,sizePhase,sizeRead);
  meanOpt=0.0;

  Data<float,4> meanSiemens_SOS;
  meanSiemens_SOS.resize(1,sizeSlice,sizePhase,sizeRead);
  meanSiemens_SOS=0.0;

int N_ = nrep/2 ;
cout << " N_ =  " << N_ << "  first time step  " << 1/2 << endl;  
double vec1_n[N_]  ;
double vec2_n[N_]  ;

float FFTscalefactors[N_coils] = {23.9457649485, 53.2818365217, 65.2660363636, 65.6313250909, 20.9210816529, 34.332672, 48.7164759494, 103.0172054795, 119.7419749254, 54.3412489209, 6.8593720035, 5.0699839351, 68.8467536842, 36.9015466667, 9.4550725504, 6.3083598501, 75.0222469565, 33.6575210467, 14.6864256833, 5.9117536573, 48.5321386667, 51.1762369466, 35.5696411173, 13.8395867919, 9.8875760252, 15.0863949834, 34.6513586087, 60.5100972973, 3.8417457951, 3.2676104004, 30.3460173913, 38.6274057722} ; 
//FFTscalefactors[] = {1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., } ; // in case it is not necessary to re_scale

cout << " Done reading  " << endl; 

cout << " putting data together in one big file  " << endl;
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		// right Cortex
		bigbigdata(0,timestep,islice,iy,ix)  =    file0(timestep,islice,iy,ix)     ;
		bigbigdata(1,timestep,islice,iy,ix)  =    file1(timestep,islice,iy,ix)     ;
		bigbigdata(2,timestep,islice,iy,ix)  =    file2(timestep,islice,iy,ix)     ;
		bigbigdata(3,timestep,islice,iy,ix)  =    file3(timestep,islice,iy,ix)     ;
		bigbigdata(4,timestep,islice,iy,ix)  =    file4(timestep,islice,iy,ix)     ;
		bigbigdata(5,timestep,islice,iy,ix)  =    file5(timestep,islice,iy,ix)     ;
		bigbigdata(6,timestep,islice,iy,ix)  =    file6(timestep,islice,iy,ix)     ;
		bigbigdata(7,timestep,islice,iy,ix)  =    file7(timestep,islice,iy,ix)     ;
		bigbigdata(8,timestep,islice,iy,ix)  =    file8(timestep,islice,iy,ix)     ;
		bigbigdata(9,timestep,islice,iy,ix)  =    file9(timestep,islice,iy,ix)     ;
		bigbigdata(10,timestep,islice,iy,ix) =    file10(timestep,islice,iy,ix)    ;
		bigbigdata(11,timestep,islice,iy,ix) =    file11(timestep,islice,iy,ix)    ;
		bigbigdata(12,timestep,islice,iy,ix) =    file12(timestep,islice,iy,ix)    ;
		bigbigdata(13,timestep,islice,iy,ix) =    file13(timestep,islice,iy,ix)    ;
		bigbigdata(14,timestep,islice,iy,ix) =    file14(timestep,islice,iy,ix)    ;
		bigbigdata(15,timestep,islice,iy,ix) =    file15(timestep,islice,iy,ix)    ;
		bigbigdata(16,timestep,islice,iy,ix) =    file16(timestep,islice,iy,ix)    ;
		bigbigdata(17,timestep,islice,iy,ix) =    file17(timestep,islice,iy,ix)    ;
		bigbigdata(18,timestep,islice,iy,ix) =    file18(timestep,islice,iy,ix)    ;
		bigbigdata(19,timestep,islice,iy,ix) =    file19(timestep,islice,iy,ix)    ;
		bigbigdata(20,timestep,islice,iy,ix) =    file20(timestep,islice,iy,ix)    ;
		bigbigdata(21,timestep,islice,iy,ix) =    file21(timestep,islice,iy,ix)    ;
		bigbigdata(22,timestep,islice,iy,ix) =    file22(timestep,islice,iy,ix)    ;
		bigbigdata(23,timestep,islice,iy,ix) =    file23(timestep,islice,iy,ix)    ;
		bigbigdata(24,timestep,islice,iy,ix) =    file24(timestep,islice,iy,ix)    ;
		bigbigdata(25,timestep,islice,iy,ix) =    file25(timestep,islice,iy,ix)    ;
		bigbigdata(26,timestep,islice,iy,ix) =    file26(timestep,islice,iy,ix)    ;
		bigbigdata(27,timestep,islice,iy,ix) =    file27(timestep,islice,iy,ix)    ;
		bigbigdata(28,timestep,islice,iy,ix) =    file28(timestep,islice,iy,ix)    ;
		bigbigdata(29,timestep,islice,iy,ix) =    file29(timestep,islice,iy,ix)    ;
		bigbigdata(30,timestep,islice,iy,ix) =    file30(timestep,islice,iy,ix)    ;
		bigbigdata(31,timestep,islice,iy,ix) =    file31(timestep,islice,iy,ix)    ;
	}
      }
    }
  }

cout << " normalycing with FFT scale factors " << endl;
 for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		bigbigdata(icoilelement,timestep,islice,iy,ix) = bigbigdata(icoilelement,timestep,islice,iy,ix) / FFTscalefactors[icoilelement];
	}
      }
    }
  }
 }

cout << " calculating SIEMENS SOS " << endl ;
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
		My_SIEMENS_SOS(timestep,islice,iy,ix) = My_SIEMENS_SOS(timestep,islice,iy,ix) + bigbigdata(icoilelement,timestep,islice,iy,ix)*bigbigdata(icoilelement,timestep,islice,iy,ix) ;
	     }
		My_SIEMENS_SOS(timestep,islice,iy,ix) = sqrt(My_SIEMENS_SOS(timestep,islice,iy,ix) ); 
	}
      }
    }
  }

cout << " and corresponding tSNR map " << endl ;
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int timestep=null_init; timestep<nrep; timestep = timestep + 2) {     // ----------> HIER einstellen, ob genullt oder nicht <------------
		vec1_n[timestep/2] = My_SIEMENS_SOS(timestep,islice,iy,ix) ; 
	     }
	     tSNRMy_SIEMENS_SOS(0,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_)/ gsl_stats_sd_m(vec1_n, 1, N_,  gsl_stats_mean (vec1_n, 1, N_));
	     meanSiemens_SOS(0,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_);
	}
      }
    }
 
cout << " get Coil tSNR MAPs ..."  ;
    for(int icoilelement=0; icoilelement<N_coils; ++icoilelement){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	   for(int islice=0; islice<sizeSlice; ++islice){
	     for(int timestep=null_init; timestep<nrep; timestep = timestep + 2) {     // ----------> HIER einstellen, ob genullt oder nicht <------------
		vec1_n[timestep/2] = bigbigdata(icoilelement,timestep,islice,iy,ix); 
	     }
	     tSNR_coil(icoilelement,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_)/ gsl_stats_sd_m(vec1_n, 1, N_,  gsl_stats_mean (vec1_n, 1, N_));
	   }
	}
      }
     cout << icoilelement << " " ;
    }
cout << " " << endl ;




cout << " get coil weightings based on tSNR " << endl ;
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
		coil_weightings(icoilelement,islice,iy,ix) = tSNR_coil(icoilelement,islice,iy,ix)/tSNRMy_SIEMENS_SOS(0,islice,iy,ix) ; 
 	     }
	}
      }
    }

cout << " calculating tSNR weighted combined time series " << endl ;
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
		weightedtSNRCombined(timestep,islice,iy,ix) = weightedtSNRCombined(timestep,islice,iy,ix) + bigbigdata(icoilelement,timestep,islice,iy,ix)*coil_weightings(icoilelement,islice,iy,ix) ;
	     }
	}
      }
    }
  }

cout << " and corresponding tSNR map " << endl ;
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int timestep=null_init; timestep<nrep; timestep = timestep + 2) {     // ----------> HIER einstellen, ob genullt oder nicht <------------
		vec1_n[timestep/2] = weightedtSNRCombined(timestep,islice,iy,ix) ; 
	     }     
 	     tSNRweightedtSNRCombined(0,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_)/ gsl_stats_sd_m(vec1_n, 1, N_,  gsl_stats_mean (vec1_n, 1, N_));
	}
      }
    }




cout << "#############################################" << endl ;
cout << "########## May the crazy stuff begin ########" << endl ;
cout << "########## This may take a while     ########" << endl ;
cout << "#############################################" << endl << endl ;

float tSNR_i = 0.; 
float tSNR_max = 0.;
float wieghting_fact[N_coils] ; 
for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
	wieghting_fact[icoilelement] = 1.; 
}

int number_of_weighting_factors = 14; 
float weigting_factor_array[number_of_weighting_factors] = {-2.2,  -1., -0.5, -0.25, 0., 0.25, 0.5, 0.75, 0.9, 0.95, 1., 1.2, 1.25,  4. };
//float weightingfactor_stepsize = 0.1 ;
//float max_weightingfactor = 1.4 ;
//float min_weightingfactor = 0.6 ; //  could be negative in case of too strong coupling
float best_weightingfactor = 0. ;
int number_of_iterations = 8;  // originally 8  

 clock_t t1,t2;
    t1=clock();
	float diff = 0.  ; 
	float minutes_ = 0.  ; 
	int count_timing = 0 ; 

for (int iteration = 0 ; iteration <  number_of_iterations ; ++iteration ){

  cout << "########## itteration " << iteration << " of " << number_of_iterations << "  ########" << endl ;

   
     for(int islice=0; islice<sizeSlice; ++islice){
      cout  <<  " slice  "<< islice << " of " << sizeSlice  <<  endl;
      for(int iy=0; iy<sizePhase; ++iy){ 
        //cout << " slice  "<< islice  << "   " << (float)iy/(float)sizePhase << " "  << endl ; 

	
        for(int ix=0; ix<sizeRead; ++ix){
	    for(int icoilelementtoopt=0; icoilelementtoopt<N_coils; ++icoilelementtoopt) {
		 // optimication loop
		tSNR_max = 0.;
		best_weightingfactor = 0.;
		 for(int i_ofweitingfactg = 0 ; i_ofweitingfactg < number_of_weighting_factors ; ++i_ofweitingfactg ) {
			 
			 wieghting_fact[icoilelementtoopt] = weigting_factor_array[i_ofweitingfactg] ; 

			   for(int timestep=null_init; timestep<nrep; timestep = timestep + 2) { // ----------> HIER einstellen, ob genullt oder nicht <------------
			     vec1_n[timestep/2] = 0.; 
			     for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
				vec1_n[timestep/2] = vec1_n[timestep/2] + bigbigdata(icoilelement,timestep,islice,iy,ix) * wieghting_fact[icoilelement] * coil_weightings(icoilelement,islice,iy,ix) ;
			     }
			   }
			   tSNR_i = gsl_stats_mean (vec1_n, 1, N_)/ gsl_stats_sd_m(vec1_n, 1, N_,  gsl_stats_mean (vec1_n, 1, N_));

//cout << "i_wieghting_fact = "<< i_wieghting_fact << " tSNR = " << tSNR_i << " vector "  <<  vec1_n[0] << "    " << vec1_n[10] <<  endl; 

			   if ( tSNR_i > tSNR_max ) {
				tSNR_max = tSNR_i ;
				best_weightingfactor = wieghting_fact[icoilelementtoopt] ; 
			   }

		  }

		 wieghting_fact[icoilelementtoopt] = best_weightingfactor ; 
	         //coil_weightings(icoilelementtoopt,islice,iy,ix) = coil_weightings(icoilelementtoopt,islice,iy,ix) * wieghting_fact[icoilelementtoopt] ; 
		 additional_weighting(icoilelementtoopt,islice,iy,ix) = best_weightingfactor ; 
 // cout << "best tSNR is  = "<< tSNR_max << " with  weigting of  = " <<  additional_weighting(icoilelementtoopt,islice,iy,ix) << " for element  " << icoilelementtoopt << endl;
 	   }
	    for(int icoilelementtoopt=0; icoilelementtoopt<N_coils; ++icoilelementtoopt) {
	    	wieghting_fact[icoilelementtoopt] = 1. ; 
	    }
	}




		t2=clock();
		 diff =  ((float)t2-(float)t1);
    		 minutes_ = diff / CLOCKS_PER_SEC / 60. ;
		count_timing++; 
		cout<< " it took already   " << minutes_    <<  " min or " << minutes_  /60. <<" hours, which are " << (float)count_timing/ (float)(sizeSlice*sizePhase*number_of_iterations )*100. 	<< "% ... There are " << (float)(sizeSlice*sizePhase*number_of_iterations -count_timing)/(float)count_timing *  minutes_  <<  " min or " << (float)(sizeSlice*sizePhase*number_of_iterations -count_timing)/(float)count_timing * minutes_  /60.    << " hours until it is finished " <<endl;	


      }// slice loop closed
    }
  

  for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
      for(int islice=0; islice<sizeSlice; ++islice){
        for(int iy=0; iy<sizePhase; ++iy){
          for(int ix=0; ix<sizeRead; ++ix){     
		coil_weightings(icoilelement,islice,iy,ix) = coil_weightings(icoilelement,islice,iy,ix) * additional_weighting(icoilelement,islice,iy,ix)  ;   
		//finalcoil_weightings(icoilelement,islice,iy,ix) = additional_weighting(icoilelement,islice,iy,ix)  ;
	  }
        }
      }
   //wieghting_fact[icoilelement] = 1.;
  }
}//itteration loo closed


cout << " calculating optimized weighted combined time series " << endl ;
  for(int timestep=0; timestep<nrep; timestep = timestep + 1) {
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int icoilelement=0; icoilelement<N_coils; ++icoilelement) {
		weightedOptiCombined(timestep,islice,iy,ix) = weightedOptiCombined(timestep,islice,iy,ix) + bigbigdata(icoilelement,timestep,islice,iy,ix) * coil_weightings(icoilelement,islice,iy,ix) ;
	     }
	}
      }
    }
  }




cout << " and corresponding tSNR map " << endl ;
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int timestep=null_init; timestep<nrep; timestep = timestep + 2) {     
		vec1_n[timestep/2] = weightedOptiCombined(timestep,islice,iy,ix) ; // ----------> HIER einstellen, ob genullt oder nicht <------------
	     }     
 	     tSNRweightedOptiCombined(0,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_)/ gsl_stats_sd_m(vec1_n, 1, N_,  gsl_stats_mean (vec1_n, 1, N_));
	     meanOpt(0,islice,iy,ix) =  gsl_stats_mean (vec1_n, 1, N_);
	}
      }
    }

cout << " sclaling the timeseries back for proper motion correction perfomance later " << endl ;
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
	     for(int timestep=0; timestep<nrep; ++timestep) {     
		weightedOptiCombined(timestep,islice,iy,ix) = weightedOptiCombined(timestep,islice,iy,ix) *meanSiemens_SOS(0,islice,iy,ix)  / meanOpt(0,islice,iy,ix) ; 
	     }     
	}
      }
    }





cout << " writing stuff out now " << endl; 

 // bigbigdata.autowrite("bigbigdata_"+filename1, wopts, &prot);
  My_SIEMENS_SOS.autowrite("My_SIEMENS_SOS_"+filename1, wopts, &prot);
  tSNRMy_SIEMENS_SOS.autowrite("tSNR_My_SIEMENS_SOS_"+filename1, wopts, &prot);
  tSNR_coil.autowrite("tSNR_from_Coils_"+filename1, wopts, &prot);
  tSNRweightedtSNRCombined.autowrite("tSNR_from_tSNR_comined_image"+filename1, wopts, &prot);
  weightedtSNRCombined.autowrite("Weighted_tSNR_comined_image"+filename1, wopts, &prot);
  additional_weighting.autowrite("additional_weighting"+filename1, wopts, &prot);
  weightedOptiCombined.autowrite("WeightedOptiCombined_"+filename1, wopts, &prot);
  tSNRweightedOptiCombined.autowrite("tSNR_WeightedOptiCombined_"+filename1, wopts, &prot);
  coil_weightings.autowrite("optimaced_weigtings_that_are_used_at_the_end.nii", wopts, &prot);
  finalcoil_weightings.autowrite("optimaced_finalweigtingchanges.nii", wopts, &prot);

cout << " bis hier4 " << endl; 

  return 0;

}
