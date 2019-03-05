#include <iostream>
#include <iomanip>
#include <cmath>
#include "My3vector.h"
#include "My3vectorDek.cpp"
using namespace std;



int main() {



My3Vector r(1.,1.,0.);
My3Vector e(1.,0.,0.);
cout <<"r=";
r.Disp();
cout<<"r+e=";

r.Add(e).Disp();
cout<<"r*e="<<r.Scalarprodukt(e)<<" bzw. = "<< r*e<<endl;
cout<<"Normierter e=";
My3Vector w;
w=e.Normieren();
w.Disp();

cout << " Winkel zwischen r und e ist :";
cout<< r.Winkel(e)<<endl;
cout<< "alternatieve Ausgabe von e"<<e<<endl;





}




