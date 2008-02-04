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
 along with this program; If not, see <http://www.gnu.org/licenses/>.
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

DEFUN_DLD(coupling_3j, args, nargout, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} coupling_3j (@var{two_ja}, @var{two_jb}, @var{two_jc}, @var{two_ma}, @var{two_mb}, @var{two_mc})\n\
\n\
These routines compute the Wigner 3-j coefficient,\n\
\n\
@example\n\
@group\n\
(ja jb jc\n\
 ma mb mc)\n\
@end group\n\
@end example\n\
\n\
where the arguments are given in half-integer units,\n\
@code{ja = two_ja/2}, @code{ma = two_ma/2}, etc.\n\
\n\
This function is from the GNU Scientific Library,\n\
see @url{http://www.gnu.org/software/gsl/} for documentation.\n\
@end deftypefn")
{
    int i;
    
    gsl_set_error_handler (octave_gsl_errorhandler);
    
    if(args.length() != 6) {
	print_usage ();
	return octave_value();
    }
    if(!args(0).is_real_type() ||
       !args(1).is_real_type() ||
       !args(2).is_real_type() ||
       !args(3).is_real_type() ||
       !args(4).is_real_type() ||
       !args(5).is_real_type()) {
        error("The arguments must be real.");
	print_usage ();	    
	return octave_value();
    }

    int len = args(0).length();
    if(len != args(1).length() ||
       len != args(2).length() ||
       len != args(3).length() ||
       len != args(4).length() ||
       len != args(5).length()) {
        error("The arguments have the same length.");
	print_usage ();	    
	return octave_value();
    }	
    
    NDArray ja = args(0).array_value();
    NDArray jb = args(1).array_value();
    NDArray jc = args(2).array_value();
    NDArray ma = args(3).array_value();
    NDArray mb = args(4).array_value();
    NDArray mc = args(5).array_value();    
    NDArray y(ja.dims());
    
    if(nargout < 2) {
	for(i = 0; i < len; i++) {
	    y.xelem(i) = gsl_sf_coupling_3j (static_cast<int>(ja.xelem(i)),
					     static_cast<int>(jb.xelem(i)),
					     static_cast<int>(jc.xelem(i)),
					     static_cast<int>(ma.xelem(i)),
					     static_cast<int>(mb.xelem(i)),
					     static_cast<int>(mc.xelem(i)));
	}
	return octave_value(y);	    
    } else {
	NDArray err(ja.dims());
	gsl_sf_result result;
	octave_value_list retval;
	for(i = 0; i < len; i++) {
	    gsl_sf_coupling_3j_e (static_cast<int>(ja.xelem(i)),
				  static_cast<int>(jb.xelem(i)),
				  static_cast<int>(jc.xelem(i)),
				  static_cast<int>(ma.xelem(i)),
				  static_cast<int>(mb.xelem(i)),
				  static_cast<int>(mc.xelem(i)),
				  &result);
	    y.xelem(i) = result.val;
	    err.xelem(i) = result.err;
	}
	retval(0) = octave_value(y);
	retval.append(err);
	return retval;
    }

    return octave_value();

}
