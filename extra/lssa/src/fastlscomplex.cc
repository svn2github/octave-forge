/* Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
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

bool flscomplex (const RowVector & tvec, const ComplexRowVector & xvec,
                 double maxfreq, int coefficients, int octaves, ComplexRowVector & result);

DEFUN_DLD(fastlscomplex,args,nargout, 
"-*- texinfo -*-\n\
@deftypefn {Function File} { C = } fastlscomplex                        \
(@var{time},@var{magnitude},@var{maxfreq},@var{ncoeff},@var{noctave})\n \
\n\
Return a series of least-squares transforms of a complex time series via a divide and\n\
conquer algorithm.  Each transform is minimized independently at each frequency,\n\
starting from @var{maxfreq} and descending over @var{ncoeff} frequencies for\n\
each of @var{noctave} octaves.\n\
\n\
For each result, the complex result for a given frequency o defines the real and\n\
imaginary sinusoids which have the least distance to the data set: for a + bi,\n\
the matching sinusoids are a cos (ot) + b i sin (ot).\n\
\n\
@seealso{lscomplex, fastlsreal}\n\
\n\
@end deftypefn")
{

  octave_value_list retval;

  if (args.length() != 5)
    print_usage();
  else
    {

      RowVector tvals = args(0).row_vector_value ();
      ComplexRowVector xvals = args(1).complex_row_vector_value ();
      double omegamax = args(2).double_value ();
      int noctaves = args(3).int_value ();
      int ncoeff = args(4).int_value ();

      if (tvals.numel () != xvals.numel ())
        if (tvals.numel () > xvals.numel ())
          error ("fastlscomplex: More time values than magnitude values");
        else
          error ("fastlscomplex: More magnitude values than time values");
      if (ncoeff == 0)
        error ("fastlscomplex: No coefficients to compute");
      if (noctaves == 0)
        error ("fastlscomplex: No octaves to compute over");
      if (omegamax == 0)
        error ("fastlscomplex: No difference between minimal and maximal frequency");

      if (! error_state)
        {
          ComplexRowVector results;
          if (flscomplex (tvals, xvals, omegamax, noctaves, ncoeff, results))
            retval(0) = octave_value (results);
          else
            error ("fastlscomplex: error in the underlying flscomplex function");
        }

    }

  return retval;
}

bool flscomplex (const RowVector & tvec, const ComplexRowVector & xvec,
                 double maxfreq, int octaves, int coefficients,
                 ComplexRowVector & results)
{

  struct Precomputation_Record
  {
    Precomputation_Record *next;
    std::complex<double> power_series[12]; // I'm using 12 as a matter of compatibility, only.
    bool stored_data;
  };

  const std::complex<double> *xvec_ptr = xvec.data ();
  const double *tvec_ptr = tvec.data ();

  results.resize (coefficients * octaves);
  const std::complex<double> *results_ptr = results.fortran_vec ();

  double tau, delta_tau, tau_0, tau_h, n_inv, mu, te,
    omega_oct, omega_multiplier, octavemax, omega_working,
    loop_tau_0, loop_delta_tau, on_1, n_1, o;

  double length = tvec_ptr[tvec.numel () - 1] - tvec_ptr[0];

  int octave_iter, coeff_iter;

  std::complex<double> zeta, zz, z_accumulator, exp_term, exp_multiplier,
    alpha, h, *tpra, *temp_ptr_alpha, temp_alpha[12], *tprb, *temp_ptr_beta,
    temp_beta[12], temp_array[12], *p, x;

  octave_idx_type n = tvec.numel ();

  for (int array_iter = 0; array_iter < 12; array_iter++)
    temp_array[array_iter] = std::complex<double> (0 , 0);

  int factorial_array[12];
  factorial_array[0] = 1;

  for (int i = 1; i < 12; i++)
    factorial_array[i] = factorial_array[i-1] * i;

  n_1 = n_inv = 1.0 / n;
  mu = (0.5 * M_PI) / length; // Per the article; this is in place to improve numerical accuracy if desired.
  /* Viz. the paper, in which Dtau = c / omega_max, and c is stated as pi/2 for floating point processors,
   * In the case of this computation, I'll go by the recommendation.
   */

  delta_tau = (0.5 * M_PI) / maxfreq;
  tau_0 = tvec_ptr[0] + delta_tau;
  tau_h = tau_0;
  te = tau_h + delta_tau;

  octave_idx_type k = 0; // Iterator for accessing xvec, tvec.

  Precomputation_Record * precomp_records_head, *record_current, *record_tail, *record_ref, *record_next;
  record_current = precomp_records_head = new  Precomputation_Record;

  for (te = tvec_ptr[k] + (2 * delta_tau) ; ;) 
    {
      x = xvec_ptr[k];
      {
        double t = mu *(tvec_ptr[k] - tau_h), tt;
        p = record_current->power_series;
        // p = 0
        *p++ = x;
        // p = 1
        tt = -t;
        h = x * tt;
        *p++ = std::complex<double> (-h.imag (), h.real ());
        // p = 2
        tt *= t*(1.0/2.0);
        *p++ = x*tt;
        // p = 3
        tt *= t*(-1.0/3.0);
        h = x * tt;
        *p++ = std::complex<double> (-h.imag (), h.real ());
        // p = 4
        tt *= t*(1.0/4.0);
        *p++ = x*tt;
        // p = 5
        tt *= t*(-1.0/5.0);
        h = x * tt;
        *p++ = std::complex<double>(-h.imag () ,h.real ());
        // p = 6
        tt *= t*(1.0/6.0);
        *p++ = x*tt;
        // p = 7
        tt *= t*(-1.0/7.0);
        h = x * tt;
        *p++ = std::complex<double>(-h.imag(),h.real());
        // p = 8
        tt *= t*(1.0/8.0);
        *p++ = x*tt;
        // p = 9
        tt *= t*(-1.0/9.0);
        h = x * tt;
        *p++ = std::complex<double>(-h.imag(),h.real());
        // p = 10
        tt *= t*(1.0/10.0);
        *p++ = x*tt;
        // p = 11
        tt *= t*(-1.0/11.0);
        h = x * tt;
        *p++ = std::complex<double>(-h.imag(),h.real());
      }

      record_current->stored_data = true;
      for(k++; k < n && tvec_ptr[k] < te; k++)
        {
          x = std::complex<double> (xvec_ptr[k]);
          {
            double t = mu * (tvec_ptr[k] - tau_h), tt;
            p = record_current->power_series;
            // p = 0
            *p++ += std::complex<double>(x);
            // p = 1
            tt = -t;
            h = x * tt;
            *p++ += std::complex<double>(- h.imag(), h.real());
            // p = 2
            tt *= t*(1.0/2.0);
            *p++ += x*tt;
            // p = 3
            tt *= t*(-1.0/3.0);
            h = x * tt;
            *p++ += std::complex<double>(-h.imag(),h.real());
            // p = 4
            tt *= t*(1.0/4.0);
            *p++ += x*tt;
            // p = 5
            tt *= t*(-1.0/5.0);
            h = x * tt;
            *p++ += std::complex<double>(-h.imag(),h.real());
            // p = 6
            tt *= t*(1.0/6.0);
            *p++ += x*tt;
            // p = 7
            tt *= t*(-1.0/7.0);
            h = x * tt;
            *p++ += std::complex<double>(-h.imag(),h.real());
            // p = 8
            tt *= t*(1.0/8.0);
            *p++ += x*tt;
            // p = 9
            tt *= t*(-1.0/9.0);
            h = x * tt;
            *p++ += std::complex<double>(-h.imag(),h.real());
            // p = 10
            tt *= t*(1.0/10.0);
            *p++ += x*tt;
            // p = 11
            tt *= t*(-1.0/11.0);
            h = x * tt;
            *p++ += std::complex<double>(-h.imag(),h.real());
          }
          record_current->stored_data = true;
        }

      if (k >= n)
        break;

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
  omega_multiplier = exp (-log(2) / coefficients);
  octavemax = maxfreq;
  loop_tau_0 = tau_0;
  loop_delta_tau = delta_tau;

  octave_idx_type iter = 0;

  // Loops need to first travel over octaves, then coefficients;
  for (octave_iter = octaves; ;
       omega_oct *= 0.5, octavemax *= 0.5, loop_tau_0 += loop_delta_tau, loop_delta_tau *= 2) 
    {
      o = omega_oct;
      omega_working = octavemax;
      for (coeff_iter = 0;
           coeff_iter < coefficients;
           coeff_iter++, o *= omega_multiplier,
             omega_working *= omega_multiplier)
        {
          exp_term = std::complex<double> (cos (- omega_working * loop_tau_0),
                                           sin (- omega_working * loop_tau_0));

          exp_multiplier = std::complex<double> (cos (- 2 * omega_working * loop_delta_tau) ,
                                                 sin (- 2 * omega_working * loop_delta_tau));

          for (zeta = 0, record_current = precomp_records_head;
               record_current;
               record_current = record_current->next, exp_term *= exp_multiplier ) 
            {
              if (record_current->stored_data)
                {
                  int p;
                  for (zz = 0, p = 0, on_1 = n_1; p < 12; p++)
                    {
                      zz += record_current->power_series[p] * on_1;
                      on_1 *= o;
                    }
                  zeta += exp_term * zz;
                }
            }
          results(iter) = std::complex<double> (zeta);
          iter++;
        }
      if (! (--octave_iter))
        break;

      /* If we've already reached the lowest value, stop.
       * Otherwise, merge with the next computation range.
       */
      double *exp_pse_ptr, *exp_ptr, exp_power_series_elements[12];
      {
        double t = mu * loop_delta_tau, tt;
        exp_ptr = exp_power_series_elements;
        *exp_ptr++ = 1;
        *exp_ptr++ = t;
        tt = t * t * ( 1.0 / 2.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 3.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 4.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 5.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 6.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 7.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 8.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 9.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 10.0 );
        *exp_ptr++ = tt;
        tt *= t * ( 1.0 / 11.0 );
        *exp_ptr++ = tt;
      }
      exp_pse_ptr = exp_ptr = exp_power_series_elements;

      try
        {
          for (record_current = precomp_records_head;
               record_current;
               record_current = record_current->next)
            {
              if (! (record_ref = record_current->next )
                  || ! record_ref->stored_data )
                {
                  // In this case, there is no next record, but this record has data.
                  if (record_current->stored_data)
                    {
                      int p = 0;
                      for (exp_pse_ptr = exp_power_series_elements + 1, temp_ptr_alpha = temp_alpha; 
                           p < 12;
                           p++ , exp_pse_ptr++)
                        {
                          tpra = temp_ptr_alpha;
                          *(temp_ptr_alpha++) = std::complex<double>(record_current->power_series[p]);
                          for( exp_ptr = exp_power_series_elements, record_current->power_series[p] = *temp_ptr_alpha * *exp_ptr; ; ) {
                            /* This next block is from Mathias' code, and it does a few
                             *  ... unsavoury things.  First off, it uses conditionals with
                             *  break in order to avoid potentially accessing null regions
                             *  of memory, and then it does ... painful things with a few
                             *  numbers.  However, remembering that most of these will not
                             *  actually be accessed for the first iterations, it's easier.
                             */

                            if (++exp_ptr >= exp_pse_ptr)
                              break;

                            --tpra;
                            h = *tpra * *exp_ptr;
                            record_current->power_series[p].real() -= h.imag();
                            record_current->power_series[p].imag() += h.real();

                            if (++exp_ptr >= exp_pse_ptr )
                              break;

                            --tpra;
                            record_current->power_series[p] -= *tpra * *exp_ptr;

                            if (++exp_ptr >= exp_pse_ptr)
                              break;

                            --tpra;
                            h = -*tpra * *exp_ptr;
                            record_current->power_series[p].real() -= h.imag();
                            record_current->power_series[p].imag() += h.real();

                            if (++exp_ptr >= exp_pse_ptr)
                              break;

                            --tpra;
                            record_current->power_series[p] += *tpra * *exp_ptr;
                          }
                        }

                      if ( ! record_ref )
                        break; // Last record was reached

                    }
                  else
                    {
                      record_next = record_ref;
                      if ( record_current->stored_data )
                        {
                          int p = 0, q = 0;
                          for (exp_pse_ptr = exp_power_series_elements + 1, temp_ptr_alpha = temp_alpha, temp_ptr_beta = temp_beta; 
                               p < 12; p++, q++, exp_pse_ptr++)
                            {
                              tpra = temp_ptr_alpha;
                              *temp_ptr_alpha++ = record_current->power_series[p] + record_next->power_series[q];
                              *temp_ptr_beta++ = record_current->power_series[p] - record_next->power_series[q];
                              tprb = temp_ptr_beta;

                              for (exp_ptr = exp_power_series_elements, record_current->power_series[p] = *tpra * *exp_ptr; ;) 
                                {
                                  if (++exp_ptr >= exp_pse_ptr )
                                    break;

                                  tprb -= 2;
                                  h = *tprb * *exp_ptr;
                                  record_current->power_series[p].real() -= h.imag();
                                  record_current->power_series[p].imag() += h.real();

                                  if ( ++exp_ptr >= exp_pse_ptr )
                                    break;

                                  tpra -= 2;
                                  record_current->power_series[p] -= *tpra * *exp_ptr;

                                  if (++exp_ptr >= exp_pse_ptr)
                                    break;

                                  tprb -= 2;
                                  h = - *tprb * *exp_ptr;
                                  record_current->power_series[p].real() -= h.imag();
                                  record_current->power_series[p].imag() += h.real();

                                  if (++exp_ptr >= exp_pse_ptr)
                                    break;

                                  tpra -= 2;
                                  record_current->power_series[p] += *tpra * *exp_ptr;
                                }
                            }
                        }
                      else
                        {
                          int q = 0;
                          for (exp_pse_ptr = exp_power_series_elements + 1,
                                 temp_ptr_alpha = temp_alpha,
                                 temp_ptr_beta = temp_beta;
                               q < 12;
                               q++, exp_pse_ptr++)
                            {
                              tpra = temp_ptr_alpha;
                              *temp_ptr_alpha++ = std::complex<double>(record_next->power_series[q]);

                              for (exp_ptr = exp_power_series_elements,
                                     record_next->power_series[q] = *tpra * *exp_ptr; ;) 
                                {
                                  if (++exp_ptr >= exp_pse_ptr)
                                    break;

                                  --tpra;
                                  h = *tpra * *exp_ptr;
                                  record_next->power_series[q].real() -= h.imag();
                                  record_next->power_series[q].imag() += h.real();

                                  if (++exp_ptr >= exp_pse_ptr)
                                    break;

                                  --tpra;
                                  record_next->power_series[q] -= *tpra * *exp_ptr;

                                  if ( ++exp_ptr >= exp_pse_ptr )
                                    break;

                                  --tpra;
                                  h = -*tpra * *exp_ptr;
                                  record_next->power_series[q].real() -= h.imag();
                                  record_next->power_series[q].imag() += h.real();

                                  if (++exp_ptr >= exp_pse_ptr)
                                    break;

                                  --tpra;
                                  record_next->power_series[q] += *tpra * *exp_ptr;
                                }
                            }
                        }

                      record_current->stored_data = true;
                      record_ref = record_next;
                      record_current->next = record_ref->next;
                      delete record_ref;

                    }
                }
            }
        }
      catch (std::exception & e)
        {//This section was part of my debugging, and may be removed.
          std::cout << "Exception thrown: " << e.what() << std::endl;
          return (false);
        }
    }

  return true;
}

/*
%!test
%! maxfreq = 4 / ( 2 * pi );
%! t = [0:0.008:8];
%! x = ( 2 .* sin (maxfreq .* t) +
%!       3 .* sin ( (3 / 4) * maxfreq .* t)-
%!       0.5 .* sin ((1/4) * maxfreq .* t) -
%!       0.2 .* cos (maxfreq .* t) + 
%!       cos ((1/4) * maxfreq .* t));
%! assert (fastlscomplex (t, x, maxfreq, 2, 2), 
%!       [(-0.400924546169395 - 2.371555305867469i), ...
%!        (1.218065147708429 - 2.256125004156890i), ... 
%!        (1.935428592212907 - 1.539488163739336i), ...
%!        (2.136692292751917 - 0.980532175174563i)], 5e-10);
*/