/*
 Copyright (C) 2004   Teemu Ikonen   <tpikonen@pcu.helsinki.fi>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
 
#include <octave/oct.h>
#include <gsl/gsl_sf.h>
#include <gsl/gsl_sf_result.h>
#include <gsl/gsl_errno.h>

void octave_gsl_errorhandler (const char * reason, const char * file,
			      int line, int gsl_errno)
{
    error("GSL error %d at %s, line %d: %s\n", gsl_errno, file, line, reason);
}

DEFUN_DLD(legendre_sphPlm_array, args, nargout, "\
function y = legendre_sphPlm_array (lmax, m, x)\n\n\
This function computes an array of normalized associated Legendre functions\n\
$\\sqrt{(2l+1)/(4\\pi)} \\sqrt{(l-m)!/(l+m)!} P_l^m(x)$\n\
for m >= 0, l = |m|, ..., lmax, |x| <= 1.0\n\
\n\
This function is from the GNU Scientific Library,\n\
see http://www.gnu.org/software/gsl/ for documentation.\n\
")
{
    int i;
    
    gsl_set_error_handler (octave_gsl_errorhandler);
    
    if(args.length() != 3) {
	print_usage ("legendre_sphPlm_array");
	return octave_value_list();
    }
    if(!args(0).is_real_type()
       || !args(1).is_real_type()
       || !args(2).is_real_type()
       || !args(0).is_scalar_type()
       || !args(1).is_scalar_type()
       || !args(2).is_scalar_type()) {
        error("The arguments must be real scalars.");
	print_usage ("legendre_sphPlm_array");	    
	return octave_value_list();
    }

    int lmax = static_cast<int>(args(0).scalar_value());
    int m = static_cast<int>(args(1).scalar_value());    
    double x = args(2).scalar_value();
    RowVector *y = new RowVector(gsl_sf_legendre_array_size (lmax, m));
    double *yd = y->fortran_vec();
    gsl_sf_legendre_sphPlm_array (lmax, m, x, yd);

    return octave_value_list(octave_value(*y));

}
