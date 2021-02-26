
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

  Data<float,5> bigbigdata;
  bigbigdata.resize(N_coils,nrep,sizeSlice,sizePhase,sizeRead);
  bigbigdata=0.0;


int N_ = nrep ;
cout << " N_ =  " << N_ << endl;  

//float FFTscalefactors[N_coils] = {23.9457649485, 53.2818365217, 65.2660363636, 65.6313250909, 20.9210816529, 34.332672, 48.7164759494, 103.0172054795, 119.7419749254, 54.3412489209, 6.8593720035, 5.0699839351, 68.8467536842, 36.9015466667, 9.4550725504, 6.3083598501, 75.0222469565, 33.6575210467, 14.6864256833, 5.9117536573, 48.5321386667, 51.1762369466, 35.5696411173, 13.8395867919, 9.8875760252, 15.0863949834, 34.6513586087, 60.5100972973, 3.8417457951, 3.2676104004, 30.3460173913, 38.6274057722} ; 
float FFTscalefactors[N_coils] = {1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., } ; // in case it is not necessary to re_scale

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


cout << "#############################################" << endl ;
cout << "########## Averaging over ebtire FOV ########" << endl ;
cout << "########## This may take a while     ########" << endl ;
cout << "#############################################" << endl << endl ;

double vec1_n[N_coils][nrep] ;
    for(int icoils=0; icoils<N_coils; ++icoils){
      for(int timestep=0; timestep<nrep; ++timestep){
	vec1_n[icoils][timestep] = 0.; 
      }
    }
 
double number_in_vol = (double)  sizeSlice * sizeSlice *  sizeRead ; 

cout << " befuelle vector indem ich ueber das ganze volumen mittle " << endl;
for(int timestep=0; timestep<nrep; ++timestep) {
  for(int icoils=0; icoils<N_coils; ++icoils){
    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
		vec1_n[icoils][timestep] = vec1_n[icoils][timestep] + bigbigdata(icoils,timestep,islice,iy,ix) / number_in_vol ;
	}
      }
    }
  }
}




cout << " berechne corss corelation  " << endl;
double cross_correl[N_coils][N_coils] ;
    for(int icoils=0; icoils<N_coils; ++icoils){
      for(int jcoils=0; jcoils<N_coils; ++jcoils){
	cross_correl[icoils][jcoils] =  gsl_stats_correlation (vec1_n[icoils],  1, vec1_n[jcoils] ,1, nrep) ; 
      }
    }


cout << " raus schreiben fuer gnuplot  " << endl;
    ofstream outf("coil_gnuplot.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }


	for(int i = 0; i< N_coils ; i++){
		for(int j = 0; j< N_coils ; j++){
			outf << 1*i << "  " << 1*j << "  " <<  cross_correl[i][j] <<  endl;
			outf << 1*i << "  " << 1*j+1 << "  " <<  cross_correl[i][j] <<  endl;
		}
		outf << endl; 
		for(int j = 0; j< N_coils ; j++){
			outf << 1*i+1  << "  " << 1*j << "  " <<  cross_correl[i][j] <<  endl;
			outf << 1*i+1  << "  " << 1*j+1 << "  " <<  cross_correl[i][j] <<  endl;
		}
		outf << endl; 
	}





  outf.close();

 // bigbigdata.autowrite("bigbigdata_"+filename1, wopts, &prot);





cout << " bis hier4 " << endl; 

  return 0;

}
