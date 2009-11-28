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

Transmission zeros of SS object.
Uses SLICOT AB08ND by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: November 2009
Version: 0.1

*/

#include <octave/oct.h>
#include "f77-fcn.h"

extern "C"
{ 
    int F77_FUNC (ab08nd, AB08ND) (char& EQUIL,
                                   int& N, int& M, int& P,
                                   double* A, int& LDA,
                                   double* B, int& LDB,
                                   double* C, int& LDC,
                                   double* D, int& LDD,
                                   int& NU, int& RANK, int& DINFZ,
                                   int& NKROR, int& NKROL, int* INFZ,
                                   int* KRONR, int* KRONL,
                                   double* AF, int& LDAF,
                                   double* BF, int& LDBF,
                                   double& TOL,
                                   int* IWORK, double* DWORK, int& LDWORK,
                                   int& INFO);
                                   
    int F77_FUNC (dggev, DGGEV) (char& JOBVL, char& JOBVR,
                                 int& N,
                                 double* A, int& LDA,
                                 double* B, int& LDB,
                                 double* ALPHAR, double* ALPHAI,
                                 double* BETA,
                                 double* VL, int& LDVL,
                                 double* VR, int& LDVR,
                                 double* WORK, int& LWORK,
                                 int& INFO);
}

int max (int a, int b)
{
    if (a > b)
        return a;
    else
        return b;
}

int min (int a, int b)
{
    if (a < b)
        return a;
    else
        return b;
}
     
DEFUN_DLD (slab08nd, args, nargout, "Slicot AB08ND Release 5.0")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 4)
    {
        print_usage ();
    }
    else
    {
        // arguments in
        char equil = 'N';
        
        NDArray a = args(0).array_value ();
        NDArray b = args(1).array_value ();
        NDArray c = args(2).array_value ();
        NDArray d = args(3).array_value ();
        
        int n = a.rows ();      // n: number of states
        int m = b.columns ();   // m: number of inputs
        int p = c.rows ();      // p: number of outputs
        
        int lda = a.rows ();
        int ldb = b.rows ();
        int ldc = c.rows ();
        int ldd = d.rows ();
        
        // arguments out
        int nu;
        int rank;
        int dinfz;
        int nkror;
        int nkrol;
        
        int* infz;
        int* kronr;
        int* kronl;
        
        double* af;
        int ldaf = n + m;
        double* bf;
        int ldbf = n + p;
        
        infz = new int[n];
        kronr = new int[1+max(n,m)];
        kronl = new int[1+max(n,p)];

        af = new double[ldaf*(n+min(p,m))];
        bf = new double[ldbf*(n+m)];

        // workspace
        int* iwork;
        double* dwork;
        int ldwork;
        
        int s = max (m, p);
        ldwork = max (s, n) + max (3*s-1, n+s);
        
        iwork = new int[s];
        dwork = new double[ldwork];
        
        // error indicator
        int info;
        
        // tolerance
        double tol = 2.2204e-16;    // TODO: use LAPACK dlamch

        // SLICOT routine AB08ND
        F77_XFCN (ab08nd, AB08ND, (equil,
                                   n, m, p,
                                   a.fortran_vec (), lda,
                                   b.fortran_vec (), ldb,
                                   c.fortran_vec (), ldc,
                                   d.fortran_vec (), ldd,
                                   nu, rank, dinfz,
                                   nkror, nkrol, infz,
                                   kronr, kronl,
                                   af, ldaf,
                                   bf, ldbf,
                                   tol,
                                   iwork, dwork, ldwork,
                                   info));

        if (f77_exception_encountered)
            error ("ss: zero: slab08nd: exception in SLICOT subroutine AB08ND");
            
        if (info != 0)
            error ("ss: zero: slab08nd: AB08ND did not return 0");
        
        
        // DGGEV Part
        char jobvl = 'N';
        char jobvr = 'N';

        double* vl;
        int ldvl = 1;
        double* vr;
        int ldvr = 1;
        
        double* work;
        int lwork = max (1, 8*nu);
        
        vl = new double[ldvl];
        vr = new double[ldvr];
        work = new double[lwork];
        
        dim_vector dv (1);
        dv(0) = nu;
        NDArray alphar (dv);
        NDArray alphai (dv);
        NDArray beta (dv);
        
        int info2;
        
        F77_XFCN (dggev, DGGEV, (jobvl, jobvr,
                                 nu,
                                 af, ldaf,
                                 bf, ldbf,
                                 alphar.fortran_vec (), alphai.fortran_vec (),
                                 beta.fortran_vec (),
                                 vl, ldvl,
                                 vr, ldvr,
                                 work, lwork,
                                 info2));
                                 
        if (f77_exception_encountered)
            error ("ss: zero: slab08nd: exception in LAPACK subroutine DGGEV");
            
        if (info2 != 0)
            error ("ss: zero: slab08nd: DGGEV did not return 0");
        
        // return values
        retval(0) = alphar;
        retval(1) = alphai;
        retval(2) = beta;
        
        // free memory
        delete[] infz;
        delete[] kronr;
        delete[] kronl;
        
        delete[] af;
        delete[] bf;
        
        delete[] iwork;
        delete[] dwork;
        
        delete[] vl;
        delete[] vr;
        delete[] work;
    }
    
    return retval;
}
