/*

Copyright (C) 2011   Lukas F. Reichlin

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

Controller reduction based on Balance & Truncate (B&T) or
Singular Perturbation Approximation (SPA) method.
Uses SLICOT SB16AD by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: November 2011
Version: 0.1

*/

#include <octave/oct.h>
#include <f77-fcn.h>
#include "common.cc"

extern "C"
{ 
    int F77_FUNC (sb16ad, SB16AD)
                 (char& DICO, char& JOBC, char& JOBO, char& JOBMR,
                  char& WEIGHT, char& EQUIL, char& ORDSEL,
                  int& N, int& M, int& P,
                  int& NC, int& NCR,
                  double& ALPHA,
                  double* A, int& LDA,
                  double* B, int& LDB,
                  double* C, int& LDC,
                  double* D, int& LDD,
                  double* AC, int& LDAC,
                  double* BC, int& LDBC,
                  double* CC, int& LDCC,
                  double* DC, int& LDDC,
                  int& NCS,
                  double* HSVC,
                  double& TOL1, double& TOL2,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  int& IWARN, int& INFO);
}
     
DEFUN_DLD (slsb16ad, args, nargout,
   "-*- texinfo -*-\n\
Slicot SB16AD Release 5.0\n\
No argument checking.\n\
For internal use only.")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 25)
    {
        print_usage ();
    }
    else
    {
        // arguments in
        char dico;
        char jobc;
        char jobo;
        char jobmr;
        char weight;
        char equil;
        char ordsel;
        
        Matrix a = args(0).matrix_value ();
        Matrix b = args(1).matrix_value ();
        Matrix c = args(2).matrix_value ();
        Matrix d = args(3).matrix_value ();
        
        const int idico = args(4).int_value ();
        const int iequil = args(5).int_value ();
        int nr = args(6).int_value ();
        const int iordsel = args(7).int_value ();
        double alpha = args(8).double_value ();
        const int ijobmr = args(9).int_value ();
                       
        Matrix ac = args(10).matrix_value ();
        Matrix bc = args(11).matrix_value ();
        Matrix cc = args(12).matrix_value ();
        Matrix dc = args(13).matrix_value ();
        
        const int iweight = args(14).int_value ();
        const int ijobc = args(15).int_value ();
        const int ijobo = args(16).int_value ();

        double tol1 = args(17).double_value ();
        double tol2 = args(18).double_value ();

        if (idico == 0)
            dico = 'C';
        else
            dico = 'D';

        if (iequil == 0)
            equil = 'S';
        else
            equil = 'N';

        if (iordsel == 0)
            ordsel = 'F';
        else
            ordsel = 'A';

        if (ijobc == 0)
            jobc = 'S';
        else
            jobc = 'E';

        if (ijobo == 0)
            jobo = 'S';
        else
            jobo = 'E';

        switch (ijobmr)
        {
            case 0:
                jobmr = 'B';
                break;
            case 1:
                jobmr = 'F';
                break;
            case 2:
                jobmr = 'S';
                break;
            case 3:
                jobmr = 'P';
                break;
            default:
                error ("slsb16ad: argument jobmr invalid");
        }

        switch (iweight)
        {
            case 0:
                weight = 'N';
                break;
            case 1:
                weight = 'O';
                break;
            case 2:
                weight = 'I';
                break;
            case 3:
                weight = 'P';
                break;
            default:
                error ("slsb16ad: argument weight invalid");
        }

        int n = a.rows ();      // n: number of states
        int m = b.columns ();   // m: number of inputs
        int p = c.rows ();      // p: number of outputs
        
        int nc = ac.rows ();

        int lda = max (1, n);
        int ldb = max (1, n);
        int ldc = max (1, p);
        int ldd = max (1, p);

        int ldac = max (1, nc);
        int ldbc = max (1, nc);
        int ldcc = max (1, m);
        int lddc = max (1, m);

        // arguments out
        int ncs;
        ColumnVector hsvc (n);

        // workspace
        int liwork;
        int liwrk1;
        int liwrk2;

        switch (jobmr)
        {
            case 'B':
                liwrk1 = 0;
                break;
            case 'F':
                liwrk1 = nc;
                break;
            default:
                liwrk1 = 2*nc;
        }

        if (weight == 'N')
            liwrk2 = 0;
        else
            liwrk2 = 2*(m+p);

        liwork = max (1, liwrk1, liwrk2);

        int ldwork;
        int lminl;
        int lrcf;
        int lminr;
        int llcf;
        int lleft;
        int lright;

        if (nw == 0 || weight == 'L' || weight == 'N')
        {
            lrcf = 0;
            lminr = 0;
        }
        else
        {
            lrcf = mw*(nw+mw) + max (nw*(nw+5), mw*(mw+2), 4*mw, 4*m);
            if (m == mw)
                lminr = nw + max (nw, 3*m);
            else
                lminr = 2*nw*max (m, mw) + nw + max (nw, 3*m, 3*mw);
        }

        llcf = pv*(nv+pv) + pv*nv + max (nv*(nv+5), pv*(pv+2), 4*pv, 4*p);

        if (nv == 0 || weight == 'R' || weight == 'N')
            lminl = 0;
        else if (p == pv)
            lminl  = max (llcf, nv + max (nv, 3*p));
        else
            lminl  = max (p, pv) * (2*nv + max (p, pv)) + max (llcf, nv + max (nv, 3*p, 3*pv));


        if (pv == 0 || weight == 'R' || weight == 'N')
            lleft = n*(p+5);
        else
            lleft = (n+nv) * (n + nv + max (n+nv, pv) + 5);

        if (mw == 0 || weight == 'L' || weight == 'N')
            lright = n*(m+5);
        else
            lright = (n+nw) * (n + nw + max (n+nw, mw) + 5);

        ldwork =  max (lminl, lminr, lrcf,
                       2*n*n + max (1, lleft, lright, 2*n*n+5*n, n*max (m, p)));

        OCTAVE_LOCAL_BUFFER (int, iwork, liwork);
        OCTAVE_LOCAL_BUFFER (double, dwork, ldwork);
        
        // error indicators
        int iwarn = 0;
        int info = 0;


        // SLICOT routine SB16AD
        F77_XFCN (sb16ad, SB16AD,
                 (dico, jobc, jobo, jobmr,
                  weight, equil, ordsel,
                  n, m, p,
                  nc, ncr,
                  alpha,
                  a.fortran_vec (), lda,
                  b.fortran_vec (), ldb,
                  c.fortran_vec (), ldc,
                  d.fortran_vec (), ldd,
                  ac.fortran_vec (), ldac,
                  bc.fortran_vec (), ldbc,
                  cc.fortran_vec (), ldcc,
                  dc.fortran_vec (), lddc,
                  ncs,
                  hsvc.fortran_vec (),
                  tol1, tol2,
                  iwork,
                  dwork, ldwork,
                  iwarn, info));


        if (f77_exception_encountered)
            error ("conred: exception in SLICOT subroutine SB16AD");
            
        if (info != 0)
        {
            if (info < 0)
                error ("conred: the %d-th argument had an invalid value", info);
            else
            {
                switch (info)
                {
                    case 1:
                        error ("conred: 1: the closed-loop system is not well-posed; "
                               "its feedthrough matrix is (numerically) singular");
                    case 2:
                        error ("conred: 2: the computation of the real Schur form of the "
                               "closed-loop state matrix failed");
                    case 3:
                        error ("conred: 3: the closed-loop state matrix is not stable");
                    case 4:
                        error ("conred: 4: the solution of a symmetric eigenproblem failed");
                    case 5:
                        error ("conred: 5: the computation of the ordered real Schur form "
                               "of Ac failed");
                    case 6:
                        error ("conred: 6: the separation of the ALPHA-stable/unstable "
                               "diagonal blocks failed because of very close eigenvalues");
                    case 7:
                        error ("conred: 7: the computation of Hankel singular values failed");
                    default:
                        error ("conred: unknown error, info = %d", info);
                }
            }
        }
        
        if (iwarn != 0)
        {
            switch (iwarn)
            {
                case 1:
                    warning ("conred: 1: with ORDSEL = 'F', the selected order NCR is greater "
                             "than NSMIN, the sum of the order of the "
                             "ALPHA-unstable part and the order of a minimal "
                             "realization of the ALPHA-stable part of the given "
                             "controller; in this case, the resulting NCR is set "
                             "equal to NSMIN.");
                    break;
                case 2:
                    warning ("conred: 2: with ORDSEL = 'F', the selected order NCR "
                             "corresponds to repeated singular values for the "
                             "ALPHA-stable part of the controller, which are "
                             "neither all included nor all excluded from the "
                             "reduced model; in this case, the resulting NCR is "
                             "automatically decreased to exclude all repeated "
                             "singular values.");
                    break;
                case 3:
                    warning ("conred: 3: with ORDSEL = 'F', the selected order NCR is less "
                             "than the order of the ALPHA-unstable part of the "
                             "given controller. In this case NCR is set equal to "
                             "the order of the ALPHA-unstable part.");
                    break;
                default:
                    warning ("conred: unknown warning, iwarn = %d", iwarn);
            }
        }

        // resize
        a.resize (nr, nr);
        b.resize (nr, m);
        c.resize (p, nr);
        hsv.resize (ns);
        
        // return values
        retval(0) = a;
        retval(1) = b;
        retval(2) = c;
        retval(3) = d;
        retval(4) = octave_value (nr);
        retval(5) = hsv;
        retval(6) = octave_value (ns);
    }
    
    return retval;
}
