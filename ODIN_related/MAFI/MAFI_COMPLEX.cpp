#include <odindata/data.h>
#include <odindata/complexdata.h>
#include <odindata/fileio.h>
#include <math.h>
#include <complex>
 
 
#define PI 3.14159265;

#include "utils.hpp"

void usage() { cout << "MAFI_COMPLEX <magnitude_file1>  <magnitude_file2> <magnitude_file3>  <magnitude_file4> <phase_file1> <phase_file2> <phase_file3> <phase_file4> <n=TR2/TR1> <desired angle (in deg)> <cutoff value mask> <dTE1> <dTE2>" << endl;}


int main(int argc,char* argv[]) {

  if (argc!=14) {usage(); return 0;}
  STD_string filename_mag1(argv[1]);
  STD_string filename_mag2(argv[2]);
  STD_string filename_mag3(argv[3]);
  STD_string filename_mag4(argv[4]);
  STD_string filename_phase1(argv[5]);
  STD_string filename_phase2(argv[6]);
  STD_string filename_phase3(argv[7]);
  STD_string filename_phase4(argv[8]);
  float TR_ratio(atof(argv[9]));
  float desired_angle(atof(argv[10]));
  int cutoff_value(atoi(argv[11]));
  float dTE1(atof(argv[12]));
  float dTE2(atof(argv[13]));

  Range all=Range::all();

   Protocol prot;
   FileReadOpts ropts;
   FileWriteOpts wopts;
   wopts.datatype="float";
  
  // angle range around the 0 angle that is still acceptable that both Signals are positive
  float cut_off_angle = 90.0;

  Data<float,4> file_mag1;
  file_mag1.autoread(filename_mag1, FileReadOpts(), &prot);
  int nrep=file_mag1.extent(firstDim);
  int sizeSlice=file_mag1.extent(secondDim);
  int sizePhase=file_mag1.extent(thirdDim);
  int sizeRead=file_mag1.extent(fourthDim);

  Data<float,4> file_mag2;
  file_mag2.autoread(filename_mag2);

  Data<float,4> file_mag3;
  file_mag3.autoread(filename_mag3);

  Data<float,4> file_mag4;
  file_mag4.autoread(filename_mag4);

cout << " mag 1 " << file_mag1(0,15,15,15) << endl; 

cout << " cutoff  " << cutoff_value << endl; 
  
  // to fit to utils which also need a coil dimension
  Data<float,5> file_mag_5(1,4,sizeSlice,sizePhase,sizeRead);
 file_mag_5 =0.; 
  //file_mag_5(0,all,all,all,all)=file_mag(all,all,all,all);
  for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
	file_mag_5(0,0,islice,iy,ix) = file_mag1(0,islice,iy,ix);
	file_mag_5(0,1,islice,iy,ix) = file_mag2(0,islice,iy,ix);
	file_mag_5(0,2,islice,iy,ix) = file_mag3(0,islice,iy,ix);
	file_mag_5(0,3,islice,iy,ix) = file_mag4(0,islice,iy,ix);


	//cout << " mag 1 " << file_mag_5(0,0,islice,iy,ix) << endl; 
	//cout << " mag 2 " << file_mag_5(0,1,islice,iy,ix) << endl; 
      }
    }
  }



  
  Data<float,4> file_phase1;
  file_phase1.autoread(filename_phase1);

  Data<float,4> file_phase2;
  file_phase2.autoread(filename_phase2);

  Data<float,4> file_phase3;
  file_phase3.autoread(filename_phase3);

  Data<float,4> file_phase4;
  file_phase4.autoread(filename_phase4);
  
/*
  if( file_phase.extent(firstDim) != nrep ){
    std::cout << " The phase and magnitude have different # of repetitions " << std::endl; return 0;
  }
  if( file_phase.extent(secondDim) != sizeSlice ){
    std::cout << " The phase and magnitude have different # of slicess " << std::endl; return 0;
  }
  if( file_phase.extent(thirdDim) != sizePhase ){
    std::cout << " The phase and magnitude have a different y-dimension " << std::endl; return 0;
  }
  if( file_phase.extent(fourthDim) != sizeRead ){
    std::cout << " The phase and magnitude have a different x-dimension " << std::endl; return 0;
  }
*/
  
  /**********************************************************************************/
  // siemens phase
  /**********************************************************************************/
    // to fit to utils which also need a coil dimension
  Data<float,5> file_phase_5(1,4,sizeSlice,sizePhase,sizeRead);
  //file_phase_5(0,all,all,all,all)=file_phase(all,all,all,all);
 file_phase_5 = 0.; 

  for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
	file_phase_5(0,0,islice,iy,ix) = file_phase1(0,islice,iy,ix);
	file_phase_5(0,1,islice,iy,ix) = file_phase2(0,islice,iy,ix);
	file_phase_5(0,2,islice,iy,ix) = file_phase3(0,islice,iy,ix);
	file_phase_5(0,3,islice,iy,ix) = file_phase4(0,islice,iy,ix);
	//cout << " pha 1 " << file_phase_5(0,0,islice,iy,ix) << endl; 
	//cout << " pha 2 " << file_phase_5(0,1,islice,iy,ix) << endl; 
      }
    }
  }

  
  Data<float,5> phase_siemens_5(1,4,sizeSlice,sizePhase,sizeRead);
  phase_siemens_5(all,all,all,all,all)=0.4;
  phase_siemens_5(all,all,all,all,all)=PII/4096.0*file_phase_5(all,all,all,all,all);

  
  /**********************************************************************************/
  // creates complex data
  /**********************************************************************************/
  // stores the magnitude and phase data of each coil as a complex number
  ComplexData<5> complex_data(1,4,sizeSlice,sizePhase,sizeRead);
  complex_data(all,all,all,all,all)=0.0;
  // creates the complex data and stores it in 'complex_data'
  //Create_complex_data( complex_data, file_mag_5, phase_siemens_5 );

 for (int echo = 0; echo < 4; ++echo) {
  for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
       
         complex_data(0,echo,islice,iy,ix)=complex<float> (file_mag_5(0,echo,islice,iy,ix) * cos( phase_siemens_5(0,echo,islice,iy,ix)), file_mag_5(0,echo,islice,iy,ix) * sin( phase_siemens_5(0,echo,islice,iy,ix)));
      } 
    }
  }
 }


cout <<  " mag " <<  file_mag_5(0,0,40,40,40) << endl;

cout <<  " phase " << phase_siemens_5(0,0,40,40,40) << endl;

cout <<  " complex " << complex_data(0,0,40,40,40) << endl;
  
  ComplexData<4> Sratio(3,sizeSlice,sizePhase,sizeRead);
  Sratio(all,all,all,all)=0.3;

  Data<float,4> acosratio;
  acosratio.resize(1,sizeSlice,sizePhase,sizeRead);
  acosratio=0.2;

  Data<float,4> angle;
  angle.resize(1,sizeSlice,sizePhase,sizeRead);
  angle=0.1;
  
  // complex ratio (small signal divided by larger signal)
  Sratio(0,all,all,all) = complex_data(0,1,all,all,all) / complex_data(0,0,all,all,all);
  Sratio(1,all,all,all) = complex_data(0,2,all,all,all) / complex_data(0,0,all,all,all);
  Sratio(2,all,all,all) = complex_data(0,3,all,all,all) / complex_data(0,2,all,all,all);

//B0 maps
  Data<float,4> B0;
  B0.resize(2,sizeSlice,sizePhase,sizeRead);
  B0=0.7;  
 
  B0(0,all,all,all) = phase(Sratio(1,all,all,all))*180.0/PI;
  B0(1,all,all,all) = phase(Sratio(2,all,all,all))*180.0/PI;

//in ppm umrechnen
  B0(0,all,all,all) = B0(0,all,all,all)/360./(dTE1*0.001);
  B0(1,all,all,all) = B0(1,all,all,all)/360./(dTE2*0.001);

  // multiplies the signal with a 1 if the angle is close to 0° and with -1 if the angle is close to 180°
  Data<float,4> complex_factor;
  complex_factor.resize(1,sizeSlice,sizePhase,sizeRead);
  complex_factor=1.0;


  float absolute_angle=0.0;
  
  // finds the the values of angle close to 180°
  for(int islice=0; islice<sizeSlice; ++islice){
    for(int iy=0; iy<sizePhase; ++iy){
      for(int ix=0; ix<sizeRead; ++ix){
        absolute_angle=phase(Sratio(0,islice,iy,ix))*180.0/PI;
        if( absolute_angle < 0 ){
          absolute_angle = -absolute_angle;
        }
        if( absolute_angle >= cut_off_angle ){
          complex_factor(0,islice,iy,ix)=-1.0;
        }
      } 
    }
  }
  
  acosratio(0,all,all,all) = (complex_factor(0,all,all,all)*abs(Sratio(0,all,all,all))*TR_ratio-1.0) / (TR_ratio-complex_factor(0,all,all,all)*abs(Sratio(0,all,all,all)));
  
  angle(0,all,all,all) = acos( acosratio(0,all,all,all) )  * 180.0 / PI;
  
 
  // replace nan by 0
  //angle=where(Array<float,4>(angle) == Array<float,4>(angle), Array<float,4>(angle), (float)0 );
  
  //angle.autowrite("C1_angle_"+filename_mag1);
  
  angle(0,all,all,all) /= desired_angle;

  Data<float,4> mask;
  mask.resize(1,sizeSlice,sizePhase,sizeRead);
  mask=0.0;
  
  Data<float,4> data;
  data.resize(1,sizeSlice,sizePhase,sizeRead);
  data=0.0;
  

    for(int islice=0; islice<sizeSlice; ++islice){
      for(int iy=0; iy<sizePhase; ++iy){
        for(int ix=0; ix<sizeRead; ++ix){
          if(file_mag1(0,islice,iy,ix)>=cutoff_value){
            mask(0,islice,iy,ix)=1;
            data(0,islice,iy,ix)=angle(0,islice,iy,ix);
          }
        }
      }
    }

  B0.autowrite("XB0_map.nii", wopts, &prot);
  data.autowrite("XB1_map.nii", wopts, &prot);
  file_mag_5.autowrite("test.nii", wopts, &prot);
  phase_siemens_5.autowrite("test1.nii", wopts, &prot);

  return 0;

}
