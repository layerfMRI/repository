#include <iostream>

using namespace std;







int main()
{ 

int variable = 5 ; 
   cout<< "variable = " << variable <<endl;
int* zeiger =  &variable ;
   cout<< "zeiger = " << zeiger <<endl;

      cout<< "*zeiger = " << *zeiger <<endl;
*zeiger = 3    ;
      cout<< "*zeiger = " << *zeiger <<endl;
   cout<< "variable = " << variable <<endl;

   cout<< "&variable = " << &variable <<endl;

return 0;
}





    
