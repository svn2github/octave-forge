/* Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
 * Licensed under the GNU GPLv2
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


DEFUN_DLD(fastlsreal,args,nargout, "fastlsreal(time,magnitude,maximum_frequency,octaves,coefficients)") {
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
    ComplexRowVector results = flscomplex(tvals,xvals,omegamax,noctaves,ncoeff);
    retval(0) = octave_value(results);
  } else {
    return octave_value_list ();
  }
  return retval;

}

ComplexRowVector flsreal( RowVector tvec , ComplexRowVector xvec ,
			  double maxfreq, int octaves, int coefficients ) {
  struct Precomputation_Record {
    Precomputation_Record *next;
    std::complex<double> power_series[12]; // I'm using 12 as a matter of compatibility, only.
    bool stored_data;
  };

  ComplexRowVector results = ComplexRowVector (coefficients * octaves );

  double tau, delta_tau, tau_0, tau_h, n_inv, mu,
    omega_oct, omega_multiplier, octavemax, omega_working,
    loop_tau_0, loop_delta_tau;
  double length = ( tvec((tvec.numel()-1)) - tvec( octave_idx_type (0)));
  int octave_iter, coeff_iter;
  std::complex<double> zeta, z_accumulator, zeta_exp_term, zeta_exp_multiplier, alpha,
    iota, i_accumulator, iota_exp_term, iota_exp_multiplier;
  octave_idx_type n = tvec.numel();
  std::complex<double> temp_array[12];
  for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
    temp_array[array_iter] = std::complex<double> ( 0 , 0 );
  }
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

  Precomputation_Record * complex_precomp_records_head, *complex_record_current,
    *complex_record_tail, *complex_record_ref, *complex_record_next, *iota_precomp_records_head,
    *iota_record_current, *iota_record_tail, *iota_record_ref, *iota_record_next;
  complex_record_current = complex_precomp_records_head = new  Precomputation_Record;
  iota_record_current = iota_precomp_records_head = new Precomputation_Record;
  for ( size_t p_r_iter = 1 ; p_r_iter < precomp_subset_count ; p_r_iter++ ) {
    complex_record_current->next = new Precomputation_Record;
    iota_record_current->next = new Precomputation_Record;
    complex_record_current = complex_record_current->next;
    iota_record_current = iota_record_current->next;
  }
  complex_record_tail = complex_record_current;
  iota_record_tail = iota_record_current;
  complex_record_current = complex_precomp_records_head;
  iota_record_current = iota_precomp_records_head;
  complex_record_tail->next = 0;
  iota_record_tail->next = 0;
  /* A test needs to be included for if there was a failure, but since
   * precomp_subset_count is of type size_t, it should be okay. */
  for( ; complex_record_current != 0 ; complex_record_current = complex_record_current->next ) {
    for ( int j = 0 ; j < 12 ; j++ ) { 
      complex_record_current->power_series[j] = std::complex<double> ( 0 , 0 );
    } // To avoid any trouble down the line, although it is an annoyance.
    // Error is traced this far. Time to see if it's in this loop.
    while ( (k < n) && (abs(tvec(k)-tau_h) <= delta_tau) ) {
      double p;
      for ( int j = 0 ; j < 12 ; j++ ) {
	alpha.real() = xvec(k).real();
	alpha.imag() = xvec(k).imag();
	// Change to switches for easier manipulation, fewer tests. This is two tests where one will do.
	if ( !( j % 2 ) ) {
	  if ( ! ( j % 4 ) ) {
	    alpha.real() = xvec(k).real() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	    alpha.imag() = xvec(k).imag() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	  } else {
	    alpha.real() = -1 * xvec(k).real() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	    alpha.imag() = -1 * xvec(k).imag() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	  } 
	} else {
	  if ( ! ( j % 3 ) ) {
	    alpha.real() = -1 * xvec(k).imag() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	    alpha.imag() = -1 * xvec(k).real() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	  } else {
	    alpha.real() = xvec(k).imag() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	    alpha.imag() = xvec(k).real() * pow(mu,j) * pow(tvec(k)-tau_h,j) / factorial_array[j];
	  }
	}
	complex_record_current->power_series[j].real() += alpha.real();
	complex_record_current->power_series[j].imag() += alpha.imag();
      }
      // Computes each next step of the power series for the given power series element.
      // j was reused since it was a handy inner-loop variable, even though I used it twice here.
      complex_record_current->stored_data = true;
      k++;
    }
    tau_h += ( 2 * delta_tau );
  }
  // At this point all precomputation records have been
  // exhausted for complex records. Short-circuit is abused
  // to avoid overflow errors.
  // Reset k, tau_h to reset the process. I may rewrite
  // these loops to be one, since running twice as long to
  // do the same thing is painful. May also move to a switch
  // in the previous section too.
  k = 0;
  tau_h = tau_0;
  for( ; iota_record_current != 0 ; iota_record_current = iota_record_current->next ) {
    for ( int j = 0 ; j < 12 ; j++ ) { 
      complex_record_current->power_series[j] = std::complex<double> ( 0 , 0 );
    }
    while( ( k < n ) && (abs(tvec(k)-tau_h) <= delta_tau) ) {
      double comps[12];
      iota_record_current->power_series[0].real() = 1;
      comps[0] = 1;
      for ( int j = 1 ; j < 12 ; j++ ) {
	comps[j] = comps[j-1] * mu * (tvec(k)-tau_h);
	switch ( j % 4 ) {
	case 0 :
	  iota_record_current->power_series[j].real() += comps[j] / factorial_array[j] ;
	  break;
	case 1:
	  iota_record_current->power_series[j].imag() += comps[j] / factorial_array[j] ;
	  break;
	case 2:
	  iota_record_current->power_series[j].real() -= comps[j] / factorial_array[j] ;
	  break;
	case 3:
	  iota_record_current->power_series[j].imag() -= comps[j] / factorial_array[j] ;
	  break;
	}
      }
      iota_record_current->stored_data = true;
      k++;
    }
    tau_h += ( 2 * delta_tau );
  }
      
  
  /* Summation of coefficients for each frequency. As we have ncoeffs * noctaves elements,
   * it makes sense to work from the top down, as we have omega_max by default (maxfreq)
   */

  omega_oct = maxfreq / mu;
  omega_multiplier = exp(-log(2)/coefficients);
  octavemax = maxfreq;
  loop_tau_0 = tau_0;
  loop_delta_tau = delta_tau;
  
  octave_idx_type iter ( 0 );
  
  double zeta_real_part = 0, zeta_imag_part = 0, zeta_real_part_accumulator = 0, zeta_imag_part_accumulator = 0,
    iota_real_part = 0, iota_imag_part = 0, iota_real_part_accumulator = 0, iota_imag_part_accumulator = 0;

  // Loops need to first travel over octaves, then coefficients;
  
  for ( octave_iter = octaves ; ; omega_oct *= 0.5 , octavemax *= 0.5 , loop_tau_0 += loop_delta_tau , loop_delta_tau *= 2 ) {
    omega_working = omega_oct;
    zeta_exp_term = std::complex<double> ( cos ( - omega_working * loop_tau_0 ) ,
				      sin ( - omega_working * loop_tau_0 ) );
    zeta_exp_multiplier = std::complex<double> ( cos ( - 2 * omega_working * loop_delta_tau ) ,
					    sin ( - 2 * omega_working * loop_delta_tau ) );
    iota_exp_term = std::complex<double> ( cos ( - 2 * omega_working * loop_tau_0 ) ,
					   sin ( - 2 * omega_working * loop_tau_0 ) );
    iota_exp_multiplier = std::complex<double> ( cos ( - 2 * omega_working * loop_delta_tau ) ,
						 sin ( - 2 * omega_working * loop_delta_tau ) );
    for ( coeff_iter = 0 ; coeff_iter < coefficients ; coeff_iter++, omega_working *= omega_multiplier){
      zeta_real_part_accumulator = 0;
      zeta_imag_part_accumulator = 0;
      zeta_real_part = 0;
      zeta_imag_part = 0;
      for ( complex_record_current = complex_precomp_records_head ; complex_record_current ;
	    complex_record_current = complex_record_current->next, zeta_exp_term *= zeta_exp_multiplier ) {
	for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
	  z_accumulator = ( pow(omega_working,array_iter) * complex_record_current->power_series[array_iter] );
	  zeta_real_part_accumulator += z_accumulator.real();
	  zeta_imag_part_accumulator += z_accumulator.imag();
	}
	zeta_real_part = zeta_real_part + ( zeta_exp_term.real() * zeta_real_part_accumulator - zeta_exp_term.imag() * zeta_imag_part_accumulator ) );
	zeta_imag_part = zeta_imag_part + ( zeta_exp_term.imag() * zeta_real_part_accumulator + zeta_exp_term.real() * zeta_imag_part_accumulator );
      }
      for ( iota_record_current = iota_precomp_records_head; iota_record_current ;
	    iota_record_current = iota_record_current->next, iota_exp_term = iota_exp_term_multiplier ) {
	for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
	  i_accumulator = ( pow(omega_working,array_iter) * iota_record_current->power_series[array_iter] );
	  iota_real_part_accumulator += i_accumulator.real();
	  iota_imag_part_accumulator += i_accumulator.imag();
	}
	iota_real_part = iota_real_part + ( iota_exp_term.real() * iota_real_part_accumulator - iota_exp_term.imag() * iota_imag_part_accumulator );
	iota_imag_part = iota_imag_part + ( iota_exp_term.imag() * iota_real_part_accumulator + iota_exp_term.real() * iota_imag_part_accumulator );
      }
      // c + i s = 2 * ( zeta-omega-conjugate - iota-2omega-conjuage * zeta-omega ) / ( 1 - abs(iota-2omega) ^ 2 )
      // (is what the results will be.)
      zeta_real_part *= n_inv;
      zeta_imag_part *= n_inv;
      iota_real_part *= n_inv;
      iota_imag_part *= n_inv;
      double result_real_part = 2 * ( zeta_real_part - iota_real_part * zeta_real_part - iota_imag_part * zeta_imag_part )
	/ ( 1 - iota_real_part * iota_real_part - iota_imag_part * iota_imag_part );
      double result_imag_part = 2 * ( - zeta_imag_part + iota_imag_part * zeta_real_part - iota_real_part * zeta_imag_part )
	/ ( 1 - iota_real_part * iota_real_part - iota_imag_part * iota_imag_part );
      results(iter) = std::complex<double> ( result_real_part , result_imag_part );
      iter++;
    }
    if ( !(--octave_iter) ) break;
    /* If we've already reached the lowest value, stop.
     * Otherwise, merge with the next computation range.
     */
    double exp_power_series_elements[12];
    exp_power_series_elements[0] = 1;
    for ( int r_iter = 1 ; r_iter < 12 ; r_iter++ ) {
      exp_power_series_elements[r_iter] = exp_power_series_elements[r_iter-1]
	* ( mu * loop_delta_tau) * ( 1.0 / ( (double) r_iter ) );
    }
    try{ 
      for ( complex_record_current = complex_precomp_records_head ; complex_record_current ;
	    complex_record_current = complex_record_current->next ) {
	if ( ! ( complex_record_ref = complex_record_current->next ) || ! complex_record_ref->stored_data ) {
	  if ( complex_record_current->stored_data ) {
	    std::complex<double> temp[12];
	    for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	    for( int p = 0 ; p < 12 ; p ++ ) {
	      double step_floor_r = floor( ( (double) p ) / 2.0 );
	      double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
	      for( int q = 0 ; q < step_floor_r ; q++ ) {
		temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * complex_record_current->power_series[p - ( 2 * q )];
	      }
	      for( int q = 0 ; q <= step_floor_i ; q++ ) {
		temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,q) * complex_record_current->power_series[p - ( 2 * q ) - 1];
	      }
	    }
	    for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
	      complex_record_current->power_series[array_iter].real() = temp[array_iter].real();
	      complex_record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	    }
	    if ( ! complex_record_ref ) break; // Last record was reached
	  }
	  else {
	    complex_record_next = complex_record_ref;
	    if ( complex_record_current->stored_data ) {
	      std::complex<double> temp[12];
	      for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	      for( int p = 0 ; p < 12 ; p ++ ) {
		double step_floor_r = floor( ( (double) p ) / 2.0 );
		double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
		for( int q = 0 ; q < step_floor_r ; q++ ) {
		  temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * ( complex_record_current->power_series[p - ( 2 * q )] - complex_record_next->power_series[p - (2*q)] );
		}
		for( int q = 0 ; q <= step_floor_i ; q++ ) {
		  temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,q) * ( complex_record_current->power_series[p - ( 2 * q ) - 1] - complex_record_next->power_series[p - ( 2 * q ) - 1 ] );
		}
	      }
	      for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
		complex_record_current->power_series[array_iter].real() = temp[array_iter].real();
		complex_record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	      }
	    } else {
	      std::complex<double> temp[12];
	      for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	      for( int p = 0 ; p < 12 ; p ++ ) {
		double step_floor_r = floor( ( (double) p ) / 2.0 );
		double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
		for( int q = 0 ; q < step_floor_r ; q++ ) {
		  temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * complex_record_next->power_series[p - ( 2 * q )];
		}
		for( int q = 0 ; q <= step_floor_i ; q++ ) {
		  temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,(q+1)) * complex_record_next->power_series[p - ( 2 * q ) - 1];
		}
	      }
	      for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
		complex_record_current->power_series[array_iter].real() = temp[array_iter].real();
		complex_record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	      }
	    }
	    complex_record_current->stored_data = true;
	    complex_record_ref = complex_record_next;
	    complex_record_current->next = complex_record_ref->next;
	    delete complex_record_ref;
	  }
	}
      }
    } catch (std::exception& e) { //This section was part of my debugging, and may be removed.
      std::cout << "Exception thrown: " << e.what() << std::endl;
      ComplexRowVector exception_result (1);
      exception_result(0) = std::complex<double> ( 0,0);
      return exception_result;
    }
  }
  return results;
}
