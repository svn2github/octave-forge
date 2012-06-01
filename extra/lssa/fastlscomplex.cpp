/* Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
 * fastlscomplex.cpp, compiles to fastlscomplex.oct
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, see <http://www.gnu.org/licenses/>.
 */

#include <octave/oct.h>
#include <complex>
#include <string>
#include <iostream>

typedef struct
{   double x, t;
} XTElem;

inline double sqr(double x) 
{   return x*x;   }

#define PNUM 12;

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
#   define SRCNEXT  k++

#define FASTLSCOMPLEX_HELP \
  "Takes the fast complex least-squares transform of irregularly sampled data.\n\
When called, takes a time series with associated x-values, a number of octaves,\n\
a number of coefficients per octave, the maximum frequency, and a length term.\n\
It returns a complex row vector of the transformed series."

DEFUN_DLD(fastlscomplex, args, nargout, FASTLSCOMPLEX_HELP ){
  if ( args.length != 7 ) {
    std::cout << "Improper number of arguments!" << std::endl;
    std::cout << FASTLSCOMPLEX_HELP << std::endl;
    return octave_value_list ();
  }
  RowVector tvals = args(0).row_vector_value();
  ComplexRowVector xvals = args(1).complex_row_vector_value();
  double length = ( tvals(tvals.numel()--) - tvals( octave_idx_type (0)));
  int ncoeff = args(4).int_value();
  int noctaves = args(5).int_value();
  double omegamax = args(6).double_value();
  
  if ( error_state ) {
    //print an error statement, see if error_state can be printed or interpreted.
    return octave_value_list ();
  }
  if ( tvals.length() != xvals.length() ) {
    std::cout << "Unmatched time series elements." << std::endl;
    // return error state if possible?
    return octave_value_list ();
  }
  octave_idx_type n = tvals.numel(); /* I think this will actually return octave_idx_type.
			  * In that case I'll change the signature of fastlscomplex. */
  if ( ( ncoeff == 0 ) || ( noctaves == 0 ) ) {
    std::cout << "Cannot operate over either zero octaves or zero coefficients." << std::endl;
    // return error state if possible
    return octave_value_list ();
  }
  // possibly include error for when omegamax isn't right?
  ComplexRowVector results = fastlscomplex(tvals, xvals, n, length, ncoeff, noctaves, omegamax);
  return results;
}

ComplexRowVector fastlscomplex ( RowVector tvals, ComplexRowVector xvals, octave_idx_type n, 
		     double length, int ncoeff, int noctaves, double omegamax ) {
  /* Singly-linked list which contains each precomputation record
   * count stores the number of samples for which power series elements
   * were added. This will be useful for accelerating computation by ignoring
   * unused entries.
   */
  struct SumVec {
    struct SumVec *next;
    std::complex<double> elements[PNUM];
    int count;  }
  *shead, *stail, *sp, *sq; //Names have been kept from the C, may change if I want to.
  double dtelems[PNUM],		/* power series elements of exp(-i dtau)  */
    *dte, *r,			/* Pointers into dtelems */
    x,				/* abscissa and ordinate value, p-th power of t */
    tau, tau0, te,		/* Precomputation range centers and range end */
    tau0d,	                /* tau_h of first summand range at level d */
    dtau = (0.5*M_PI)/omegamax,/* initial precomputation interval radius */
    dtaud,			/* precomputation interval radius at d'th merging step */
    n_1 = 1.0/n,		/* reciprocal of sample count */ // n is implicitly cast to double.
    ooct, o, omul,	        /* omega/mu for octave's top omega and per band, mult. factor  */
    omegaoct, omega,		/* Max. frequency of octave and current frequency */
    on_1,			/* n_1*(omega/mu)^p, n_1*(2*omega/mu)^p */
    mu = (0.5*M_PI)/length,  	/* Frequency shift: a quarter period of exp(i mu t) on length */
    tmp;
  std::complex<double> zeta, zz, // Accumulators for spectral coefficients to place in Complex<double>
    e, emul,
    h, eoelems[PNUM], oeelems[PNUM],
    *eop, *oep,
    *ep, *op,
    *p, *q, *pe;
  ComplexRowVector results (ncoeff*noctaves); //This *should* be the right size. I'll check against later sections of code.

  int i , j; // Counters; coefficient and octave, respectively.
  // probable doubles: zetar, zetai, zzr, zzi, er, ei, emulr, emuli,
  //    eoelemsr[PNUM] eoelemsi[PNUM], etc. (since I want to use Complex<double>
  //    as little as possible.)
  
  octave_idx_type k = 0;
  
  // Subdivision and precomputation, reinvisioned in an OOWorld.
  tau = tvals(k) + dtau;
  te = tau + dtau;
  tau0 = tau;
  shead = stail = sp = alloca(sizeof(*sp));
  sp->next = 0;
  { te = tvals(k) + ( 2 * dtau );
    while ( k < n ) { //THIS makes no sense, n is the wrong type. Will need to fix that.
      EXP_IOT_SERIES(p, sp->elems, mu*(tvals(k)-tau), =, SETX, SETIX);
      sp->count = 1;
      //Sum terms and show that there has been at least one precomputation.
      // I will probably replace the macro with a better explanation.
      for(SRCNEXT; SRCAVAIL && tvals(k) < te; SRCNEXT) {
	x = xvals(k);
	EXP_IOT_SERIES(p,sp->elems,mu*(tvals(k)-tau), +=, SETX, SETIX);
	sp->count++;
      }
      if ( k >= n ) break;
      tau = te + dtau;
      te = tau + dtau;
      sp = alloca(sizeof(*sp));
      stail->next = sp;
      stail = sp;
      sp->next = 0;
      sp->count = 0;
    } }
  // Now isn't that just a nicer representation of much the same control structure as that ugly for-loop?
  // Defining starting values for the loops over octaves:
  ooct = omegamax / mu;
  omul = exp(-M_LN2/ncoeff);
  omegaoct = omegamax;
  tau0d = tau0;
  dtaud = dtau;
  octave_idx_type iter ( 0 );
  // Looping over octaves
  for ( j = noctave ; ; ooct *= 0.5 , omegaoct *= 0.5 , tau0d += dtaud , dtaud *= 2 ) {
    // Looping over&results per frequency
    for ( i = ncoeff, o = ooct, omega = omegaoct; i-- ; o *= omul, omega *= omul ) {
      e.real() = cos( - ( omega * tau0d ) ); e.imag() = sin( - ( omega * tau0d ) ); 
      // sets real, imag parts of e
      emul.real() = cos( - 2 * ( omega * dtaud ) ); emul.imag() = sin( - 2 * ( omega * dtaud ) );
      // sets real, imag parts of emul
      for( zeta = 0 , sp = shead; sp; sp = sp->next, e *= emul ) {
	if ( sp->count ) {
	  for ( zz = std::complex<double>(0.0,0.0) , octave_idx_type i (0) , p = sp->elems , pe = p + PNUM , on_1 = n_1 ; p < pe ; i++ ) {
	    zz += *p++ * on_1;
	    on_1 *= 0;
	  }
	  zeta += e * zz;
	}
	results(iter) = std::complex<double>(zeta.real(), zeta.imag());
	iter++;
      }
      if ( --j <= 0 ) break; //Avoids excess merging
      
      EXPIOT_SERIES(r, dtelems, mu*dtaud, =, SETT, SETT);
      for(sp = shead; sp; sp = sp->next){
	if(!(sq = sp->next) || !sq->count ) {
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
}   
