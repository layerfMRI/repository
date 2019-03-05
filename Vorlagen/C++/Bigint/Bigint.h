 // BigInt.hxx  header file for class BigInt;
 class BigInt
 {
 private:
   int number[100];           // reserve string with 100 chars
   int ndig;                  // count digits
 public:
   BigInt();                  // default constructor
   BigInt(const char * s);          // standard constructor
   //   BigInt(const BigInt & x ); // copy constructor, spaeter
   //   ~ BigInt();                 // destructor, spaeter
   void print() const;
   BigInt  operator + (const BigInt & x ) const;
   BigInt  operator - (const BigInt & x ) const;
   friend std::ostream &operator << ( std::ostream &s, const BigInt &x); 
 }; 
 std::ostream &operator << ( std::ostream &s, const BigInt &x); 
