     #include <math.h>
     #include <stdio.h>
     #include <gsl/gsl_fit.h>
     #include <gsl/gsl_multifit.h>
     
     int
     main (int argc, char **argv)
     {

       double chisq;
       gsl_matrix *X, *cov;
       gsl_vector *y, *w, *c;
       int n = 4 ; 

       X = gsl_matrix_alloc (n, 4);
       y = gsl_vector_alloc (n);
       w = gsl_vector_alloc (n);
       c = gsl_vector_alloc (4);
       cov = gsl_matrix_alloc (4, 4);

	gsl_matrix_set (X, 0, 0, 1.0); //U_WM
	gsl_matrix_set (X, 1, 0, 1.0);
	gsl_matrix_set (X, 2, 0, 5.0);
	gsl_matrix_set (X, 3, 0, 2.0);
	gsl_matrix_set (X, 0, 1, 1.0); //U_GM
	gsl_matrix_set (X, 1, 1, 2.0);
	gsl_matrix_set (X, 2, 1, 4.0);
	gsl_matrix_set (X, 3, 1, 10.0);
	gsl_matrix_set (X, 0, 2, 1.0); //U_CSF
	gsl_matrix_set (X, 1, 2, 3.0);
	gsl_matrix_set (X, 2, 2, 1.0);
	gsl_matrix_set (X, 3, 2, 5.0);
	gsl_matrix_set (X, 0, 3, 1.0); //const
	gsl_matrix_set (X, 1, 3, 1.0);
	gsl_matrix_set (X, 2, 3, 1.0);
	gsl_matrix_set (X, 3, 3, 1.0);
        gsl_vector_set (y, 0, 101.);     //Gemessenes Signal
        gsl_vector_set (y, 1, 102.2);
        gsl_vector_set (y, 2, 103.);
        gsl_vector_set (y, 3, 106.4);
        gsl_vector_set (w, 0, 1.0);    //Fehler Dummy
        gsl_vector_set (w, 1, 1.0);
        gsl_vector_set (w, 2, 1.0);
        gsl_vector_set (w, 3, 1.0);
     
       {
         gsl_multifit_linear_workspace * work  = gsl_multifit_linear_alloc (n, 4);
         gsl_multifit_wlinear (X, w, y, c, cov, &chisq, work);
         gsl_multifit_linear_free (work);
       }
     
     #define C(i) (gsl_vector_get(c,(i)))
     #define COV(i,j) (gsl_matrix_get(cov,(i),(j)))
     
       /*{
         printf ("# best fit: Y = %g a + %g b + %g c + %g d\n",   C(0), C(1), C(2), C(3));
         printf ("# covarianz matrix:\n");
         printf ("[ %+.5e, %+.5e, %+.5e , %+.5e \n", COV(0,0), COV(0,1), COV(0,2), COV(0,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e \n", COV(1,0), COV(1,1), COV(1,2), COV(1,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e \n", COV(2,0), COV(2,1), COV(2,2), COV(2,3));
         printf ("  %+.5e, %+.5e, %+.5e , %+.5e ]\n", COV(3,0), COV(3,1), COV(3,2), COV(3,3));
         printf ("# chisq = %g\n", chisq);
       }*/
     
       gsl_matrix_free (X);
       gsl_vector_free (y);
       gsl_vector_free (w);
       gsl_vector_free (c);
       gsl_matrix_free (cov);
     
       return 0;
     }
