     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     
     int
     main (void)
     {
       int i, n = 4;
       double x[4] = { 1970, 1980, 1990, 2000 };
       double y[4] = {   12,   11,   14,   13 };
       double w[4] = {  0.1,  0.2,  0.3,  0.4 };
     
       double c0, c1, cov00, cov01, cov11, chisq;
     
       gsl_fit_wlinear (x, 1, w, 1, y, 1, n, 
                        &c0, &c1, &cov00, &cov01, &cov11, 
                        &chisq);
     
       printf ("# best fit: Y = %g + %g X\n", c0, c1);
       printf ("# covariance matrix:\n");
       printf ("# [ %g, %g\n#   %g, %g]\n", 
               cov00, cov01, cov01, cov11);
       printf ("# chisq = %g\n", chisq);
     
      
       return 0;
     }
