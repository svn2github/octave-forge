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

TODO
Uses SLICOT IB01BD by courtesy of NICONET e.V.
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
}

// PKG_ADD: autoload ("slib01bd", "devel_slicot_functions.oct");
DEFUN_DLD (slib01bd, args, nargout,
   "-*- texinfo -*-\n\
Slicot IB01BD Release 5.0\n\
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
        // arguments in
        char meth;
        char alg;
        char jobd;
        char batch;
        char conct;
        char ctrl;
        
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
        

        if (imeth == 0)
            meth = 'M';
        else
            meth = 'N';

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
                error ("slib01bd: argument 'alg' invalid");
        }
        
        if (ijobd == 0)
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
                error ("slib01bd: argument 'batch' invalid");
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
        
        int ldu;
        
        if (m == 0)
            ldu = 1;
        else                    // m > 0
            ldu = nsmp;

        int ldy = nsmp;

        // arguments out
        int n;
        int ldr;
        
        if (meth == 'M' && jobd == 'M')
            ldr = max (2*(m+l)*nobr, 3*m*nobr);
        else if (meth == 'N' || (meth == 'M' && jobd == 'N'))
            ldr = 2*(m+l)*nobr;
        else
            error ("slib01bd: could not handle 'ldr' case");
        
        Matrix r (ldr, 2*(m+l)*nobr);
        ColumnVector sv (l*nobr);

        // workspace
        int liwork;

        if (meth == 'N')            // if METH = 'N'
            liwork = (m+l)*nobr;
        else if (alg == 'F')        // if METH = 'M' and ALG = 'F'
            liwork = m+l;
        else                        // if METH = 'M' and ALG = 'C' or 'Q'
            liwork = 0;

        // TODO: Handle 'k' for DWORK

        int ldwork;

        ldwork = 0;

        if (alg == 'C' && (batch == 'F' || batch == 'I') && conct = 'C')
            ldwork = (4*nobr-2)*(m+l);
        else if (alg == 'C' && (batch == 'F' || batch == 'I') && conct = 'N')
            ldwork = 1;
        else if (meth == 'M' && alg == 'C' && batch == 'L' && conct == 'C')
            ldwork = max ((4*nobr-2)*(m+l), 5*l*nobr);
        else if ((meth == 'M' && jobd = 'M' && alg == 'C' && batch == 'O') || (batch == 'L' && conct == 'N'))
            ldwork = max ((2*m-1)*nobr, (m+l)*nobr, 5*l*nobr);
        else if ((meth == 'M' && jobd == 'N' && alg == 'C' && batch == 'O') || (batch == 'L' && conct == 'N'))
            ldwork = 5*l*nobr;

        // FIXME : two times  || (batch == 'L' && conct == 'N') doesn't make sense

C             LDWORK >= 5*(M+L)*NOBR+1, if METH = 'N', ALG = 'C', and
C                             BATCH = 'L' or 'O';
C             LDWORK >= (M+L)*2*NOBR*(M+L+3), if ALG = 'F',
C                             BATCH <> 'O' and CONCT = 'C';
C             LDWORK >= (M+L)*2*NOBR*(M+L+1), if ALG = 'F',
C                             BATCH = 'F', 'I' and CONCT = 'N';
C             LDWORK >= (M+L)*4*NOBR*(M+L+1)+(M+L)*2*NOBR, if ALG = 'F',
C                             BATCH = 'L' and CONCT = 'N', or
C                             BATCH = 'O';
C             LDWORK >= 4*(M+L)*NOBR, if ALG = 'Q', BATCH = 'F', and
C                             LDR >= NS = NSMP - 2*NOBR + 1;
C             LDWORK >= max(4*(M+L)*NOBR, 5*L*NOBR), if METH = 'M',
C                             ALG = 'Q', BATCH = 'O', and LDR >= NS;
C             LDWORK >= 5*(M+L)*NOBR+1, if METH = 'N', ALG = 'Q',
C                             BATCH = 'O', and LDR >= NS;
C             LDWORK >= 6*(M+L)*NOBR, if ALG = 'Q', (BATCH = 'F' or 'O',
C                             and LDR < NS), or (BATCH = 'I' or
C                             'L' and CONCT = 'N');
C             LDWORK >= 4*(NOBR+1)*(M+L)*NOBR, if ALG = 'Q', BATCH = 'I'
C                             or 'L' and CONCT = 'C'.
C             The workspace used for ALG = 'Q' is
C                       LDRWRK*2*(M+L)*NOBR + 4*(M+L)*NOBR,
C             where LDRWRK = LDWORK/(2*(M+L)*NOBR) - 2; recommended
C             value LDRWRK = NS, assuming a large enough cache size.
C             For good performance,  LDWORK  should be larger.



        OCTAVE_LOCAL_BUFFER (int, iwork, liwork);
        OCTAVE_LOCAL_BUFFER (double, dwork, ldwork);
        
        // error indicators
        int iwarn = 0;
        int info = 0;


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
                  tol,
                  iwork,
                  dwork, ldwork,
                  bwork,
                  iwarn, info));


        if (f77_exception_encountered)
            error ("ident: exception in SLICOT subroutine IB01BD");

        static const char* err_msg[] = {
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

        static const char* warn_msg[] = {
            "0: OK",
            "1: warning message not specified",
            "2: warning message not specified",
            "3: warning message not specified",
            "4: a least squares problem to be solved has a "
                "rank-deficient coefficient matrix",
            "5: the computed covariance matrices are too small. "
                "The problem seems to be a deterministic one; the "
                "gain matrix is set to zero"};


        error_msg ("ident", info, 10, err_msg);
        warning_msg ("ident", iwarn, 5, warn_msg);


        // resize
        int rs = 2*(m+l)*nobr;
        r.resize (rs, rs);

        
        // return values
        retval(0) = octave_value (n);
        retval(1) = r;
        retval(2) = sv;
    }
    
    return retval;
}
