/* Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
 * GNU GPLv2
 */


#include <octave/oct.h>
#include <octave/unwind-prot.h>
#include <complex>
#include <string>
#include <math.h>
#include <iostream>
#include <exception>

ComplexRowVector flscomplex( RowVector tvec , ComplexRowVector xvec ,
			     double maxfreq , int octaves , int coefficients);


DEFUN_DLD(fastlscomplex,args,nargout, 
	  "-*- texinfo -*-\n"
"@deftypefn {Function File} { C = } fastlscomplex"
	  "(@var{time},@var{magnitude},@var{maximum_frequency},@var{octaves},@var{coefficients})\n"
"\n"
"Return the complex least squares transform of the (@var{time},@var{magnitude}) series\n\
supplied, using the fast algorithm.\n"
"\n"
"@seealso{lscomplex}\n"
"@seealso{fastlsreal}\n"
"\n"
"@end deftypefn") {
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

ComplexRowVector flscomplex( RowVector tvec , ComplexRowVector xvec ,
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
  std::complex<double> zeta, z_accumulator, exp_term, exp_multiplier, alpha;
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
  const std::complex<double> im = std::complex<double> ( 0 , 1 );

  octave_idx_type k ( 0 ); // Iterator for accessing xvec, tvec.

  Precomputation_Record * precomp_records_head, *record_current, *record_tail, *record_ref, *record_next;
  record_current = precomp_records_head = new  Precomputation_Record;
  for ( size_t p_r_iter = 1 ; p_r_iter < precomp_subset_count ; p_r_iter++ ) {
    record_current->next = new Precomputation_Record;
    record_current = record_current->next;
  }
  record_tail = record_current;
  record_current = precomp_records_head;
  record_tail->next = 0;
  /* A test needs to be included for if there was a failure, but since
   * precomp_subset_count is of type size_t, it should be okay. */
  for( ; record_current != 0 ; record_current = record_current->next ) {
    for ( int j = 0 ; j < 12 ; j++ ) { 
      record_current->power_series[j] = std::complex<double> ( 0 , 0 );
    } // To avoid any trouble down the line, although it is an annoyance.
    // Error is traced this far. Time to see if it's in this loop.
    while ( (k < n) && (abs(tvec(k)-tau_h) <= delta_tau) ) {
      double p;
      //      alpha = std::complex<double> ( 0 , 0 );
      for ( int j = 0 ; j < 12 ; j++ ) {
	alpha.real() = xvec(k).real();
	alpha.imag() = xvec(k).imag();
	//	alpha = std::complex<double> ( xvec(k).real() , xvec(k).imag() );
	  //	  alpha *= ( -1 * im * mu * ( tvec(k) - tau_h ) ) * p;
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
	record_current->power_series[j].real() += alpha.real();
	record_current->power_series[j].imag() += alpha.imag();
      }
      // Computes each next step of the power series for the given power series element.
      // j was reused since it was a handy inner-loop variable, even though I used it twice here.
      record_current->stored_data = true;
      k++;
    }
    tau_h += ( 2 * delta_tau );
  }
  // At this point all precomputation records have been exhausted; short-circuit is abused to avoid overflow errors.
  
  /* Summation of coefficients for each frequency. As we have ncoeffs * noctaves elements,
   * it makes sense to work from the top down, as we have omega_max by default (maxfreq)
   */

  omega_oct = maxfreq / mu;
  omega_multiplier = exp(-log(2)/coefficients);
  octavemax = maxfreq;
  loop_tau_0 = tau_0;
  loop_delta_tau = delta_tau;
  
  octave_idx_type iter ( 0 );
  
  double real_part = 0, imag_part = 0, real_part_accumulator = 0, imag_part_accumulator = 0;

  // Loops need to first travel over octaves, then coefficients;
  
  for ( octave_iter = octaves ; ; omega_oct *= 0.5 , octavemax *= 0.5 , loop_tau_0 += loop_delta_tau , loop_delta_tau *= 2 ) {
    omega_working = omega_oct;
    exp_term = std::complex<double> ( cos( - omega_working * loop_tau_0 ) ,
				      sin ( - omega_working * loop_tau_0 ) );
    exp_multiplier = std::complex<double> ( cos ( - 2 * omega_working * loop_delta_tau ) ,
					    sin ( - 2 * omega_working * loop_delta_tau ) );
    for ( coeff_iter = 0 ; coeff_iter < coefficients ; coeff_iter++, omega_working *= omega_multiplier){
      real_part_accumulator = 0;
      imag_part_accumulator = 0;
      real_part = 0;
      imag_part = 0;
      for ( record_current = precomp_records_head ; record_current ;
	    record_current = record_current->next, exp_term *= exp_multiplier ) {
	for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
	  z_accumulator = ( pow(omega_working,array_iter) * record_current->power_series[array_iter] );
	  real_part_accumulator += z_accumulator.real();
	  imag_part_accumulator += z_accumulator.imag();
	}
	real_part = real_part + ( exp_term.real() * real_part_accumulator - ( exp_term.imag() * imag_part_accumulator ) );
	imag_part = imag_part + ( exp_term.imag() * real_part_accumulator + exp_term.real() * imag_part_accumulator );
      }
      results(iter) = std::complex<double> ( n_inv * real_part , n_inv * imag_part );
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
      for ( record_current = precomp_records_head ; record_current ;
	    record_current = record_current->next ) {
	if ( ! ( record_ref = record_current->next ) || ! record_ref->stored_data ) {
	  if ( record_current->stored_data ) {
	    std::complex<double> temp[12];
	    for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	    for( int p = 0 ; p < 12 ; p ++ ) {
	      double step_floor_r = floor( ( (double) p ) / 2.0 );
	      double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
	      for( int q = 0 ; q < step_floor_r ; q++ ) {
		temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * record_current->power_series[p - ( 2 * q )];
	      }
	      for( int q = 0 ; q <= step_floor_i ; q++ ) {
		temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,q) * record_current->power_series[p - ( 2 * q ) - 1];
	      }
	    }
	    for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
	      record_current->power_series[array_iter].real() = temp[array_iter].real();
	      record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	    }
	    if ( ! record_ref ) break; // Last record was reached
	  }
	  else {
	    record_next = record_ref;
	    if ( record_current->stored_data ) {
	      std::complex<double> temp[12];
	      for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	      for( int p = 0 ; p < 12 ; p ++ ) {
		double step_floor_r = floor( ( (double) p ) / 2.0 );
		double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
		for( int q = 0 ; q < step_floor_r ; q++ ) {
		  temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * ( record_current->power_series[p - ( 2 * q )] - record_next->power_series[p - (2*q)] );
		}
		for( int q = 0 ; q <= step_floor_i ; q++ ) {
		  temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,q) * ( record_current->power_series[p - ( 2 * q ) - 1] - record_next->power_series[p - ( 2 * q ) - 1 ] );
		}
	      }
	      for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
		record_current->power_series[array_iter].real() = temp[array_iter].real();
		record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	      }
	    } else {
	      std::complex<double> temp[12];
	      for( int array_init = 0 ; array_init < 12 ; array_init++ ) { temp[array_init] = std::complex<double>(0,0); }
	      for( int p = 0 ; p < 12 ; p ++ ) {
		double step_floor_r = floor( ( (double) p ) / 2.0 );
		double step_floor_i = floor( ( (double) ( p - 1 ) ) / 2.0 );
		for( int q = 0 ; q < step_floor_r ; q++ ) {
		  temp[p] += exp_power_series_elements[2*q] * pow((double)-1,q) * record_next->power_series[p - ( 2 * q )];
		}
		for( int q = 0 ; q <= step_floor_i ; q++ ) {
		  temp[p] += im * exp_power_series_elements[2 * q + 1] * pow((double)-1,(q+1)) * record_next->power_series[p - ( 2 * q ) - 1];
		}
	      }
	      for ( int array_iter = 0 ; array_iter < 12 ; array_iter++ ) {
		record_current->power_series[array_iter].real() = temp[array_iter].real();
		record_current->power_series[array_iter].imag() = temp[array_iter].imag();
	      }
	    }
	    record_current->stored_data = true;
	    record_ref = record_next;
	    record_current->next = record_ref->next;
	    delete record_ref;
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
