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

TODO
Uses SLICOT SB16BD by courtesy of NICONET e.V.
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
    int F77_FUNC (sb16bd, SB16BD)
                 (char& DICO, char& JOBD, char& JOBMR, char& JOBCF,
                  char& EQUIL, char& ORDSEL,
                  int& N, int& M, int& P,
                  int& NCR,
                  double* A, int& LDA,
                  double* B, int& LDB,
                  double* C, int& LDC,
                  double* D, int& LDD,
                  double* F, int& LDF,
                  double* G, int& LDG,
                  double* DC, int& LDDC,
                  double* HSV,
                  double& TOL1, double& TOL2,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  int& IWARN, int& INFO);
}
     
DEFUN_DLD (slsb16bd, args, nargout,
   "-*- texinfo -*-\n\
Slicot SB16BD Release 5.0\n\
No argument checking.\n\
For internal use only.")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 19)
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
        int ncr = args(6).int_value ();
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
                error ("slsb16bd: argument jobmr invalid");
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
                error ("slsb16bd: argument weight invalid");
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
        int lfreq;
        int lsqred;

        if (weight == 'N')
        {
            if (equil == 'N')           // if WEIGHT = 'N' and EQUIL = 'N'
                lfreq  = nc*(max (m, p) + 5);
            else                        // if WEIGHT = 'N' and EQUIL  = 'S'
                lfreq  = max (n, nc*(max (m, p) + 5));

        }
        else                            // if WEIGHT = 'I' or 'O' or 'P'
        {
            lfreq = (n+nc)*(n+nc+2*m+2*p) +
                     max ((n+nc)*(n+nc+max(n+nc,m,p)+7), (m+p)*(m+p+4));
        }

        lsqred = max (1, 2*nc*nc+5*nc);
        ldwork = 2*nc*nc + max (1, lfreq, lsqred);

        OCTAVE_LOCAL_BUFFER (int, iwork, liwork);
        OCTAVE_LOCAL_BUFFER (double, dwork, ldwork);
        
        // error indicators
        int iwarn = 0;
        int info = 0;


        // SLICOT routine SB16BD
        F77_XFCN (sb16bd, SB16BD,
                 (dico, jobd, jobmr, jobcf,
                  equil, ordsel,
                  n, m, p,
                  ncr,
                  a.fortran_vec (), lda,
                  b.fortran_vec (), ldb,
                  c.fortran_vec (), ldc,
                  d.fortran_vec (), ldd,
                  f.fortran_vec (), ldf,
                  g.fortran_vec (), ldg,
                  dc.fortran_vec (), lddc,
                  hsv.fortran_vec (),
                  tol1, tol2,
                  iwork,
                  dwork, ldwork,
                  iwarn, info));


        if (f77_exception_encountered)
            error ("conred: exception in SLICOT subroutine SB16BD");
            
        if (info != 0)
        {
            if (info < 0)
                error ("conred: the %d-th argument had an invalid value", info);
            else
            {
                switch (info)
                {
                    case 1:
                        error ("conred: 1: the reduction of A+G*C to a real Schur form "
                               "failed");
                    case 2:
                        error ("conred: 2: the matrix A+G*C is not stable (if DICO = 'C'), "
                               "or not convergent (if DICO = 'D')");
                    case 3:
                        error ("conred: 3: the computation of Hankel singular values failed");
                    case 4:
                        error ("conred: 4: the reduction of A+B*F to a real Schur form "
                               "failed");
                    case 5:
                        error ("conred: 5: the matrix A+B*F is not stable (if DICO = 'C'), "
                               "or not convergent (if DICO = 'D')");
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
                    warning ("conred: 1: with ORDSEL = 'F', the selected order NCR is "
                             "greater than the order of a minimal "
                             "realization of the controller.");
                    break;
                default:
                    warning ("conred: unknown warning, iwarn = %d", iwarn);
            }
        }

        // resize
        ac.resize (ncr, ncr);
        bc.resize (ncr, p);    // p: number of plant outputs
        cc.resize (m, ncr);    // m: number of plant inputs
        hsvc.resize (ncs);
        
        // return values
        retval(0) = ac;
        retval(1) = bc;
        retval(2) = cc;
        retval(3) = dc;
        retval(4) = octave_value (ncr);
        retval(5) = hsvc;
        retval(6) = octave_value (ncs);
    }
    
    return retval;
}
