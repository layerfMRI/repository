// compile mit  g++ devel.cpp -o program

#include "filt.h"
#define ECODE(x) {m_error_flag = x; return;}

// Handles LPF and HPF case
Filter::Filter(filterType filt_t, int num_taps, double Fs, double Fx)
{
	m_error_flag = 0;
	m_filt_t = filt_t;
	m_num_taps = num_taps;
	m_Fs = Fs;
	m_Fx = Fx;
	m_lambda = M_PI * Fx / (Fs/2);

	if( Fs <= 0 ) ECODE(-1);
	if( Fx <= 0 || Fx >= Fs/2 ) ECODE(-2);
	if( m_num_taps <= 0 || m_num_taps > MAX_NUM_FILTER_TAPS ) ECODE(-3);

	m_taps = m_sr = NULL;
	m_taps = (double*)malloc( m_num_taps * sizeof(double) );
	m_sr = (double*)malloc( m_num_taps * sizeof(double) );
	if( m_taps == NULL || m_sr == NULL ) ECODE(-4);
	
	init();

	if( m_filt_t == LPF ) designLPF();
	else if( m_filt_t == HPF ) designHPF();
	else ECODE(-5);

	return;
}

// Handles BPF case
Filter::Filter(filterType filt_t, int num_taps, double Fs, double Fl,
               double Fu)
{
	m_error_flag = 0;
	m_filt_t = filt_t;
	m_num_taps = num_taps;
	m_Fs = Fs;
	m_Fx = Fl;
	m_Fu = Fu;
	m_lambda = M_PI * Fl / (Fs/2);
	m_phi = M_PI * Fu / (Fs/2);

	if( Fs <= 0 ) ECODE(-10);
	if( Fl >= Fu ) ECODE(-11);
	if( Fl <= 0 || Fl >= Fs/2 ) ECODE(-12);
	if( Fu <= 0 || Fu >= Fs/2 ) ECODE(-13);
	if( m_num_taps <= 0 || m_num_taps > MAX_NUM_FILTER_TAPS ) ECODE(-14);

	m_taps = m_sr = NULL;
	m_taps = (double*)malloc( m_num_taps * sizeof(double) );
	m_sr = (double*)malloc( m_num_taps * sizeof(double) );
	if( m_taps == NULL || m_sr == NULL ) ECODE(-15);
	
	init();

	if( m_filt_t == BPF ) designBPF();
	else ECODE(-16);

	return;
}

Filter::~Filter()
{
	if( m_taps != NULL ) free( m_taps );
	if( m_sr != NULL ) free( m_sr );
}

void 
Filter::designLPF()
{
	int n;
	double mm;

	for(n = 0; n < m_num_taps; n++){
		mm = n - (m_num_taps - 1.0) / 2.0;
		if( mm == 0.0 ) m_taps[n] = m_lambda / M_PI;
		else m_taps[n] = sin( mm * m_lambda ) / (mm * M_PI);
	}

	return;
}

void 
Filter::designHPF()
{
	int n;
	double mm;

	for(n = 0; n < m_num_taps; n++){
		mm = n - (m_num_taps - 1.0) / 2.0;
		if( mm == 0.0 ) m_taps[n] = 1.0 - m_lambda / M_PI;
		else m_taps[n] = -sin( mm * m_lambda ) / (mm * M_PI);
	}

	return;
}

void 
Filter::designBPF()
{
	int n;
	double mm;

	for(n = 0; n < m_num_taps; n++){
		mm = n - (m_num_taps - 1.0) / 2.0;
		if( mm == 0.0 ) m_taps[n] = (m_phi - m_lambda) / M_PI;
		else m_taps[n] = (   sin( mm * m_phi ) -
		                     sin( mm * m_lambda )   ) / (mm * M_PI);
	}

	return;
}

void 
Filter::get_taps( double *taps )
{
	int i;

	if( m_error_flag != 0 ) return;

	for(i = 0; i < m_num_taps; i++) taps[i] = m_taps[i];

  return;		
}

int 
Filter::write_taps_to_file( char *filename )
{
	FILE *fd;

	if( m_error_flag != 0 ) return -1;

	int i;
	fd = fopen(filename, "w");
	if( fd == NULL ) return -1;

	fprintf(fd, "%d\n", m_num_taps);
	for(i = 0; i < m_num_taps; i++){
		fprintf(fd, "%15.6f\n", m_taps[i]);
	}
	fclose(fd);

	return 0;
}

// Output the magnitude of the frequency response in dB
#define NP 1000
int 
Filter::write_freqres_to_file( char *filename )
{
	FILE *fd;
	int i, k;
	double w, dw;
	double y_r[NP], y_i[NP], y_mag[NP];
	double mag_max = -1;
	double tmp_d;

	if( m_error_flag != 0 ) return -1;

	dw = M_PI / (NP - 1.0);
	for(i = 0; i < NP; i++){
		w = i*dw;
		y_r[i] = y_i[i] = 0;
		for(k = 0; k < m_num_taps; k++){
			y_r[i] += m_taps[k] * cos(k * w);
			y_i[i] -= m_taps[k] * sin(k * w);
		}
	}

	for(i = 0; i < NP; i++){
		y_mag[i] = sqrt( y_r[i]*y_r[i] + y_i[i]*y_i[i] );
		if( y_mag[i] > mag_max ) mag_max = y_mag[i];
	}

	if( mag_max <= 0.0 ) return -2;

	fd = fopen(filename, "w");
	if( fd == NULL ) return -3;

	for(i = 0; i < NP; i++){
		w = i*dw;
		if( y_mag[i] == 0 ) tmp_d = -100;
		else{
			tmp_d = 20 * log10( y_mag[i] / mag_max );
			if( tmp_d < -100 ) tmp_d = -100;
		}
		fprintf(fd, "%10.6e %10.6e\n", w * (m_Fs/2)/M_PI, tmp_d);
	}

	fclose(fd);
	return 0;
}

void 
Filter::init()
{
	int i;

	if( m_error_flag != 0 ) return;

	for(i = 0; i < m_num_taps; i++) m_sr[i] = 0;

	return;
}

double 
Filter::do_sample(double data_sample)
{
	int i;
	double result;

	if( m_error_flag != 0 ) return(0);

	for(i = m_num_taps - 1; i >= 1; i--){
		m_sr[i] = m_sr[i-1];
	}	
	m_sr[0] = data_sample;

	result = 0;
	for(i = 0; i < m_num_taps; i++) result += m_sr[i] * m_taps[i];

	return result;
}
