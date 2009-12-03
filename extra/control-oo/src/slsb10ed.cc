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

H2 optimal state controller for a discrete-time system.
Uses SLICOT SB10ED by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: November 2009
Version: 0.1

*/

#include <octave/oct.h>
#include <f77-fcn.h>

extern "C"
{ 
    int F77_FUNC (sb10ed, SB10ED) (int& N, int& M, int& NP,
                                   int& NCON, int& NMEAS,
                                   double* A, int& LDA,
                                   double* B, int& LDB,
                                   double* C, int& LDC,
                                   double* D, int& LDD,
                                   double* AK, int& LDAK,
                                   double* BK, int& LDBK,
                                   double* CK, int& LDCK,
                                   double* DK, int& LDDK,
                                   double* RCOND,
                                   double& TOL,
                                   int* IWORK,
                                   double* DWORK, int& LDWORK,
                                   bool* BWORK,
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

int max (int a, int b, int c, int d)
{
    int e = max (a, b);
    int f = max (c, d);
    
    if (e > f)
        return e;
    else
        return f;
}
     
DEFUN_DLD (slsb10ed, args, nargout, "Slicot SB10ED Release 5.0")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 6)
    {
        print_usage ();
    }
    else
    {
        // arguments in
        NDArray a = args(0).array_value ();
        NDArray b = args(1).array_value ();
        NDArray c = args(2).array_value ();
        NDArray d = args(3).array_value ();
        
        int ncon = args(4).int_value ();
        int nmeas = args(5).int_value ();
        
        int n = a.rows ();      // n: number of states
        int m = b.columns ();   // m: number of inputs
        int np = c.rows ();     // np: number of outputs
        
        int lda = a.rows ();
        int ldb = b.rows ();
        int ldc = c.rows ();
        int ldd = d.rows ();
        
        int ldak = max (1, n);
        int ldbk = max (1, n);
        int ldck = max (1, ncon);
        int lddk = max (1, ncon);
        
        double tol = 0;
        
        // arguments out
        dim_vector dv_ak (2);
        dv_ak(0) = ldak;
        dv_ak(1) = n;
        
        dim_vector dv_bk (2);
        dv_bk(0) = ldbk;
        dv_bk(1) = nmeas;
        
        dim_vector dv_ck (2);
        dv_ck(0) = ldck;
        dv_ck(1) = n;
        
        dim_vector dv_dk (2);
        dv_dk(0) = lddk;
        dv_dk(1) = nmeas;
        
        dim_vector dv (1);
        dv(0) = 7;
        
        NDArray ak (dv_ak);
        NDArray bk (dv_bk);
        NDArray ck (dv_ck);
        NDArray dk (dv_dk);
        NDArray rcond (dv);
        
        // workspace
        int* iwork;
        double* dwork;
        bool* bwork;
        
        int m2 = ncon;
        int m1 = m - m2;
        int np1 = np - nmeas;
        int np2 = nmeas;
        
        int q = max (m1, m2, np1, np2);
        int ldwork = 2*q*(3*q+2*n)+max(1,(n+q)*(n+q+6),q*(q+max(n,q,5)+1),
                      2*n*n+max(1,14*n*n+6*n+max(14*n+23,16*n),
                                q*(n+q+max(q,3))));
        int liwork = max (2*m2, 2*n, n*n, np2);
        
        iwork = new int[liwork];
        dwork = new double[ldwork];
        bwork = new bool[2*n];
        
        // error indicator
        int info;


        // SLICOT routine SB10HD
        F77_XFCN (sb10ed, SB10ED, (n, m, np,
                                   ncon, nmeas,
                                   a.fortran_vec (), lda,
                                   b.fortran_vec (), ldb,
                                   c.fortran_vec (), ldc,
                                   d.fortran_vec (), ldd,
                                   ak.fortran_vec (), ldak,
                                   bk.fortran_vec (), ldbk,
                                   ck.fortran_vec (), ldck,
                                   dk.fortran_vec (), lddk,
                                   rcond.fortran_vec (),
                                   tol,
                                   iwork,
                                   dwork, ldwork,
                                   bwork,
                                   info));

        if (f77_exception_encountered)
            error ("h2syn: slsb10ed: exception in SLICOT subroutine SB10ED");
            
        if (info != 0)
            error ("h2syn: slsb10ed: SB10ED returned info = %d", info);
        
        // return values
        retval(0) = ak;
        retval(1) = bk;
        retval(2) = ck;
        retval(3) = dk;
        
        // free memory
        delete[] iwork;
        delete[] dwork;
        delete[] bwork;
    }
    
    return retval;
}
