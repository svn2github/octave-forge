/*

Copyright (C) 2009   Lukas F. Reichlin

This file is part of LTI Syncope.

LTI Syncope is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LTI Syncope is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

H-2 norm of a SS model.
Uses SLICOT AB13BD by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: November 2009
Version: 0.1

*/

#include <octave/oct.h>
#include <f77-fcn.h>

extern "C"
{ 
    double F77_FUNC (ab13bd, AB13BD)
                    (char& DICO, char& JOBN,
                     int& N, int& M, int& P,
                     double* A, int& LDA,
                     double* B, int& LDB,
                     double* C, int& LDC,
                     double* D, int& LDD,
                     int& NQ,
                     double& TOL,
                     double* DWORK, int& LDWORK,
                     int& IWARN,
                     int& INFO);
}

int max (int a, int b)
{
    if (a > b)
        return a;
    else
        return b;
}

int max (int a, int b, int c)
{
    int d = max (a, b);
    
    if (c > d)
        return c;
    else
        return d;
}

int min (int a, int b)
{
    if (a < b)
        return a;
    else
        return b;
}
     
DEFUN_DLD (slab13bd, args, nargout, "Slicot AB13BD Release 5.0")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 5)
    {
        print_usage ();
    }
    else
    {
        // arguments in
        char dico;
        char jobn = 'H';
        
        NDArray a = args(0).array_value ();
        NDArray b = args(1).array_value ();
        NDArray c = args(2).array_value ();
        NDArray d = args(3).array_value ();
        double tsam = args(4).double_value ();

        if (tsam > 0)
            dico = 'D';
        else
            dico = 'C';
        
        int n = a.rows ();      // n: number of states
        int m = b.columns ();   // m: number of inputs
        int p = c.rows ();      // p: number of outputs
        
        int lda = max (1, a.rows ());
        int ldb = max (1, b.rows ());
        int ldc = max (1, c.rows ());
        int ldd = max (1, d.rows ());
        
        // arguments out
        double norm;
        int nq;
        
        // tolerance
        double tol = 0;
        
        // workspace
        double* dwork;
        int ldwork = max (1, m*(n+m) + max (n*(n+5), m*(m+2), 4*p ),
                             n*(max (n, p) + 4 ) + min (n, p));
        dwork = new double[ldwork];
        
        // error indicator
        int iwarn;
        int info;


        // SLICOT routine AB13BD
        norm = F77_FUNC (ab13bd, AB13BD)
                        (dico, jobn,
                         n, m, p,
                         a.fortran_vec (), lda,
                         b.fortran_vec (), ldb,
                         c.fortran_vec (), ldc,
                         d.fortran_vec (), ldd,
                         nq,
                         tol,
                         dwork, ldwork,
                         iwarn,
                         info);

        if (f77_exception_encountered)
            error ("lti: norm: slab13bd: exception in SLICOT subroutine AB13BD");
            
        if (info != 0)
            error ("lti: norm: slab13bd: AB13BD returned info = %d", info);
        
        // return value
        retval(0) = octave_value (norm);
        retval(1) = octave_value (iwarn);
        
        // free memory
        delete[] dwork;
    }
    
    return retval;
}
