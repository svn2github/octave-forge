// fastlscomplex, implemented for Octave


#include <octave/oct.h>
#ifdef __cplusplus
extern "C"
{
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <complex.h>
#ifdef __cplusplus
}
#endif

#define MAXCOLUMN 8

/* We use the ISO C99 complex facility as implemented by GCC, but only in two places */

typedef _Complex double Complex;
typedef double Real;

#define RE(x_)                  (__real__ x_)
#define IM(x_)                  (__imag__ x_)
#define CSET(x_, r_, i_)        (RE(x_) = (r_), IM(x_) = (i_))
#define PHISET(x_, p_)          CSET(x_, cos(tmp=p_), sin(tmp))
#define SCALEPHISET(x_, f_, p_) CSET(x_, f_ cos(tmp=p_), f_ sin(tmp))

// Here the Data structure is included, but it's only ever a feature of the
// #STANDALONE cases, which we're not dealing with here.

typedef struct
{   Real x, t;
} XTElem;

inline double sqr(double x) 
{   return x*x;   }

/* PNUM has to match the definition of EXP_IOT_SERIES! */
#define PNUM 12
#define SETXT(p_, op_, x_, t_) (p_)->x op_ x_; (p_++)->t op_ t_;
#define SETT(p_, op_, x_, t_)  *p_++ op_ t_;
#define SETX(p_, op_, x_, t_) *p_++ op_ x_;
/* h is a complex aux. variable; it is used for assignment times I everywhere */
#define SETIX(p_, op_, x_, t_) h = x_; RE(*(p_)) op_ -IM(h); IM(*(p_)) op_ RE(h); p_++;

        /* Macro that sums up the power series terms into the power series
	 * element record pointed to by p_.
	 * By using = and += for op_, initial setting and accumulation can be selected.
	 * t_ is the expression specifying the abscissa value. set_ can be either
	 * SETXT to set the x and t fields of an XTElem record, or SETT/SETX to set
	 * the elements of a Real array representing alternately real and imaginary
	 * values.
         */
        // -10 points, comments don't match method.
#define EXP_IOT_SERIES(p_, el_, t_, op_, setr_, seti_)		\
{       Real t = t_, tt; p_ = el_;    setr_(p_, op_, x, 1)	\
        tt  = -t;            seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/2.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(-1.0/3.0);  seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/4.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(-1.0/5.0);  seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/6.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(-1.0/7.0);  seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/8.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(-1.0/9.0);  seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/10.0);  setr_(p_, op_, x*tt, tt)		\
        tt *= t*(-1.0/11.0); seti_(p_, op_, x*tt, tt)		\
}

/* same as the above, but without alternating signs */
#define EXPIOT_SERIES(p_, el_, t_, op_, setr_, seti_)		\
{       Real t = t_, tt; p_ = el_;    setr_(p_, op_, x, 1)	\
			     seti_(p_, op_, x*t,  t )		\
        tt  = t*t*(1.0/2.0); setr_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/3.0);   seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/4.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/5.0);   seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/6.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/7.0);   seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/8.0);   setr_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/9.0);   seti_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/10.0);  setr_(p_, op_, x*tt, tt)		\
        tt *= t*(1.0/11.0);  seti_(p_, op_, x*tt, tt)		\
}

#   define SRCARG   Real *tptr, Real *xptr, int n, double *lengthptr
#   define SRCVAR   int k; Real length = *lengthptr;
#   define SRCT     tptr[k]
#   define SRCX     xptr[k]
#   define SRCFIRST k = 0
#   define SRCAVAIL (k<n)



DEFUN_DLD (fastlscomplex, args, nargout, "Computes a rapid complex least squares transform.") 
{
  int nargs = args.length();
  if ( nargs != 7 ) print_usage();
  else {
    const RowVector tvals = args(0).row_vector_value();
    const ComplexRowVector xvals = args(1).complex_row_vector_value();
    const int nval = args(2).int_value();
    const int lenval = args(3).int_value();
    const int ncoeffval = args(4).int_value();
    const int noctaveval = args(5).int_value();
    const int omegamaxval = args(6).int_value();
    if ( !error_value ) {
      ComplexRowVector ret_series ( ( ncoeffval * noctaveval ) , 0.0 );
      octave_idx_type numt = tvals.numel(), numx = xvals.numel(),
	numret = ret_series.numel();
    }
  }

}

void print_usage() {
  octave_stdout << "Prints the usage string for fastlscomplex, "
		<< "once I get around to it.\n";
  // Really, I'll replace this soon.

}

void fastlscomplex(Real *tptr, Complex *xptr, int *nptr, double *lengthptr, int *ncoeffptr, int *noctaveptr, Real *omegamaxptr, Complex *rp)
{
    int  k, n = *nptr, ncoeff = *ncoeffptr, noctave = *noctaveptr;
    Real length = *lengthptr, omegamax = *omegamaxptr;
    
    struct SumVec			/* Precomputation record */
    {   struct SumVec *next;		/* A singly linked list */
	Complex elems[PNUM];		/* the summed power series elements */
        int cnt;			/* number of samples for which the power series elements were added */
    }
             *shead, *stail, *sp, *sq;  /* power series element lists */
    Real     dtelems[PNUM],		/* power series elements of exp(-i dtau)  */
	     *dte, *r,			/* Pointers into dtelems */
             x,				/* abscissa and ordinate value, p-th power of t */
             tau, tau0, te,		/* Precomputation range centers and range end */
             tau0d,	                /* tau_h of first summand range at level d */
             dtau = (0.5*M_PI)/omegamax,/* initial precomputation interval radius */
             dtaud,			/* precomputation interval radius at d'th merging step */
             n_1 = 1.0/n,		/* reciprocal of sample count */
             ooct, o, omul,	        /* omega/mu for octave's top omega and per band, mult. factor  */
             omegaoct, omega,		/* Max. frequency of octave and current frequency */
             on_1,			/* n_1*(omega/mu)^p, n_1*(2*omega/mu)^p */
             mu = (0.5*M_PI)/length,  	/* Frequency shift: a quarter period of exp(i mu t) on length */
	     tmp;
    Complex  zeta, zz,			/* Accumulators for spectral coefficients */
             e, emul,		        /* summation factor exp(-i o tau_h) */
	     h, eoelems[PNUM], oeelems[PNUM],
	     *eop, *oep,
	     *ep, *op,			/* Pointer into the current choice of eoelems and oeelems */
	     *p, *q, *pe;
    int      i, j;			/* Coefficient and octave counter */

    /* Subdivision and Precomputation */
    SRCFIRST;
    tau = SRCT+dtau; te = tau+dtau;
    tau0 = tau;
    shead = stail = sp = alloca(sizeof(*sp)); sp->next = 0;
    for(te = SRCT+2*dtau; ; )
    {   x = SRCX;
        EXP_IOT_SERIES(p, sp->elems, mu*(SRCT-tau), =, SETX, SETIX); sp->cnt = 1;
	for(SRCNEXT; SRCAVAIL && SRCT<te; SRCNEXT)
        {   x = SRCX; 
            EXP_IOT_SERIES(p, sp->elems, mu*(SRCT-tau), +=, SETX, SETIX); sp->cnt++;
        }
        if(!SRCAVAIL) break;
        tau = te+dtau; te = tau+dtau;
        sp = alloca(sizeof(*sp)); stail->next = sp; stail = sp; sp->next = 0; sp->cnt = 0;
    }

    ooct = omegamax/mu;
    omul = exp(-M_LN2/ncoeff);
    omegaoct = omegamax;
    tau0d = tau0;
    dtaud = dtau;
    /*** Loop over Octaves ***/
    for(j = noctave; ; ooct *= 0.5, omegaoct *= 0.5, tau0d += dtaud, dtaud *= 2)
    {   /*** Results per frequency ***/
        for(i = ncoeff, o = ooct, omega = omegaoct; i--; o *= omul, omega *= omul)
        {   PHISET(e, -omega*tau0d);
            PHISET(emul, -2*omega*dtaud);
            for(zeta = 0, sp = shead; sp; sp = sp->next, e *= emul)
                if(sp->cnt)
                {   for(zz = 0, p = sp->elems, pe = p+PNUM, on_1 = n_1; p < pe; )
                    {   zz += *p++ * on_1; on_1 *= o;   }
                    zeta += e * zz;
                }
	    *rp++ = zeta;
        }
	if(--j<=0) break;		    /* avoid unnecessary merging at the end */
        /* Merging of the s_h;
         * 4 different possibilities, depending on which of the merged ranges actually contain data.
         * The computation is described in the paper; The result of a merger is stored in the
	 * left precomputation record (sp). Before one power series element is stored, the 
	 * sum and difference of the original values *p and *q are stored in eoelems and oeelems,
	 * respectively. The result is then stored in *p.
         */
	EXPIOT_SERIES(r, dtelems, mu*dtaud, =, SETT, SETT);
        for(sp = shead; sp; sp = sp->next)
        {   if(!(sq = sp->next) || !sq->cnt)
            {   if(sp->cnt)
		    for(p = sp->elems, eop = eoelems, dte = dtelems+1, pe = p+PNUM; p < pe; p++, dte++)
                    {   ep = eop; *eop++ = *p;
			for(r = dtelems, *p = *ep * *r; ; )
			{   if(++r>=dte) break; --ep; h   =  *ep * *r; RE(*p) -= IM(h); IM(*p) += RE(h);
			    if(++r>=dte) break; --ep; *p -=  *ep * *r;
			    if(++r>=dte) break; --ep; h   = -*ep * *r; RE(*p) -= IM(h); IM(*p) += RE(h);
			    if(++r>=dte) break; --ep; *p +=  *ep * *r;
			}
		    }
		if(!sq) break;		    /* reached the last precomputation range */
	    }
            else
                if(sp->cnt)
                    for(p = sp->elems, q = sq->elems, eop = eoelems, oep = oeelems, dte = dtelems+1, pe = p+PNUM;
			p < pe; p++, q++, dte++)
                    {   ep = eop; *eop++ = *p+*q; *oep++ = *p-*q; op = oep;
			for(r = dtelems, *p = *ep * *r; ; )
			{   if(++r>=dte) break; op -= 2; h   =  *op * *r; RE(*p) -= IM(h); IM(*p) += RE(h);
			    if(++r>=dte) break; ep -= 2; *p -=  *ep * *r;
			    if(++r>=dte) break; op -= 2; h   = -*op * *r; RE(*p) -= IM(h); IM(*p) += RE(h);
			    if(++r>=dte) break; ep -= 2; *p +=  *ep * *r;
			}
		    }
		else
		for(q = sq->elems, eop = eoelems, oep = oeelems, dte = dtelems+1, pe = q+PNUM; q<pe; q++, dte++)
                {   ep = eop; *eop++ = *q;
		    for(r = dtelems, *q = *ep * *r; ; )
		    {   if(++r>=dte) break; --ep; h   =  *ep * *r; RE(*q) -= IM(h); IM(*q) += RE(h);
			if(++r>=dte) break; --ep; *p -=  *ep * *r;
			if(++r>=dte) break; --ep; h   = -*ep * *r; RE(*q) -= IM(h); IM(*q) += RE(h);
			if(++r>=dte) break; --ep; *q +=  *ep * *r;
		    }
		}
                    
	    sp->cnt += sq->cnt; sp->next = sq->next; /* free(sq) if malloc'ed */
        }
    }
}
