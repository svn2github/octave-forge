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

DEFUN_DLD(coupling_3j, args, nargout, "\
function y = coupling_3j (two_ja, two_jb, two_jc, two_ma, two_mb, two_mc)\n\n\
These routines compute the Wigner 3-j coefficient,\n\
\n\
(ja jb jc\n\
 ma mb mc)\n\
\n\
where the arguments are given in half-integer units,\n\
ja = two_ja/2, ma = two_ma/2, etc.\n\
\n\
This function is from the GNU Scientific Library,\n\
see http://www.gnu.org/software/gsl/ for documentation.\n\
")
{
    int i;
    
    gsl_set_error_handler (octave_gsl_errorhandler);
    
    if(args.length() != 6) {
	print_usage ("coupling_3j");
	return octave_value_list();
    }
    if(!args(0).is_real_type() ||
       !args(1).is_real_type() ||
       !args(2).is_real_type() ||
       !args(3).is_real_type() ||
       !args(4).is_real_type() ||
       !args(5).is_real_type()) {
        error("The arguments must be real.");
	print_usage ("coupling_3j");	    
	return octave_value_list();
    }

    int len = args(0).length();
    if(len != args(1).length() ||
       len != args(2).length() ||
       len != args(3).length() ||
       len != args(4).length() ||
       len != args(5).length()) {
        error("The arguments have the same length.");
	print_usage ("coupling_3j");	    
	return octave_value_list();
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
	return octave_value_list(y);	    
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
	retval = octave_value_list(y);
	retval.append(err);
	return retval;
    }

    return octave_value_list();

}
