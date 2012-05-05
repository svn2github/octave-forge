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

// PKG_ADD: autoload ("slident_a", "devel_slicot_functions.oct");
DEFUN_DLD (slident_a, args, nargout,
   "-*- texinfo -*-\n\
Slicot IB01AD Release 5.0\n\
No argument checking.\n\
For internal use only.")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 12)
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
        char jobda; // ??? unused
        
        Matrix y = args(0).matrix_value ();
        Matrix u = args(1).matrix_value ();
        int nobr = args(2).int_value ();
        int nuser = args(3).int_value ();
        
        const int imeth = args(4).int_value ();
        const int ialg = args(5).int_value ();
        const int ijobd = args(6).int_value ();
        const int ibatch = args(7).int_value ();
        const int iconct = args(8).int_value ();
        const int ictrl = args(9).int_value ();
        
        double rcond = args(10).double_value ();
        double tol = args(11).double_value ();
        double tolb = args(10).double_value ();      // tolb = rcond

            
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
        int ns = nsmp - 2*nobr + 1;
        
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
            // int ns = nsmp - 2*nobr + 1;
            
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

/*
IB01AD.f Lines 438-445
C     FURTHER COMMENTS
C
C     For ALG = 'Q', BATCH = 'O' and LDR < NS, or BATCH <> 'O', the
C     calculations could be rather inefficient if only minimal workspace
C     (see argument LDWORK) is provided. It is advisable to provide as
C     much workspace as possible. Almost optimal efficiency can be
C     obtained for  LDWORK = (NS+2)*(2*(M+L)*NOBR),  assuming that the
C     cache size is large enough to accommodate R, U, Y, and DWORK.
*/

// warning ("==================== ldwork before: %d =====================", ldwork);
// ldwork = (ns+2)*(2*(m+l)*nobr);
ldwork = max (ldwork, (ns+2)*(2*(m+l)*nobr));
// ldwork *= 3;
// warning ("==================== ldwork after: %d =====================", ldwork);


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
        
        
        // return values
        retval(0) = r;
        retval(1) = sv;
        retval(2) = octave_value (n);
    }
    
    return retval;
}
