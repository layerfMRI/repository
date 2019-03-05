// compile mit g++ devel.cpp -o program

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include "./filt.cpp"
#include <iostream>
#include <fstream>


#include "filt.h"
using namespace std;


int main(int argc, char *argv[])
{
	FILE *fd_in, *fd_out;
	Filter *my_filter;
	double samp_dat;
	double out_val;
	int num_read;
	char outfile1[80] = "taps.txt";
	char outfile2[80] = "freqres.txt";

	my_filter = new Filter(LPF, 51, 50, 20.0); // die 51 gibt irgendwie wie viele Datenpunke zum Filteern verwendet werden 
						    // die 44.1 gibt an wie die amplitude scaliert wird. 
						    // die letzte zalh gibt die cutoff frequenz an  (bis max 24)
	//my_filter = new Filter(HPF, 51, 44.1, 3.0);
	//my_filter = new Filter(BPF, 51, 44.1, 3.0, 6.0);

	fprintf(stderr, "error_flag = %d\n", my_filter->get_error_flag() );
	if( my_filter->get_error_flag() < 0 ) exit(1);
	my_filter->write_taps_to_file( outfile1 );
	my_filter->write_freqres_to_file( outfile2 );

	fd_in  = fopen("ISI2.txt", "r");
	//fd_out = fopen("filtered.raw", "w");
    
	ofstream outf;
	outf.open("renzo_out.txt");
	 
	
	ifstream infile0;
	infile0.open("ISI2.txt");
	if (!infile0 ) {
	cerr<<"Konnte die Datei nicht einlesen: "<<endl;
	return -1;
	} 
	
	double zahl = 0.; 
	int number = 0; 
	double M1[71179] ; 
	while (infile0>>zahl) {
	    M1[number] = zahl; 
	    number ++; 
	    //cout << " M1[" << zeile <<"]["<< time <<"] = " << number << endl; 
	    }
	cout << "number =  " << number << endl; 
	
	int N_ = 0;
	for(int i = 0; i < number ; i++) {
		//num_read = fread(&samp_dat, sizeof(short), 1, fd_in);
		//if(num_read != 1) break;
		//cout << "sampdata " << samp_dat << endl; 
		outf <<  M1[N_] << "   " ;
		out_val = my_filter->do_sample( (double) M1[N_] );
		samp_dat = (short) out_val;
		//cout << "out_val " << out_val << endl; 
		outf  << out_val << endl; 
		//fwrite(&samp_dat, sizeof(short), 1, fd_out);
		N_++ ; 
		//outf << samp_dat << endl; 
	}

	cout << " N  = " << N_ << endl; 
	
	fclose(fd_in);
	fclose(fd_out);
	delete my_filter;
}	
