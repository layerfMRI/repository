#ifndef UTILS_HPP
#define UTILS_HPP

void Status_information( STD_string stext, int counter );

void Siemens_phase_calc( Data<float,4> &phase );
void Siemens_phase_calc( Data<float,5> &phase );
void  Siemens_phase_calc_ret( Data<float,4> &phase );
void  Siemens_phase_calc_ret( Data<float,5> &phase );

void Fill_repetitions_with_First( Data<float,4> &data );

void Create_complex_data( ComplexData<5> &complex_data, const Data<float,5> &complete_mag, const Data<float,5> &complete_phase );

void Split_complex_data( const ComplexData<5> &complex_data, ComplexData<5> &complex_water_data, ComplexData<5> &complex_ref_data );

void Create_reference_data( ComplexData<5> &reference_data, ComplexData<5> &complex_data, int nreferences );

void Complex_div_for_phase_sub( ComplexData<5> &difference_data, ComplexData<5> &complex_data, ComplexData<5> &reference_data );

void Phase_unwrapping( ComplexData<5> &difference_data, Data<float,5> &phase_unwrapping_data );

int Check_for_not_a_number( Data<float,4> &difference_data_one_coil );

void Combine_complex_data( ComplexData<4> &combined_diff_data, ComplexData<5> &difference_data, float fcoil_weighting );

void Combine_phase_unwrapping_data( Data<float,4> &combined_phase_unwrapping_data, Data<float,5> &phase_unwrapping_data, Data<float,5> &complete_mag );

void Smooth_fft( ComplexData<4> &image, float smoothing_kernel );

void Complex_to_Real_Imaginary( ComplexData<4> &complex_data, Data<float,4> &real_data, Data<float,4> &imaginary_data );

void Real_Imaginary_to_Complex( ComplexData<4> &complex_data, Data<float,4> &real_data, Data<float,4> &imaginary_data );

#endif
