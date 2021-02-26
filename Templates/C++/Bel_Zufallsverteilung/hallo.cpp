#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
using namespace std;




double verteilung(double x);

double fak(int x); // fur Binomial


int main()
{
   //  in datei schreiben
    ofstream outf("data.dat");
  if (!outf) {
    cout<<"Fehler beim Oeffnen der Datei!"<<endl;
  }
  
  for (int i = 0; i < 20 ; i++) {
  		outf<<verteilung(i)<< endl;

  }
  outf.close();
   
   cout<< "Hallo" <<endl;
   
   
return 0;
}




//Binomial lower = 0, upper = 25
double verteilung(double k){
	double p = 0.5;
	double n = 20.;
	return pow(p, k) *pow(1.-p, n-k) * fak(n)/(fak(k)*fak(n-k));
	}

		double fak(int x){
		long int fakul = 1;
		for(int j = 1; j <= x ; j++){
			fakul = fakul * j;
			}
		return (double) fakul;
		}



    
