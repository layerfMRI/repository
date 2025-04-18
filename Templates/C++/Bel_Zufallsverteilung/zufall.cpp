#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
using namespace std;


double comul_verteilung(double);
double inverse(double);
double verteilung(double);
double_t arb_pdf_num(int N, double_t verteilung(double_t x), double_t lower, double_t upper);

int N1 = 100000;
int bins =100;
double zufallszahl; //zwischen 0 und 1 mit 4 Stellen
double a = 1. ; //Breite der Verteilung

int main()
{
   //  in datei schreiben
    ofstream outf("data.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
  
  for (int i = 0; i < N1 ; i++) {
    zufallszahl = (double) (rand()%1000000)/1000000. ;
    if (inverse(zufallszahl)>0.) {
        outf<< inverse(zufallszahl) << endl;
        }
  //  cout<< inverse(zufallszahl) << endl;
  }
  
  
  outf.close();
    
   
return 0;
}



    
double comul_verteilung(double x){
    return (erf(x/(a*sqrt(2.)))+1.)*0.5-sqrt(2./M_PI)*x/a*exp(-x*x/(a*a*2));
}

double verteilung(double z){
    return exp(-z*z/(2.*a*a))*(z*z)/(a*a*a)*sqrt(2./M_PI);
}


double inverse(double y){
    
    double y0 = 0.4;  //willkürlich zwischen 0 und 1
    double y1 = 0.58768734843; //willkürlich zwischen 0 und 1
    double epsilon=1.;
    
    while (epsilon > 0.00001) {
    y0 = y1 - ((comul_verteilung(y1)-y)/(verteilung(y1)));
    epsilon = abs(y1 - y0);
    y1 = y0;
    }
  //  cout << "konvergiert"<<endl;
    
    return y1;
}
    
    
double_t arb_pdf_num(int N, double_t verteilung(double_t x), double_t lower, double_t upper){
	double_t binwidth = (upper - lower)/(double_t)N;
	double_t integral = 0.0;
	double_t rand_num = rand()/(double_t)RAND_MAX;
	
	
	for (int i = 0; integral < rand_num; i++){
		integral += verteilung(lower + (double_t) i + 0.5) *binwidth );
		
		if (i = = N + 1 ) {
		    cout << " upper limit ueberschritten" << endl;
		    exit(-1);
		}
	}
	return integral;
}





