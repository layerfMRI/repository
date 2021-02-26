 #include <iostream>
 #include <cstring>
 #include "Bigint.h"

 using namespace std;

 #define MAX(a,b) ( (a) > (b) ? ( a ) : ( b ) )
 BigInt::BigInt() {  ndig = 0; }
 BigInt::BigInt(const char * str)
 {
   int len = strlen(str);
   ndig = 0;
   while ( len >= 0 ) {
     int c = str[len--];
     if ( c >= '0' && c <= '9' ) {
       number[ndig++] = c - '0';
     }
   }
 }    
 BigInt BigInt::operator + (const BigInt & x ) const
 {
   BigInt t;
   t.ndig = MAX( this->ndig, x.ndig) + 1;
   int sum = 0, carry = 0;
   for ( int i = 0; i < t.ndig; i++ ) {
     carry = sum/10;
     sum = carry;
     if ( i < this->ndig )
        sum += this->number[i];

     if ( i < x.ndig )  sum += x.number[i];

     t.number[i] = sum % 10;
   }
   if ( carry == 0 )  t.ndig --;
   return t;
 }
 void BigInt::print() const
   {
     for ( int i = ndig; i > 0; i-- ) {
       cout << number[i-1];
       }
     cout << endl;
 } 

int main() {

cout<<"Hallo"<< endl;
double a=b(3.);
}



