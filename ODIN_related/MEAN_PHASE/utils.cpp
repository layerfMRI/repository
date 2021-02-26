#include <odindata/complexdata.h>
#include <odindata/fileio.h>
//#include <odindata/smooth.h>

#include "utils.hpp"

  Range all=Range::all();

void Status_information( STD_string stext, int counter ){
  std::cout << " " << std::endl;
  std::cout << itos(counter) << ". " << stext << "!" << std::endl;
  std::cout << "\a" << std::endl;
  return;
} 

void Siemens_phase_calc( Data<float,4> &phase ) {
  Range all=Range::all();
  phase(all,all,all,all)=PII/4096.0*phase(all,all,all,all);
  return;
}


void Siemens_phase_calc( Data<float,5> &phase ) {
  Range all=Range::all();
  phase(all,all,all,all,all)=PII/4096.0*phase(all,all,all,all,all);
  return;
}


void  Siemens_phase_calc_ret( Data<float,4> &phase ) {
  Range all=Range::all();
  phase(all,all,all,all)= 1.0/(PII/4096.0)*phase(all,all,all,all);
  return;
}


void  Siemens_phase_calc_ret( Data<float,5> &phase ) {
  Range all=Range::all();
  phase(all,all,all,all,all)=1.0/(PII/4096.0)*phase(all,all,all,all,all);
  return;
}

void Check_Phase_for_Siemens_phase_do_Appropriate( Data<float,4> &phase ) {
  Range all=Range::all();
  float maximum_phase_value = 0.0;
  maximum_phase_value = max( phase(all,all,all,all) );
  // if maximum phase value larger than PII, do Siemens phase, else nothing
  if( maximum_phase_value > PII*1.01 ){ Siemens_phase_calc( phase );}
  return;
}
  
void Check_Phase_for_Siemens_phase_do_Appropriate( Data<float,5> &phase ) {
  Range all=Range::all();
  float maximum_phase_value = 0.0;
  maximum_phase_value = max( phase(all,all,all,all,all) );
  // if maximum phase value larger than PII, do Siemens phase, else nothing
  if( maximum_phase_value > PII*1.01 ){ Siemens_phase_calc( phase );}
  return;
}

void Fill_repetitions_with_First( Data<float,4> &data ) {
  Range all=Range::all();
  TinyVector<int,4> data_size = data.shape();
  for(int irep=1; irep<data_size(0); irep++) {
    data(irep,all,all,all) = data(0,all,all,all);
  }
  return;
}


void Create_complex_data( ComplexData<5> &complex_data, const Data<float,5> &complete_mag, const Data<float,5> &complete_phase ){
  TinyVector<int,5> complex_data_size = complex_data.shape();
  for(int icoil=0; icoil<complex_data_size(0); icoil++) {
    for(int irep=0; irep<complex_data_size(1); irep++) {
      for(int islice=0; islice<complex_data_size(2); islice++) {
        for(int iy=0; iy<complex_data_size(3); iy++) {
          for(int ix=0; ix<complex_data_size(4); ix++) {
            complex_data(icoil,irep,islice,iy,ix)=STD_complex(complete_mag(icoil,irep,islice,iy,ix)*cos(complete_phase(icoil,irep,islice,iy,ix)),                                                complete_mag(icoil,irep,islice,iy,ix)*sin(complete_phase(icoil,irep,islice,iy,ix)));
          }
        }
      }
    }
  }
  return;
}

// 120323 this was when fat and water was imaged in seperate repetitions
// splits the dataset containing water and reference images into 2 separate files
void Split_complex_data( const ComplexData<5> &complex_data, ComplexData<5> &complex_water_data, ComplexData<5> &complex_ref_data ){
  // shape of the separated data files
  TinyVector<int,5> complex_data_size = complex_water_data.shape();
  for(int icoil=0; icoil<complex_data_size(0); icoil++) {
    for(int irep=0; irep<complex_data_size(1); irep++) {
      for(int islice=0; islice<complex_data_size(2); islice++) {
        for(int iy=0; iy<complex_data_size(3); iy++) {
          for(int ix=0; ix<complex_data_size(4); ix++) {
            complex_water_data(icoil,irep,islice,iy,ix) = complex_data(icoil,2*irep,islice,iy,ix);
            complex_ref_data(icoil,irep,islice,iy,ix) = complex_data(icoil,2*irep+1,islice,iy,ix);
          }
        }
      }
    }
  }
  return;
}


void Create_reference_data( ComplexData<5> &reference_data, ComplexData<5> &complex_data, int nreferences ){
  TinyVector<int,5> reference_data_size = reference_data.shape();
  for(int icoil=0; icoil<reference_data_size(0); icoil++) {
    for(int irep=0; irep<nreferences; irep++) {
      for(int islice=0; islice<reference_data_size(2); islice++) {
        for(int iy=0; iy<reference_data_size(3); iy++) {
          for(int ix=0; ix<reference_data_size(4); ix++) {
            reference_data(icoil,0,islice,iy,ix)=reference_data(icoil,0,islice,iy,ix)+complex_data(icoil,irep,islice,iy,ix);
          }
        }
      }
    }
  }
 return;
}

// complex division to practically subtract the phase
void Complex_div_for_phase_sub( ComplexData<5> &difference_data, ComplexData<5> &complex_data, ComplexData<5> &reference_data ){
  TinyVector<int,5> difference_data_size = difference_data.shape();
  for(int icoil=0; icoil<difference_data_size(0); icoil++) {
    for(int irep=0; irep<difference_data_size(1); irep++) {
      for(int islice=0; islice<difference_data_size(2); islice++) {
        for(int iy=0; iy<difference_data_size(3); iy++) {
          for(int ix=0; ix<difference_data_size(4); ix++) {
            difference_data(icoil,irep,islice,iy,ix)=complex_data(icoil,irep,islice,iy,ix)/reference_data(icoil,0,islice,iy,ix)
                *abs(reference_data(icoil,0,islice,iy,ix));
          }
        }
      }
    }
  }
  return;
}

// write absolute value into real part and set imaginary part to zero
void Complex_to_Real_Imag_to_Zero( ComplexData<5> &complex_data ){
  TinyVector<int,5> data_size = complex_data.shape();
  for(int icoil=0; icoil<data_size(0); icoil++) {
    for(int irep=0; irep<data_size(1); irep++) {
      for(int islice=0; islice<data_size(2); islice++) {
        for(int iy=0; iy<data_size(3); iy++) {
          for(int ix=0; ix<data_size(4); ix++) {
            complex_data(icoil,irep,islice,iy,ix)=STD_complex(abs(complex_data(icoil,irep,islice,iy,ix)),0.0);
          }
        }
      }
    }
  }
  return;
}

void Phase_unwrapping( ComplexData<5> &difference_data, Data<float,5> &phase_unwrapping_data ){
  float phase_cutoff_value = 2.0;
  float phase_difference;
  TinyVector<int,5> difference_data_size = difference_data.shape();
  for(int icoil=0; icoil<difference_data_size(0); icoil++) {
    for(int irep=1; irep<difference_data_size(1); irep++) { // start from the second repetition
      for(int islice=0; islice<difference_data_size(2); islice++) {
        for(int iy=0; iy<difference_data_size(3); iy++) {
          for(int ix=0; ix<difference_data_size(4); ix++) {
            phase_difference = phase(difference_data(icoil,irep,islice,iy,ix) / difference_data(icoil,irep-1,islice,iy,ix))-phase_unwrapping_data(icoil,irep-1,islice,iy,ix);// complex subtraction by division
            while( (phase_difference > PII) || (phase_difference < -PII) ){
              if( phase_difference > PII ){ phase_difference -= 2*PII;}
              else if( phase_difference < -PII ){ phase_difference += 2*PII;}
              else{ std::cout << "\n ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR \n" << std::endl;}
            }
            if( phase_difference > phase_cutoff_value ){ 
              phase_unwrapping_data(icoil,irep,islice,iy,ix) = phase_unwrapping_data(icoil,irep-1,islice,iy,ix) - 2*PII;
            }else if( phase_difference < -phase_cutoff_value ){
              phase_unwrapping_data(icoil,irep,islice,iy,ix) = phase_unwrapping_data(icoil,irep-1,islice,iy,ix) + 2*PII;
            }else{
              phase_unwrapping_data(icoil,irep,islice,iy,ix) = phase_unwrapping_data(icoil,irep-1,islice,iy,ix);
            }
          }
        }
      }
    }
  }
  return;
}


int Check_for_not_a_number( Data<float,4> &difference_data_one_coil ){
  TinyVector<int,4> difference_data_one_coil_size = difference_data_one_coil.shape();
  int icounter = 0;
  for(int irep=0; irep<difference_data_one_coil_size(0); irep++) {
    for(int islice=0; islice<difference_data_one_coil_size(1); islice++) {
      for(int iy=0; iy<difference_data_one_coil_size(2); iy++) {
        for(int ix=0; ix<difference_data_one_coil_size(3); ix++) {
          if (isnan(difference_data_one_coil(irep,islice,iy,ix))) {
            difference_data_one_coil(irep,islice,iy,ix)=0.0;
            ++icounter;
          }
        }
      }
    }
  }
  return icounter;
}



void Combine_complex_data( ComplexData<4> &combined_diff_data, ComplexData<5> &difference_data, float fcoil_weighting ){
  TinyVector<int,5> difference_data_size = difference_data.shape();
  fcoil_weighting -= 1.0;
  for(int icoil=0; icoil<difference_data_size(0); icoil++) {
    for(int irep=0; irep<difference_data_size(1); irep++) {
      for(int islice=0; islice<difference_data_size(2); islice++) {
        for(int iy=0; iy<difference_data_size(3); iy++) {
          for(int ix=0; ix<difference_data_size(4); ix++) {
            combined_diff_data(irep,islice,iy,ix) = combined_diff_data(irep,islice,iy,ix) + (difference_data(icoil,irep,islice,iy,ix) * pow(abs(difference_data(icoil,irep,islice,iy,ix)),fcoil_weighting));
          }
        }
      }
    }
  }
  // normalizing the data
  fcoil_weighting += 1.0;
  fcoil_weighting = 1.0/fcoil_weighting;
  for(int irep=0; irep<difference_data_size(1); irep++) {
    for(int islice=0; islice<difference_data_size(2); islice++) {
      for(int iy=0; iy<difference_data_size(3); iy++) {
        for(int ix=0; ix<difference_data_size(4); ix++) {
          combined_diff_data(irep,islice,iy,ix) = combined_diff_data(irep,islice,iy,ix) / pow(abs(combined_diff_data(irep,islice,iy,ix)),fcoil_weighting);
        }
      }
    }
  }
  return;
}

void Combine_phase_unwrapping_data( Data<float,4> &combined_phase_unwrapping_data, Data<float,5> &phase_unwrapping_data, Data<float,5> &complete_mag ){
  Range all=Range::all();
  TinyVector<int,5> complete_mag_size = complete_mag.shape();
  Data<float,4> max_mag(complete_mag_size(1),complete_mag_size(2),complete_mag_size(3),complete_mag_size(4));
  max_mag(all,all,all,all)=complete_mag(0,all,all,all,all);
  combined_phase_unwrapping_data(all,all,all,all)=phase_unwrapping_data(0,all,all,all,all);
  for(int icoil=1; icoil<complete_mag_size(0); icoil++) { // we only have to start from 1
    for(int irep=0; irep<complete_mag_size(1); irep++) {
      for(int islice=0; islice<complete_mag_size(2); islice++) {
        for(int iy=0; iy<complete_mag_size(3); iy++) {
          for(int ix=0; ix<complete_mag_size(4); ix++) {
            if( complete_mag(icoil,irep,islice,iy,ix) > max_mag(irep,islice,iy,ix) ){
              max_mag(irep,islice,iy,ix) = complete_mag(icoil,irep,islice,iy,ix);
              combined_phase_unwrapping_data(irep,islice,iy,ix) = phase_unwrapping_data(icoil,irep,islice,iy,ix);
            }
          }
        }
      }
    }
  }
  return;
}
  
  
  void Smooth_fft( ComplexData<4> &image, float smoothing_kernel, int dimension ){
    Range all=Range::all();
    
    int nrep=image.extent(firstDim);
    int nslice=image.extent(secondDim);
    int ny=image.extent(thirdDim);
    int nx=image.extent(fourthDim);
    
    // smoothing dimension
    // int dimension = 6;
   
    ///////////////// smoothing 4D ///////////////////////////////////////
    if (dimension==4) {
      ComplexData<4> result;
      result.resize(nrep,nslice,ny,nx);
      result(all,all,all,all)=image(all,all,all,all);
  
      unsigned int size=result.numElements();
  
      TinyVector<int,4> indices;
  
      result.fft(false);
  
      for(unsigned int i=0; i<size; i++) {
        indices=result.create_index(i);
        float normsqr=0.0;
        for(int j=0;j<dimension;j++) {
          float s=2.0*PII*float(indices(j)-result.extent(j)/2)/float(result.extent(j));
          normsqr+=s*s;
        }
        STD_complex factor=STD_complex(exp(-normsqr*smoothing_kernel*smoothing_kernel/8.0));
        result(indices)=result(indices)*factor;
      }
      result.fft(true);
      image(all,all,all,all)=result(all,all,all,all); 
    }
  
    ///////////////// smoothing 3D ///////////////////////////////////////
    if (dimension==3) {
      for(int irep=0; irep<nrep; irep++) {
        ComplexData<3> result;
        result.resize(nslice,ny,nx);
        result(all,all,all)=image(irep,all,all,all);
  
        unsigned int size=result.numElements();
  
        TinyVector<int,3> indices;
  
        result.fft(false);
  
        for(unsigned int i=0; i<size; i++) {
          indices=result.create_index(i);
          float normsqr=0.0;
          for(int j=0;j<dimension;j++) {
            float s=2.0*PII*float(indices(j)-result.extent(j)/2)/float(result.extent(j));
            normsqr+=s*s;
          }
          STD_complex factor=STD_complex(exp(-normsqr*smoothing_kernel*smoothing_kernel/8.0));
          result(indices)=result(indices)*factor;
        }
        result.fft(true);
        image(irep,all,all,all)=result(all,all,all); 
      }
    }
  
    ///////////////// smoothing 2D+time ///////////////////////////////////////
    if (dimension==5) {
      for(int islice=0; islice<nslice; islice++) {
        ComplexData<3> result;
        result.resize(nrep,ny,nx);
        result(all,all,all)=image(all,islice,all,all);
  
        unsigned int size=result.numElements();
  
        TinyVector<int,3> indices;
  
        result.fft(false);
  
        for(unsigned int i=0; i<size; i++) {
          indices=result.create_index(i);
          float normsqr=0.0;
          for(int j=0;j<3;j++) {
            float s=2.0*PII*float(indices(j)-result.extent(j)/2)/float(result.extent(j));
            normsqr+=s*s;
          }
          STD_complex factor=STD_complex(exp(-normsqr*smoothing_kernel*smoothing_kernel/8.0));
          result(indices)=result(indices)*factor;
        }
        result.fft(true);
        image(all,islice,all,all)=result(all,all,all); 
      }
    }
  
    if (dimension==2) {
      for(int irep=0; irep<nrep; irep++) {
        for(int islice=0; islice<nslice; islice++) {
          ComplexData<2> result;
          result.resize(ny,nx);
          result(all,all)=image(irep,islice,all,all);
  
          unsigned int size=result.numElements();
  
          TinyVector<int,2> indices;
  
          result.fft(false);
  
          for(unsigned int i=0; i<size; i++) {
            indices=result.create_index(i);
            float normsqr=0.0;
            for(int j=0;j<dimension;j++) {
              float s=2.0*PII*float(indices(j)-result.extent(j)/2)/float(result.extent(j));
              normsqr+=s*s;
            }
            STD_complex factor=STD_complex(exp(-normsqr*smoothing_kernel*smoothing_kernel/8.0));
            result(indices)=result(indices)*factor;
          }
          result.fft(true);
          image(irep,islice,all,all)=result(all,all); 
          // cout << "rep/slice " << irep << "/" << islice << " done" << endl;
        }
      }
    }
    
    if (dimension==6) { // smooth in time dimension
      for(int islice=0; islice<nslice; islice++) {
        for(int iy=0; iy<ny; iy++) {
          for(int ix=0; ix<nx; ix++) {
            ComplexData<1> result;
            result.resize(nrep);
            result(all)=image(all,islice,iy,ix);
      
            unsigned int size=result.numElements();
      
            TinyVector<int,1> indices;
      
            result.fft(false);
      
            for(unsigned int i=0; i<size; i++) {
              indices=result.create_index(i);
              float normsqr=0.0;
              for(int j=0;j<1;j++) {
                float s=2.0*PII*float(indices(j)-result.extent(j)/2)/float(result.extent(j));
                normsqr+=s*s;
              }
              STD_complex factor=STD_complex(exp(-normsqr*smoothing_kernel*smoothing_kernel/8.0));
              result(indices)=result(indices)*factor;
            }
            result.fft(true);
            image(all,islice,iy,ix)=result(all);
          }
        }
      }
    }
    
    return;
  }

  
  
  void Complex_to_Real_Imaginary( ComplexData<4> &complex_data, Data<float,4> &real_data, Data<float,4> &imaginary_data ){
    Range all=Range::all();
    real_data(all,all,all,all)=abs(complex_data(all,all,all,all))*cos(phase(complex_data(all,all,all,all)));
    imaginary_data(all,all,all,all)=abs(complex_data(all,all,all,all))*sin(phase(complex_data(all,all,all,all)));
    return;
  }

  void Real_Imaginary_to_Complex( ComplexData<4> &complex_data, Data<float,4> &real_data, Data<float,4> &imaginary_data ){
    Range all=Range::all();
    TinyVector<int,4> complex_data_size = complex_data.shape();
    for(int irep=0; irep<complex_data_size(0); irep++) {
      for(int islice=0; islice<complex_data_size(1); islice++) {
        for(int iy=0; iy<complex_data_size(2); iy++) {
          for(int ix=0; ix<complex_data_size(3); ix++) {
            complex_data(irep,islice,iy,ix) = STD_complex(real_data(irep,islice,iy,ix),imaginary_data(irep,islice,iy,ix));
          }
        }
      }
    }
    return;
  }
  

