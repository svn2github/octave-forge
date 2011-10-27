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

Model reduction based on Balance & Truncate (B&T) or
Singular Perturbation Approximation (SPA) method.
Uses SLICOT AB09ID by courtesy of NICONET e.V.
<http://www.slicot.org>

Author: Lukas Reichlin <lukas.reichlin@gmail.com>
Created: October 2011
Version: 0.1

*/

#include <octave/oct.h>
#include <f77-fcn.h>
#include "common.cc"

extern "C"
{ 
    int F77_FUNC (ab09id, AB09ID)
                 (char& DICO, char& JOBC, char& JOBO, char& JOB,
                  char& WEIGHT, char& EQUIL, char& ORDSEL,
                  int& N, int& M, int& P,
                  int& NV, int& PV, int& NW, int& MW,
                  int& NR,
                  double& ALPHA, double& ALPHAC, double& ALPHAO,
                  double* A, int& LDA,
                  double* B, int& LDB,
                  double* C, int& LDC,
                  double* D, int& LDD,
                  double* AV, int& LDAV,
                  double* BV, int& LDBV,
                  double* CV, int& LDCV,
                  double* DV, int& LDDV,
                  double* AW, int& LDAW,
                  double* BW, int& LDBW,
                  double* CW, int& LDCW,
                  double* DW, int& LDDW,
                  int& NS,
                  double* HSV,
                  double& TOL1, double& TOL2,
                  int* IWORK,
                  double* DWORK, int& LDWORK,
                  int& IWARN, int& INFO);
}
     
DEFUN_DLD (slab09id, args, nargout,
   "-*- texinfo -*-\n\
Slicot AB09ID Release 5.0\n\
No argument checking.\n\
For internal use only.")
{
    int nargin = args.length ();
    octave_value_list retval;
    
    if (nargin != 26)
    {
        print_usage ();
    }
    else
    {
        // arguments in
        char dico;
        char jobc;
        char jobo;
        char job;
        char weigth
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
        const int ijob = args(9).int_value ();
                       
        Matrix av = args(10).matrix_value ();
        Matrix bv = args(11).matrix_value ();
        Matrix cv = args(12).matrix_value ();
        Matrix dv = args(13).matrix_value ();
      
        Matrix aw = args(15).matrix_value ();
        Matrix bw = args(16).matrix_value ();
        Matrix cw = args(17).matrix_value ();
        Matrix dw = args(18).matrix_value ();
        
        const int iweight = args(19).int_value ();
        const int ijobc = args(20).int_value ();
        double alphac = args(21).double_value ();
        const int ijobo = args(22).int_value ();
        double alphao = args(23).double_value ();

        double tol1 = args(24).double_value ();
        double tol2 = args(25).double_value ();

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

        switch (ijob)
        {
            case 0:
                job = 'B';
                break;
            case 1:
                job = 'F';
                break;
            case 2:
                job = 'S';
                break;
            case 3:
                job = 'P';
                break;
            default:
                error ("slab09id: argument job invalid");
        }

        switch (iweight)
        {
            case 0:
                weight = 'N';
                break;
            case 1:
                weight = 'L';
                break;
            case 2:
                weight = 'R';
                break;
            case 3:
                weight = 'B';
                break;
            default:
                error ("slab09id: argument weight invalid");
        }

        int n = a.rows ();      // n: number of states
        int m = b.columns ();   // m: number of inputs
        int p = c.rows ();      // p: number of outputs
        
        int nv = av.rows ();
        int pw = cv.rows ();
        int nw = aw.rows ();
        int mw = bw.columns ();

        int lda = max (1, n);
        int ldb = max (1, n);
        int ldc = max (1, p);
        int ldd = max (1, p);

        int ldav = max (1, nv);
        int ldbv = max (1, nv);
        int ldcv = max (1, pv);
        int lddv = max (1, pv);

        int ldaw = max (1, nw);
        int ldbw = max (1, nw);
        int ldcw = max (1, m);
        int lddw = max (1, m);

        // arguments out
        int ns;
        ColumnVector hsv (n);

        // workspace
        int liwork;
        int liwrk1;
        int liwrk2;
        int liwrk3;

        switch (job)
        {
            case 'B':
                liwrk1 = 0;
                break;
            case 'F':
                liwrk1 = n;
                break;
            default:
                liwrk1 = 2*n;
        }

        if (nv == 0 || weight == 'R' || weight == 'N')
            liwrk2 = 0;
        else
            liwrk2 = nv + max (p, pv);

        if (nw == 0 || weight == 'L' || weight == 'N')
            liwrk3 = 0;
        else
            liwrk3 = nw + max (m, mw);

        liwork = max (3, liwrk1, liwrk2, liwrk3));

        int ldwork;
        int 
        
        ldwork =  max (lminl, lminr, lrcf,
                       2*n*n + max (1, lleft, lright, 2*n*n+5*n, n*max (m, p)));
c             where
c             lminl  = 0, if weight = 'r' or 'n' or nv = 0; otherwise,
c             lminl  = max(llcf,nv+max(nv,3*p))           if p =  pv;
c             lminl  = max(p,pv)*(2*nv+max(p,pv))+
c                      max(llcf,nv+max(nv,3*p,3*pv))      if p <> pv;
c             lrcf   = 0, and
c             lminr  = 0, if weight = 'l' or 'n' or nw = 0; otherwise,
c             lminr  = nw+max(nw,3*m)                     if m =  mw;
c             lminr  = 2*nw*max(m,mw)+nw+max(nw,3*m,3*mw) if m <> mw;
c             llcf   = pv*(nv+pv)+pv*nv+max(nv*(nv+5), pv*(pv+2),
c                                           4*pv, 4*p);
c             lrcf   = mw*(nw+mw)+max(nw*(nw+5),mw*(mw+2),4*mw,4*m)
c             lleft  = (n+nv)*(n+nv+max(n+nv,pv)+5)
c                              if weight = 'l' or 'b' and pv > 0;
c             lleft  = n*(p+5) if weight = 'r' or 'n' or  pv = 0;
c             lright = (n+nw)*(n+nw+max(n+nw,mw)+5)
c                              if weight = 'r' or 'b' and mw > 0;
c             lright = n*(m+5) if weight = 'l' or 'n' or  mw = 0.


        if (jobv == 'N')
            tmpc = 0;
        else
            tmpc = max (2*p, nv+p+n+6, 2*nv+p+2);

        if (jobw == 'N')
            tmpd = 0;
        else
            tmpd = max (2*m, nw+m+n+6, 2*nw+m+2);
        
        if (dico == 'C')
            liwork = max (1, m, tmpc, tmpd);
        else
            liwork = max (1, n, m, tmpc, tmpd);

        int ldwork;
        int nvp = nv + p;
        int nwm = nw + m;
        int ldw1;
        int ldw2;
        int ldw3 = n*(2*n + max (n, m, p) + 5) + n*(n+1)/2;
        int ldw4 = n*(m+p+2) + 2*m*p + min (n, m) + max (3*m+1, min (n, m) + p);
        
        if (jobv == 'N')
        {
            ldw1 = 0;
        }
        else
        {
            ldw1 = 2*nvp*(nvp+p) + p*p + max (2*nvp*nvp + max (11*nvp+16, p*nvp),
                                              nvp*n + max (nvp*n+n*n, p*n, p*m));
        }

        if (jobw == 'N')
        {
            ldw2 = 0;
        }
        else
        {
            ldw2 = 2*nwm*(nwm+m) + m*m + max (2*nwm*nwm + max (11*nwm+16, m*nwm),
                                              nwm*n + max (nwm*n+n*n, m*n, p*m));
        }
        
        ldwork = max (ldw1, ldw2, ldw3, ldw4);

        OCTAVE_LOCAL_BUFFER (int, iwork, liwork);
        OCTAVE_LOCAL_BUFFER (double, dwork, ldwork);
        
        // error indicators
        int iwarn = 0;
        int info = 0;


        // SLICOT routine AB09ID
        F77_XFCN (ab09id, AB09ID,
                 (dico, jobc, jobo, job,
                  weight, equil, ordsel,
                  n, m, p,
                  nv, pv, nw, mw,
                  nr,
                  alpha, alphac, alphao,
                  a.fortran_vec (), lda,
                  b.fortran_vec (), ldb,
                  c.fortran_vec (), ldc,
                  d.fortran_vec (), ldd,
                  av.fortran_vec (), ldav,
                  bv.fortran_vec (), ldbv,
                  cv.fortran_vec (), ldcv,
                  dv.fortran_vec (), lddv,
                  aw.fortran_vec (), ldaw,
                  bw.fortran_vec (), ldbw,
                  cw.fortran_vec (), ldcw,
                  dw.fortran_vec (), lddw,
                  ns,
                  hsv.fortran_vec (),
                  tol1, tol2,
                  iwork,
                  dwork, ldwork,
                  iwarn, info));

        if (f77_exception_encountered)
            error ("hnamodred: exception in SLICOT subroutine AB09ID");
            
        if (info != 0)
        {
            //error ("hsvd: slab09id: AB09ID returned info = %d", info);
            if (info < 0)
                error ("hnamodred: the %d-th argument had an invalid value", info);
            else
            {
                switch (info)
                {
                    // FIXME: The code below looks nice, but the error message does not
                    //        because there is much white space after each line break
                    case 1:
                        error ("hnamodred: 1: the computation of the ordered real Schur form of A\
                                failed");
                    case 2:
                        error ("hnamodred: 2: the separation of the ALPHA-stable/unstable\
                                diagonal blocks failed because of very close eigenvalues");
                    case 3:
                        error ("hnamodred: 3: the reduction of AV to a real Schur form failed");
                    case 4:
                        error ("hnamodred: 4: the reduction of AW to a real Schur form failed");
                    case 5:
                        error ("hnamodred: 5: the reduction to generalized Schur form of the\
                                descriptor pair corresponding to the inverse of V\
                                failed");
                    case 6:
                        error ("hnamodred: 6: the reduction to generalized Schur form of the\
                                descriptor pair corresponding to the inverse of W\
                                failed");
                    case 7:
                        error ("hnamodred: 7: the computation of Hankel singular values failed");
                    case 8:
                        error ("hnamodred: 8: the computation of stable projection in the\
                                Hankel-norm approximation algorithm failed");
                    case 9:
                        error ("hnamodred: 9: the order of computed stable projection in the\
                                Hankel-norm approximation algorithm differs\
                                from the order of Hankel-norm approximation");
                    case 10:
                        error ("hnamodred: 10: the reduction of AV-BV*inv(DV)*CV to a\
                                real Schur form failed");
                    case 11:
                        error ("hnamodred: 11: the reduction of AW-BW*inv(DW)*CW to a\
                                real Schur form failed");
                    case 12:
                        error ("hnamodred: 12: the solution of the Sylvester equation failed\
                                because the poles of V (if JOBV = 'V') or of\
                                conj(V) (if JOBV = 'C') are not distinct from\
                                the poles of G1 (see METHOD)");
                    case 13:
                        error ("hnamodred: 13: the solution of the Sylvester equation failed\
                                because the poles of W (if JOBW = 'W') or of\
                                conj(W) (if JOBW = 'C') are not distinct from\
                                the poles of G1 (see METHOD)");
                    case 14:
                        error ("hnamodred: 14: the solution of the Sylvester equation failed\
                                because the zeros of V (if JOBV = 'I') or of\
                                conj(V) (if JOBV = 'R') are not distinct from\
                                the poles of G1sr (see METHOD)");
                    case 15:
                        error ("hnamodred: 15: the solution of the Sylvester equation failed\
                                because the zeros of W (if JOBW = 'I') or of\
                                conj(W) (if JOBW = 'R') are not distinct from\
                                the poles of G1sr (see METHOD)");
                    case 16:
                        error ("hnamodred: 16: the solution of the generalized Sylvester system\
                                failed because the zeros of V (if JOBV = 'I') or\
                                of conj(V) (if JOBV = 'R') are not distinct from\
                                the poles of G1sr (see METHOD)");
                    case 17:
                        error ("hnamodred: 17: the solution of the generalized Sylvester system\
                                failed because the zeros of W (if JOBW = 'I') or\
                                of conj(W) (if JOBW = 'R') are not distinct from\
                                the poles of G1sr (see METHOD)");
                    case 18:
                        error ("hnamodred: 18: op(V) is not antistable");
                    case 19:
                        error ("hnamodred: 19: op(W) is not antistable");
                    case 20:
                        error ("hnamodred: 20: V is not invertible");
                    case 21:
                        error ("hnamodred: 21: W is not invertible");
                    default:
                        error ("hnamodred: unknown error, info = %d", info);
                }
            }
        }
        
        if (iwarn != 0)
        {
            switch (iwarn)
            {
                case 1:
                    warning ("hnamodred: 1: with ORDSEL = 'F', the selected order NR is greater\
                              than NSMIN, the sum of the order of the\
                              ALPHA-unstable part and the order of a minimal\
                              realization of the ALPHA-stable part of the given\
                              system. In this case, the resulting NR is set equal\
                              to NSMIN.");
                    break;
                case 2:
                    warning ("hnamodred: 2: with ORDSEL = 'F', the selected order NR is less\
                              than the order of the ALPHA-unstable part of the\
                              given system. In this case NR is set equal to the\
                              order of the ALPHA-unstable part.");
                    break;
                default:
                    warning ("hnamodred: unknown warning, iwarn = %d", info);
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
        // retval(0) = hsv;
        // retval(1) = octave_value (ns);
    }
    
    return retval;
}
