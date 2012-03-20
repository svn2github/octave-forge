/*

Copyright (C) 2012   Lukas F. Reichlin

This file is part of LTI Syncope.

LTI Syncope is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LTI Syncope is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

SLICOT system identification
Uses SLICOT IB01AD, IB01BD and IB01CD by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: March 2012
Version: 0.1

*/

#include <octave/oct.h>
#include <f77-fcn.h>
#include "common.h"

extern "C"
{ 
    int F77_FUNC (ib01ad, IB01AD)
                 (char& METH, char& ALG, char& JOBD,
                  char& BATCH, char& CONCT, char& CTRL,
                  int& NOBR, int& M, int& L,
                  int& NSMP,
                  double* U, int& LDU,
                  double* Y, int& LDY,
                  int& N,
                  double* R, int& LDR,
                  double* SV,
                  double& RCOND, double& TOL,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  int& IWARN, int& INFO);

    int F77_FUNC (ib01bd, IB01BD)
                 (char& METH, char& JOB, char& JOBCK,
                  int& NOBR, int& N, int& M, int& L,
                  int& NSMPL,
                  double* R, int& LDR,
                  double* A, int& LDA,
                  double* C, int& LDC,
                  double* B, int& LDB,
                  double* D, int& LDD,
                  double* Q, int& LDQ,
                  double* RY, int& LDRY,
                  double* S, int& LDS,
                  double* K, int& LDK,
                  double& TOL,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  bool* BWORK,
                  int& IWARN, int& INFO);

    int F77_FUNC (ib01cd, IB01CD)
                 (char& JOBX0, char& COMUSE, char& JOB,
                  int& N, int& M, int& L,
                  int& NSMP,
                  double* A, int& LDA,
                  double* B, int& LDB,
                  double* C, int& LDC,
                  double* D, int& LDD,
                  double* U, int& LDU,
                  double* Y, int& LDY,
                  double* X0,
                  double* V, int& LDV,
                  double& TOL,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  int& IWARN, int& INFO);
}

// PKG_ADD: autoload ("slident", "devel_slicot_functions.oct");
DEFUN_DLD (slident, args, nargout,
   "-*- texinfo -*-\n\
Slicot IB01AD Release 5.0\n\
No argument checking.\n\
For internal use only.")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 11)
    {
        print_usage ();
    }
    else
    {
////////////////////////////////////////////////////////////////////////////////////
//      SLICOT IB01AD - preprocess the input-output data                          //
////////////////////////////////////////////////////////////////////////////////////

        // arguments in
        char meth;
        char alg;
        char jobd;
        char batch;
        char conct;
        char ctrl;
        char metha;
        char jobda;
        
        Matrix y = args(0).matrix_value ();
        Matrix u = args(1).matrix_value ();
        int nobr = args(2).int_value ();
        
        const int imeth = args(3).int_value ();
        const int ialg = args(4).int_value ();
        const int ijobd = args(5).int_value ();
        const int ibatch = args(6).int_value ();
        const int iconct = args(7).int_value ();
        const int ictrl = args(8).int_value ();
        
        double rcond = args(9).double_value ();
        double tol = args(10).double_value ();
        double tolb = args(9).double_value ();      // tolb = rcond

            
        switch (imeth)
        {
            case 0:
                meth = 'M';
                metha = 'M';
                break;
            case 1:
                meth = 'N';
                metha = 'N';
                break;
            case 2:
                meth = 'C';
                metha = 'N';    // no typo here
                break;
            default:
                error ("slib01ad: argument 'meth' invalid");
        }

        switch (ialg)
        {
            case 0:
                alg = 'C';
                break;
            case 1:
                alg = 'F';
                break;
            case 2:
                alg = 'Q';
                break;
            default:
                error ("slib01ad: argument 'alg' invalid");
        }
        
        if (meth == 'C')
            jobd = 'N';
        else if (ijobd == 0)
            jobd = 'M';
        else
            jobd = 'N';
        
        switch (ibatch)
        {
            case 0:
                batch = 'F';
                break;
            case 1:
                batch = 'I';
                break;
            case 2:
                batch = 'L';
                break;
            case 3:
                batch = 'O';
                break;
            default:
                error ("slib01ad: argument 'batch' invalid");
        }

        if (iconct == 0)
            conct = 'C';
        else
            conct = 'N';

        if (ictrl == 0)
            ctrl = 'C';
        else
            ctrl = 'N';


        int m = u.columns ();   // m: number of inputs
        int l = y.columns ();   // l: number of outputs
        int nsmp = y.rows ();   // nsmp: number of samples
        // y.rows == u.rows  is checked by iddata class
        // TODO: check minimal nsmp size
        
        if (batch == 'O')
        {
            if (nsmp < 2*(m+l+1)*nobr - 1)
                error ("slident: require NSMP >= 2*(M+L+1)*NOBR - 1");
        }
        else
        {
            if (nsmp < 2*nobr)
                error ("slident: require NSMP >= 2*NOBR");
        }
        
        int ldu;
        
        if (m == 0)
            ldu = 1;
        else                    // m > 0
            ldu = nsmp;

        int ldy = nsmp;

        // arguments out
        int n;
        int ldr;
        
        if (metha == 'M' && jobd == 'M')
            ldr = max (2*(m+l)*nobr, 3*m*nobr);
        else if (metha == 'N' || (metha == 'M' && jobd == 'N'))
            ldr = 2*(m+l)*nobr;
        else
            error ("slib01ad: could not handle 'ldr' case");
        
        Matrix r (ldr, 2*(m+l)*nobr);
        ColumnVector sv (l*nobr);

        // workspace
        int liwork;

        if (metha == 'N')            // if METH = 'N'
            liwork = (m+l)*nobr;
        else if (alg == 'F')        // if METH = 'M' and ALG = 'F'
            liwork = m+l;
        else                        // if METH = 'M' and ALG = 'C' or 'Q'
            liwork = 0;

        // TODO: Handle 'k' for DWORK

        int ldwork;
        
        if (alg == 'C')
        {
            if (batch == 'F' || batch == 'I')
            {
                if (conct == 'C')
                    ldwork = (4*nobr-2)*(m+l);
                else    // (conct == 'N')
                    ldwork = 1;
            }
            else if (metha == 'M')   // && (batch == 'L' || batch == 'O')
            {
                if (conct == 'C' && batch == 'L')
                    ldwork = max ((4*nobr-2)*(m+l), 5*l*nobr);
                else if (jobd == 'M')
                    ldwork = max ((2*m-1)*nobr, (m+l)*nobr, 5*l*nobr);
                else    // (jobd == 'N')
                    ldwork = 5*l*nobr;
            }
            else    // meth == 'N' && (batch == 'L' || batch == 'O')
            {
                ldwork = 5*(m+l)*nobr + 1;
            }
        }
        else if (alg == 'F')
        {
            if (batch != 'O' && conct == 'C')
                ldwork = (m+l)*2*nobr*(m+l+3);
            else if (batch == 'F' || batch == 'I')  // && conct == 'N'
                ldwork = (m+l)*2*nobr*(m+l+1);
            else    // (batch == 'L' || '0' && conct == 'N')
                ldwork = (m+l)*4*nobr*(m+l+1)+(m+l)*2*nobr;
        }
        else    // (alg == 'Q')
        {
            int ns = nsmp - 2*nobr + 1;
            
            if (ldr >= ns && batch == 'F')
            {
                ldwork = 4*(m+l)*nobr;
            }
            else if (ldr >= ns && batch == 'O')
            {
                if (metha == 'M')
                    ldwork = max (4*(m+l)*nobr, 5*l*nobr);
                else    // (meth == 'N')
                    ldwork = 5*(m+l)*nobr + 1;
            }
            else if (conct == 'C' && (batch == 'I' || batch == 'L'))
            {
                ldwork = 4*(nobr+1)*(m+l)*nobr;
            }
            else    // if ALG = 'Q', (BATCH = 'F' or 'O', and LDR < NS), or (BATCH = 'I' or 'L' and CONCT = 'N')
            {
                ldwork = 6*(m+l)*nobr;
            }
        }
////////////////////////////////////////////////////////////////////
// TO BE REMOVED !!!
////////////////////////////////////////////////////////////////////        
ldwork = 100000;
////////////////////////////////////////////////////////////////////

/*
IB01AD.f Lines 291-195:
c             the workspace used for alg = 'q' is
c                       ldrwrk*2*(m+l)*nobr + 4*(m+l)*nobr,
c             where ldrwrk = ldwork/(2*(m+l)*nobr) - 2; recommended
c             value ldrwrk = ns, assuming a large enough cache size.
c             for good performance,  ldwork  should be larger.

somehow ldrwrk and ldwork must have been mixed up here

*/


        OCTAVE_LOCAL_BUFFER (int, iwork, liwork);
        OCTAVE_LOCAL_BUFFER (double, dwork, ldwork);
        
        // error indicators
        int iwarn = 0;
        int info = 0;


        // SLICOT routine IB01AD
        F77_XFCN (ib01ad, IB01AD,
                 (metha, alg, jobd,
                  batch, conct, ctrl,
                  nobr, m, l,
                  nsmp,
                  u.fortran_vec (), ldu,
                  y.fortran_vec (), ldy,
                  n,
                  r.fortran_vec (), ldr,
                  sv.fortran_vec (),
                  rcond, tol,
                  iwork,
                  dwork, ldwork,
                  iwarn, info));


        if (f77_exception_encountered)
            error ("ident: exception in SLICOT subroutine IB01AD");

        static const char* err_msg[] = {
            "0: OK",
            "1: a fast algorithm was requested (ALG = 'C', or 'F') "
                "in sequential data processing, but it failed; the "
                "routine can be repeatedly called again using the "
                "standard QR algorithm",
            "2: the singular value decomposition (SVD) algorithm did "
                "not converge"};

        static const char* warn_msg[] = {
            "0: OK",
            "1: the number of 100 cycles in sequential data "
                "processing has been exhausted without signaling "
                "that the last block of data was get; the cycle "
                "counter was reinitialized",
            "2: a fast algorithm was requested (ALG = 'C' or 'F'), "
                "but it failed, and the QR algorithm was then used "
                "(non-sequential data processing)",
            "3: all singular values were exactly zero, hence  N = 0 "
                "(both input and output were identically zero)",
            "4: the least squares problems with coefficient matrix "
                "U_f,  used for computing the weighted oblique "
                "projection (for METH = 'N'), have a rank-deficient "
                "coefficient matrix",
            "5: the least squares problem with coefficient matrix "
                "r_1  [6], used for computing the weighted oblique "
                "projection (for METH = 'N'), has a rank-deficient "
                "coefficient matrix"};


        error_msg ("ident", info, 2, err_msg);
        warning_msg ("ident", iwarn, 5, warn_msg);


        // resize
        int rs = 2*(m+l)*nobr;
        r.resize (rs, rs);
        
////////////////////////////////////////////////////////////////////////////////////
//      SLICOT IB01BD - estimating system matrices, Kalman gain, and covariances  //
////////////////////////////////////////////////////////////////////////////////////

        // arguments in
        char job = 'A';
        char jobck = 'K';
        
        // TODO: if meth == 'C', which meth should be taken for IB01AD.f, 'M' or 'N'?

        int nsmpl = nsmp;
        
        // arguments out
        int lda = max (1, n);
        int ldc = max (1, l);
        int ldb = max (1, n);
        int ldd = max (1, l);
        int ldq = n;            // if JOBCK = 'C' or 'K'
        int ldry = l;           // if JOBCK = 'C' or 'K'
        int lds = n;            // if JOBCK = 'C' or 'K'
        int ldk = n;            // if JOBCK = 'K'
        
        Matrix a (lda, n);
        Matrix c (ldc, n);
        Matrix b (ldb, m);
        Matrix d (ldd, m);
        
        Matrix q (ldq, n);
        Matrix ry (ldry, l);
        Matrix s (lds, l);
        Matrix k (ldk, l);
        
        // workspace
        int liwork_b;
        int liw1;
        int liw2;
        
        liw1 = max (n, m*nobr+n, l*nobr, m*(n+l));
        liw2 = n*n;     // if JOBCK =  'K'
        liwork_b = max (liw1, liw2);

        int ldwork_b;
        int ldw1;
        int ldw2;
        int ldw3;
        
        if (meth == 'M')
        {
            int ldw1a = max (2*(l*nobr-l)*n+2*n, (l*nobr-l)*n+n*n+7*n);
            int ldw1b = max (2*(l*nobr-l)*n+n*n+7*n,
                             (l*nobr-l)*n+n+6*m*nobr,
                             (l*nobr-l)*n+n+max (l+m*nobr, l*nobr + max (3*l*nobr+1, m)));
            ldw1 = max (ldw1a, ldw1b);
            
            int aw;
            
            if (m == 0 || job == 'C')
                aw = n + n*n;
            else
                aw = 0;
            
            ldw2 = l*nobr*n + max ((l*nobr-l)*n+aw+2*n+max(5*n,(2*m+l)*nobr+l), 4*(m*nobr+n)+1, m*nobr+2*n+l );
        }
        else if (meth == 'N')
        {
            ldw1 = l*nobr*n + max ((l*nobr-l)*n+2*n+(2*m+l)*nobr+l,
                                   2*(l*nobr-l)*n+n*n+8*n,
                                   n+4*(m*nobr+n)+1,
                                   m*nobr+3*n+l);
                                   
            if (m == 0 || job == 'C')
                ldw2 = 0;
            else
                ldw2 = l*nobr*n+m*nobr*(n+l)*(m*(n+l)+1)+ max ((n+l)*(n+l), 4*m*(n+l)+1);

        }
        else    // (meth == 'C')
        {
            int ldw1a = max (2*(l*nobr-l)*n+2*n, (l*nobr-l)*n+n*n+7*n);
            int ldw1b = l*nobr*n + max ((l*nobr-l)*n+2*n+(2*m+l)*nobr+l,
                                        2*(l*nobr-l)*n+n*n+8*n,
                                        n+4*(m*nobr+n)+1,
                                        m*nobr+3*n+l);
                                        
            ldw1 = max (ldw1a, ldw1b);
                                        
            ldw2 = l*nobr*n+m*nobr*(n+l)*(m*(n+l)+1)+ max ((n+l)*(n+l), 4*m*(n+l)+1);

        }
            
        ldw3 = max(4*n*n + 2*n*l + l*l + max (3*l, n*l), 14*n*n + 12*n + 5);
        ldwork_b = max (ldw1, ldw2, ldw3);

        OCTAVE_LOCAL_BUFFER (int, iwork_b, liwork_b);
        OCTAVE_LOCAL_BUFFER (double, dwork_b, ldwork_b);
        OCTAVE_LOCAL_BUFFER (bool, bwork, 2*n);


        // error indicators
        int iwarn_b = 0;
        int info_b = 0;


        // SLICOT routine IB01BD
        F77_XFCN (ib01bd, IB01BD,
                 (meth, job, jobck,
                  nobr, n, m, l,
                  nsmpl,
                  r.fortran_vec (), ldr,
                  a.fortran_vec (), lda,
                  c.fortran_vec (), ldc,
                  b.fortran_vec (), ldb,
                  d.fortran_vec (), ldd,
                  q.fortran_vec (), ldq,
                  ry.fortran_vec (), ldry,
                  s.fortran_vec (), lds,
                  k.fortran_vec (), ldk,
                  tolb,
                  iwork_b,
                  dwork_b, ldwork_b,
                  bwork,
                  iwarn_b, info_b));


        if (f77_exception_encountered)
            error ("ident: exception in SLICOT subroutine IB01BD");

        static const char* err_msg_b[] = {
            "0: OK",
            "1: error message not specified",
            "2: the singular value decomposition (SVD) algorithm did "
                "not converge",
            "3: a singular upper triangular matrix was found",
            "4: matrix A is (numerically) singular in discrete-"
                "time case",
            "5: the Hamiltonian or symplectic matrix H cannot be "
                "reduced to real Schur form",
            "6: the real Schur form of the Hamiltonian or "
                "symplectic matrix H cannot be appropriately ordered",
            "7: the Hamiltonian or symplectic matrix H has less "
                "than N stable eigenvalues",
            "8: the N-th order system of linear algebraic "
                "equations, from which the solution matrix X would "
                "be obtained, is singular to working precision",
            "9: the QR algorithm failed to complete the reduction "
                "of the matrix Ac to Schur canonical form, T",
            "10: the QR algorithm did not converge"};

        static const char* warn_msg_b[] = {
            "0: OK",
            "1: warning message not specified",
            "2: warning message not specified",
            "3: warning message not specified",
            "4: a least squares problem to be solved has a "
                "rank-deficient coefficient matrix",
            "5: the computed covariance matrices are too small. "
                "The problem seems to be a deterministic one; the "
                "gain matrix is set to zero"};


        error_msg ("ident", info_b, 10, err_msg_b);
        warning_msg ("ident", iwarn_b, 5, warn_msg_b);

        // resize
        a.resize (n, n);
        c.resize (l, n);
        b.resize (n, m);
        d.resize (l, m);
        
        q.resize (n, n);
        ry.resize (l, l);
        s.resize (n, l);
        k.resize (n, l);

////////////////////////////////////////////////////////////////////////////////////
//      SLICOT IB01CD - estimating the initial state                              //
////////////////////////////////////////////////////////////////////////////////////

// TODO: use only one iwork and dwork for all three slicot routines
//       ldwork = max (ldwork_a, ldwork_b, ldwork_c)


        // arguments in
        char jobx0 = 'X';
        char comuse = 'U';
        char jobbd = 'D';
        
        // arguments out
        int ldv = max (1, n);
        
        ColumnVector x0 (n);
        Matrix v (ldv, n);
        
        // workspace
        int liwork_c = n;     // if  JOBX0 = 'X'  and  COMUSE <> 'C'
        int ldwork_c;
        int t = nsmp;
   
        int ldw1_c = 2;
        int ldw2_c = t*l*(n + 1) + 2*n + max (2*n*n, 4*n);
        int ldw3_c = n*(n + 1) + 2*n + max (n*l*(n + 1) + 2*n*n + l*n, 4*n);

        ldwork_c = ldw1_c + n*( n + m + l ) + max (5*n, ldw1_c, min (ldw2_c, ldw3_c));
        
        OCTAVE_LOCAL_BUFFER (int, iwork_c, liwork_c);
        OCTAVE_LOCAL_BUFFER (double, dwork_c, ldwork_c);

        // error indicators
        int iwarn_c = 0;
        int info_c = 0;
        

        // SLICOT routine IB01CD
        F77_XFCN (ib01cd, IB01CD,
                 (jobx0, comuse, jobbd,
                  n, m, l,
                  nsmp,
                  a.fortran_vec (), lda,
                  b.fortran_vec (), ldb,
                  c.fortran_vec (), ldc,
                  d.fortran_vec (), ldd,
                  u.fortran_vec (), ldu,
                  y.fortran_vec (), ldy,
                  x0.fortran_vec (),
                  v.fortran_vec (), ldv,
                  tolb,
                  iwork_c,
                  dwork_c, ldwork_c,
                  iwarn_c, info_c));


        if (f77_exception_encountered)
            error ("ident: exception in SLICOT subroutine IB01CD");

        static const char* err_msg_c[] = {
            "0: OK",
            "1: the QR algorithm failed to compute all the "
                "eigenvalues of the matrix A (see LAPACK Library "
                "routine DGEES); the locations  DWORK(i),  for "
                "i = g+1:g+N*N,  contain the partially converged "
                "Schur form",
            "2: the singular value decomposition (SVD) algorithm did "
                "not converge"};

        static const char* warn_msg_c[] = {
            "0: OK",
            "1: warning message not specified",
            "2: warning message not specified",
            "3: warning message not specified",
            "4: the least squares problem to be solved has a "
                "rank-deficient coefficient matrix",
            "5: warning message not specified",
            "6: the matrix  A  is unstable;  the estimated  x(0) "
                "and/or  B and D  could be inaccurate"};


        error_msg ("ident", info_c, 2, err_msg_c);
        warning_msg ("ident", iwarn_c, 6, warn_msg_c);
      
        
        // return values
        retval(0) = a;
        retval(1) = b;
        retval(2) = c;
        retval(3) = d;
        
        retval(4) = q;
        retval(5) = ry;
        retval(6) = s;
        retval(7) = k;
        
        retval(8) = x0;
        //retval(0) = octave_value (n);
        //retval(1) = r;
        //retval(2) = sv;
    }
    
    return retval;
}
