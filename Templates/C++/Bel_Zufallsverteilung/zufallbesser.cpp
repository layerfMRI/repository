#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
using namespace std;

int N = 1000;
double_t lower = -M_PI/2.;
double_t upper = M_PI/2.;


double verteilung(double x);

double fak(int x); // fur Binomial

typedef double (*Functions)(double);
Functions pFunc = verteilung;

double_t arb_pdf_num(int N, double (*pFunc)(double), double_t lower, double_t upper);

int amount_of_arb_pdf_num = 50000;

int main()
{
   //  in datei schreiben
    ofstream outf("data.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
  for (int i = 0; i < amount_of_arb_pdf_num ; i++) {
  	//	outf<<verteilung(i)<< endl;
        outf<< arb_pdf_num(N, pFunc, lower, upper) << endl;
  }
  outf.close();
   
   
   
   
return 0;
}


// Gauss     lower = -5 , upper = 5
//double verteilung(double z){
//    return exp(-z*z/(2.))*1./sqrt(2.*M_PI);
//}

// Maxwell   lower = 0, upper = 15
//double verteilung(double z){
//	double a = 1.;
//    return exp(-z*z/(2.*a*a))*(z*z)/(a*a*a)*sqrt(2./M_PI);
//}

//Binomial lower = 0, upper = 20
// Achtung !! Diskret
//double verteilung(double k){
//	double p = 0.5;
//	double n = 20.;
//	return pow(p, k) *pow(1.-p, n-k) * fak(n)/(fak(k)*fak(n-k))*0.10184; //normierung weil diskret
//	}

		double fak(int x){
		long int fakul = 1;
		for(int j = 1; j <= x ; j++){
			fakul = fakul * j;
			}
		return (double) fakul;
		}


//cos^2(x) lower = -M_PI/2, upper = M_PI/2
double verteilung(double x){
	return cos(x)*cos(x)*2./ M_PI;
	}


    
double_t arb_pdf_num(int N, double (*pFunc)(double), double_t lower, double_t upper){
	double_t binwidth = (upper - lower)/(double_t)N;
	double_t integral = 0.0 ;
	double_t rand_num = rand()/(double_t)RAND_MAX;
	int i;
	
	for (i = 0; integral < rand_num ; i++){
		integral += pFunc(lower + (double_t) i *binwidth)*binwidth ;
	
		if ((lower + (double_t) i*binwidth ) > upper ) {
		  cout << " upper limit, vielleicht sollte da limit angepasst werden "<< i << endl;
		 return lower + (double_t) i *binwidth ;
		}
	}
	return lower + (double_t) i *binwidth ;


}


