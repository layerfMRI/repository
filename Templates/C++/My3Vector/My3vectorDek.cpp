#include <iostream>
#include <iomanip>
#include <cmath>
//#include "My3vector.h"
using namespace std;

double My3Vector::Lenght() {

return(x*x+y*y+z*z);
};

My3Vector My3Vector::Add(My3Vector & p) {
My3Vector t;
t.x=x+p.x; t.y=y+p.y; t.z=z+p.z;
return(t);
};


double My3Vector::Scalarprodukt(My3Vector & d){
return (x*d.x+y*d.y+z*d.z);
};


void My3Vector::Disp() {
cout<<"("<<x<<","<<y<<","<<z<<")"<<endl;
};


My3Vector My3Vector::Normieren() {

x=x/sqrt(x*x+y*y+z*z);
y=y/sqrt(x*x+y*y+z*z);
z=z/sqrt(x*x+y*y+z*z);
return * this;
};



double My3Vector::Winkel(My3Vector &W) {

return(acos(Scalarprodukt(W)/(sqrt(x*x+y*y+z*z)*sqrt(W.x*W.x+W.y*W.y+W.z*W.z))));

   }



double My3Vector::operator * (My3Vector &p) {
return(Scalarprodukt(p));
}


 std::ostream & operator << ( std::ostream &s, const My3Vector &v)
{
  s << "(" << v.x <<","<< v.y <<","<< v.z <<")";
  return s;
}

