/* Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#include <octave/oct.h>
#include <octave/unwind-prot.h>
#include <complex>
#include <string>
#include <math.h>
#include <iostream>
#include <exception>

ComplexRowVector flsreal( RowVector tvec , ComplexRowVector xvec ,
			     double maxfreq , int octaves , int coefficients);


DEFUN_DLD(fastlsreal,args,nargout,
	  "-*- texinfo -*-\n\
@deftypefn {Function File} { C = } fastlsreal(@var{time},@var{magnitude},@var{maximum_frequency},@var{octaves},@var{coefficients})\n\
\n\
Return the real least-sqaures spectral fit to the (@var{time},@var{magnitude})\n\
data supplied, using the fast algorithm.\n\
\n\
@seealso{fastlscomplex}\n\
@seealso{lsreal}\n\
@end deftypefn") {
  if ( args.length() != 5 ) {
    print_usage();
    return octave_value_list ();
  }
  RowVector tvals = args(0).row_vector_value();
  ComplexRowVector xvals = args(1).complex_row_vector_value();
  double omegamax = args(2).double_value();
  int noctaves = args(3).int_value();
  int ncoeff = args(4).int_value();
  if ( tvals.numel() != xvals.numel() ){
    if ( tvals.numel() > xvals.numel() ) {
      error("More time values than magnitude values.");
    } else {
      error("More magnitude values than time values.");
    }
  }
  if ( ncoeff == 0 ) error("No coefficients to compute.");
  if ( noctaves == 0 ) error("No octaves to compute over.");
  if ( omegamax == 0 ) error("No difference between minimal and maximal frequency.");
  octave_value_list retval;  
  if ( !error_state) {
    ComplexRowVector results = flsreal(tvals,xvals,omegamax,noctaves,ncoeff);
    retval(0) = octave_value(results);
  } else {
    return octave_value_list ();
  }
  return retval;

}

ComplexRowVector flsreal( RowVector tvec , RowVector xvec ,
			  double maxfreq, int octaves, int coefficients ) {
  struct XTElem {
    double x, t;
  };
  struct Precomputation_Record {
    Precomputation_Record *next;
    XTElem power_series[12]; // I'm using 12 as a matter of compatibility, only.
    bool stored_data;
  };

  ComplexRowVector results = ComplexRowVector (coefficients * octaves );

  double tau, delta_tau, tau_0, tau_h, n_inv, mu,
    omega_oct, omega_multiplier, octavemax, omega_working,
    loop_tau_0, loop_delta_tau, x;
  double length = ( tvec((tvec.numel()-1)) - tvec( octave_idx_type (0)));
  int octave_iter, coeff_iter;
  std::complex<double> zeta, z_accumulator, zeta_exp_term, zeta_exp_multiplier, alpha,
    iota, i_accumulator, iota_exp_term, iota_exp_multiplier, exp_squared, exp_squared_multiplier;
  octave_idx_type n = tvec.numel();
  XTElem *tpra, *temp_ptr_alpha, temp_alpha[12], *tprb, *temp_ptr_beta, temp_beta[12], temp_array[12];


  int factorial_array[12];
  factorial_array[0] = 1;
  for ( int i = 1 ; i < 12 ; i++ ) {
    factorial_array[i] = factorial_array[i-1] * i;
  }
  n_inv = 1.0 / n;
  mu = (0.5 * M_PI)/length; // Per the article; this is in place to improve numerical accuracy if desired.
  /* Viz. the paper, in which Dtau = c / omega_max, and c is stated as pi/2 for floating point processors,
   * In the case of this computation, I'll go by the recommendation.
   */
  delta_tau = M_PI / ( 2 * maxfreq );
  tau_0 = tvec(0) + delta_tau;
  tau_h = tau_0;
  size_t precomp_subset_count = (size_t) ceil( ( tvec(tvec.numel()-1) - tvec(0) ) / ( 2 * delta_tau ) );
  // I've used size_t because it will work for my purposes without threatening undefined behaviour.
  const std::complex<double> im = std::complex<double> ( 0 , 1 ); //I seriously prefer C99's complex numbers.

  octave_idx_type k ( 0 ); // Iterator for accessing xvec, tvec.
  
    Precomputation_Record * precomp_records_head, *record_current, *record_tail, *record_ref, *record_next;
  record_current = precomp_records_head = new  Precomputation_Record;
  for ( te = tvec(k) + (2 * delta_tau) ; ; ) {
    x = xvec(k);
    {
      double t = mu*(tvec(k)-tau_h), tt;
      p = record_current->power_series;
      // p = 0
      p->x = x;
      (p++)->t = 1;
      // p = 1
      tt = -t;
      p->x = x * tt;
      (p++)->t = tt;
      // p = 2
      tt *= t*(1.0/2.0);
      p->x = x*tt;
      (p++)->t = tt;
      // p = 3
      tt *= t*(-1.0/3.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 4
      tt *= t*(1.0/4.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 5
      tt *= t*(-1.0/5.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 6
      tt *= t*(1.0/6.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 7
      tt *= t*(-1.0/7.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 8
      tt *= t*(1.0/8.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 9
      tt *= t*(-1.0/9.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 10
      tt *= t*(1.0/10.0);
      p->x = x * tt;
      (p++)->t = tt;
      // p = 11
      tt *= t*(-1.0/11.0);
      p->x = x * tt;
      (p++)->t = tt;
    }
    record_current->stored_data = true;
    for(k++; ( k < n ) && tvec(k) < te ; k++ ) {
      x = xvec(k);
      {
	double t = mu*(tvec(k)-tau_h), tt;
	p = record_current->power_series;
	// p = 0
	p->x += x;
	(p++)->t += 1;
	// p = 1
	tt = -t;
	p->x += x * tt;
	(p++)->t += tt;
	// p = 2
	tt *= t*(1.0/2.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 3
	tt *= t*(-1.0/3.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 4
	tt *= t*(1.0/4.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 5
	tt *= t*(-1.0/5.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 6
	tt *= t*(1.0/6.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 7
	tt *= t*(-1.0/7.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 8
	tt *= t*(1.0/8.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 9
	tt *= t*(-1.0/9.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 10
	tt *= t*(1.0/10.0);
	p->x += x * tt;
	(p++)->t += tt;
	// p = 11
	tt *= t*(-1.0/11.0);
	p->x += x * tt;
	(p++)->t += tt;
      }
      record_current->stored_data = true;
    }
    if( k >= n ) break;
    tau_h = te + delta_tau;
    te = tau_h + delta_tau;
    record_current->next = new Precomputation_Record;
    record_current = record_current->next;
  }
  record_tail = record_current;
  record_current = precomp_records_head;
  record_tail->next = 0;
  
  /* Summation of coefficients for each frequency. As we have ncoeffs * noctaves elements,
   * it makes sense to work from the top down, as we have omega_max by default (maxfreq)
   */

  omega_oct = maxfreq / mu;
  omega_multiplier = exp(-log(2)/coefficients);
  octavemax = maxfreq;
  loop_tau_0 = tau_0;
  loop_delta_tau = delta_tau;
  
  octave_idx_type iter ( 0 );
  
  // Loops need to first travel over octaves, then coefficients;
  
  for ( octave_iter = octaves ; ; omega_oct *= 0.5 , octavemax *= 0.5 , loop_tau_0 += loop_delta_tau , loop_delta_tau *= 2 ) {
    o = omega_oct;
    omega_working = octavemax;
    for ( coeff_iter = 0 ; coeff_iter < coefficients ; coeff_iter++, o *= omega_multiplier, omega_working *= omega_multiplier){
      exp_term = std::complex<double> ( cos( - omega_working * loop_tau_0 ) ,
					sin ( - omega_working * loop_tau_0 ) );
      exp_squared = exp_term * exp_term;
      exp_multiplier = std::complex<double> ( cos ( - 2 * omega_working * loop_delta_tau ) ,
					      sin ( - 2 * omega_working * loop_delta_tau ) );
      exp_squared_multiplier = exp_multiplier * exp_multiplier;
      for ( zeta = iota = 0, record_current = precomp_records_head ; record_current ;
	    record_current = record_current->next, exp_term *= exp_multiplier,
    exp_squared *= exp_squared_multiplier ) {
	if ( record_current->stored_data ) {
	  int p;
	  for ( zz = ii = 0 , p = 0, on_1 = n_1 ; p < 12 ; ) {
	    zz.real() += record_current->power_series[p]->x * on_1;
	    ii.real() += record_current->power_series[p++]-> t * o2n_1;
	    on_1 *= o;
	    o2n_1 *= o2;
	    zz.imag() += record_current->power_series[p]->x * on_1;
	    ii.imag() += record_current->power_series[p++]-> t * o2n_1;
	    on_1 *= o;
	    o2n_1 *= o2;
	  }
	  zeta += exp_term * zz;
	  iota += exp_squared * ii;
	}
      }
      results(iter) = 2 / ( 1 - ( iota.real() * iota.real() ) - (iota.imag() *
								 iota.imag() )
			    * ( conj(zeta) - conj(iota) * zeta );
      iter++;
    }
    if ( !(--octave_iter) ) break;
    /* If we've already reached the lowest value, stop.
     * Otherwise, merge with the next computation range.
     */
    double *exp_pse_ptr, *exp_ptr, exp_power_series_elements[12];
    exp_power_series_elements[0] = 1;
    exp_pse_ptr = exp_ptr = exp_power_series_elements;
    for ( int r_iter = 1 ; r_iter < 12 ; r_iter++ ) {
      exp_power_series_elements[r_iter] = exp_power_series_elements[r_iter-1]
	* ( mu * loop_delta_tau) * ( 1.0 / ( (double) r_iter ) );
    }
    try{ 
      for ( record_current = precomp_records_head ; record_current ;
	    record_current = record_current->next ) {
	if ( ! ( record_ref = record_current->next ) || ! record_ref->stored_data ) {
	  // In this case, there is no next record, but this record has data.
	  if ( record_current->stored_data ) {
	    int p = 0;
	    for(  exp_pse_ptr = exp_power_series_elements , temp_ptr_alpha = temp_alpha ; ; ) {
	      tpra = temp_ptr_alpha;
	      temp_ptr_alpha->x = record_current->power_series[p]->x;
	      (temp_ptr_alpha++)->t = record_current->power_series[p]->t;
	      temp_ptr_beta->x = -record_current->power_series[p]->x;
	      (temp_ptr_beta++)->t = -record_current->power_series[p]->t;
	      for( exp_ptr = exp_pse_ptr++, record_current->power_series[p]->x = tpra->x * *exp_ptr, record_current->power_series[p]->t = tpra->t * *exp_ptr ; ; ) {
		/* This next block is from Mathias' code, and it does a few
		 *  ... unsavoury things.  First off, it uses conditionals with
		 *  break in order to avoid potentially accessing null regions
		 *  of memory, and then it does ... painful things with a few
		 *  numbers.  However, remembering that most of these will not
		 *  actually be accessed for the first iterations, it's easier.
		 */
		if ( --exp_ptr < exp_power_series_elements ) break;
		++tpra;
		record_current->power_series[p]->x -= tpra->x * *exp_ptr;
		record_current->power_series[p]->t -= tpra->t * *exp_ptr;
		if ( --exp_ptr < exp_power_series_elements ) break;
		++tpra;
		record_current->power_series[p]->x += tpra->x * *exp_ptr;
		record_current->power_series[p]->t += tpra->x * *exp_ptr;
	      }
	      if ( ++p >= 12 ) break;
	      temp_ptr_alpha->x = -record_current->power_series[p]->x;
	      (temp_ptr_alpha++)->t = -record_current->power_series[p]->t;
	      temp_ptr_beta->x = record_current->power_series[p]->x;
	      (temp_ptr_beta++)->t = record_current->power_series[p]->t;
	      for( tprb = temp_beta, exp_ptr = exp_pse_ptr++, record_current->power_series[p]->t = tprb->t * *exp_ptr; exp_ptr > exp_power_series_elements ; ) {
		++tprb;
		--exp_ptr;
		record_current->power_series[p]->t += tprb->t * *exp_ptr;
	      }
	      if ( ++p >= 12 ) break;
	    }
	  }
	  if ( ! record_ref ) break; // Last record was reached
	}
	else {
	  record_next = record_ref;
	  if ( record_current->stored_data ) {
	    int p = 0;
	    for( exp_pse_ptr = exp_power_series_elements, temp_ptr_alpha = temp_alpha, temp_ptr_beta = temp_beta; ; ) {
	      temp_ptr_alpha->x = record_current->power_series[p]->x + record_next->power_series[p]->x;
	      (temp_ptr_alpha++)->t = record_current->power_series[p]->t + record_next->power_series[p]->t;
	      temp_ptr_beta->x = record_ref->power_series[p]->x - record_current->power_series[p]->x;
	      (temp_ptr_beta++)->t = record_ref->power_series[p]->t - record_current->power_series[p]->t;
	      for( tpra = temp_alpha, exp_ptr = exp_pse_ptr++, record_current->power_series[p]->x = tpra->x * *exp_ptr, record_current->power_series[p]->t = tpra->x * *exp_ptr; ; ) {
		if ( --exp_ptr < exp_pse_ptr ) break;
		++tpra;
		record_current->power_series[p]->x -= tpra->x * *exp_ptr;
		record_current->power_series[p]->t -= tpra->t * *exp_ptr;
		if ( --exp_ptr < exp_pse_ptr ) break;
		++tpra;
		record_current->power_series[p]->x += tpra->x * *exp_ptr;
		record_current->power_series[p]->t += tpra->t * *exp_ptr;
	      }
	      if ( ++p >= 12 ) break;
	      temp_ptr_alpha->x = record_next->power_series[p]->x - record_current->power_series[p]->x;
	      (temp_ptr_alpha++)->t = record_next->power_series[p]->t - record_current->power_series[p]->t;
	      temp_ptr_beta->x = record_current->power_series[p]->x + record_next->power_series[p]->x;
	      (temp_ptr_beta++)->t = record_current->power_series[p]->t + record_next->power_series[p]->t;
	      for(tprb = temp_beta, exp_ptr = exp_pse_ptr++, record_current->power_series[p]->x = tprb->x * *exp_ptr, record_current->power_series[p]->t = tprb->x * *exp_ptr; exp_ptr > exp_power_series_elements; ) {
		++tprb;
		--exp_ptr;
		record_current->power_series[p]->x += tprb->x * *exp_ptr;
		record_current->power_series[p]->t += tprb->t * *exp_ptr;
	      }
	      if ( ++p >= 12 ) break;
	    }
	  } else {
	    int q = 0;
	    for( exp_pse_ptr = exp_power_series_elements, temp_ptr_alpha = temp_alpha, temp_ptr_beta = temp_beta; ; ) {
	      temp_ptr_alpha->x = record_next->power_series[q]->x;
	      temp_ptr_alpha->t = record_next->power_series[q]->t;
	      for(tpra = temp_alpha, exp_ptr = exp_pse_ptr++, record_next->power_series[q]->x = tpra->x * *exp_ptr, record_next->power_series[q]->t = tpra->t * *exp_ptr; exp_ptr > exp_power_series_elements; ) {
		++tpra;
		--exp_ptr;
		record_next->power_series[q]->x += tpra->x * *exp_ptr;
		record_next->power_series[q]->t += tpra->t * *exp_ptr;
	      }
	      if ( ++q >= 12 ) break;
	    }
	  record_current->stored_data = true;
	  record_ref = record_next;
	  record_current->next = record_ref->next;
	  record_next = 0;
	  delete record_ref;
	}
      }
    }
  return results;
}
