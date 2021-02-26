#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;

class My3Vector {
protected:
double x;
double y;
double z;
public:
My3Vector(){};
My3Vector(double a, double b, double c) {
x=a;
y=b;
z=c;
};

double Lenght() ;
My3Vector Add(My3Vector & p);
double Scalarprodukt(My3Vector & d);
void Disp(); 
My3Vector Normieren();  //vielleicht noch {}
double Winkel(My3Vector &W);
double operator * (My3Vector &p);
friend std::ostream & operator << ( std::ostream &, const My3Vector &);
};






