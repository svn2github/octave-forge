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

DEFUN_DLD(coupling_6j, args, nargout, "\
function y = coupling_6j (two_ja, two_jb, two_jc, two_jd, two_je, two_jf)\n\n\
These routines compute the Wigner 6-j coefficient,\n\
\n\
{ja jb jc\n\
 jd je jf}\n\
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
	print_usage ("coupling_6j");
	return octave_value();
    }
    if(!args(0).is_real_type() ||
       !args(1).is_real_type() ||
       !args(2).is_real_type() ||
       !args(3).is_real_type() ||
       !args(4).is_real_type() ||
       !args(5).is_real_type()) {
        error("The arguments must be real.");
	print_usage ("coupling_6j");	    
	return octave_value();
    }

    int len = args(0).length();
    if(len != args(1).length() ||
       len != args(2).length() ||
       len != args(3).length() ||
       len != args(4).length() ||
       len != args(5).length()) {
        error("The arguments have the same length.");
	print_usage ("coupling_6j");	    
	return octave_value();
    }	
    
    NDArray ja = args(0).array_value();
    NDArray jb = args(1).array_value();
    NDArray jc = args(2).array_value();
    NDArray jd = args(3).array_value();
    NDArray je = args(4).array_value();
    NDArray jf = args(5).array_value();    
    NDArray y(ja.dims());
    
    if(nargout < 2) {
	for(i = 0; i < len; i++) {
	    y.xelem(i) = gsl_sf_coupling_6j (static_cast<int>(ja.xelem(i)),
					     static_cast<int>(jb.xelem(i)),
					     static_cast<int>(jc.xelem(i)),
					     static_cast<int>(jd.xelem(i)),
					     static_cast<int>(je.xelem(i)),
					     static_cast<int>(jf.xelem(i)));
	}
	return octave_value(y);	    
    } else {
	NDArray err(ja.dims());
	gsl_sf_result result;
	octave_value_list retval;
	for(i = 0; i < len; i++) {
	    gsl_sf_coupling_6j_e (static_cast<int>(ja.xelem(i)),
				  static_cast<int>(jb.xelem(i)),
				  static_cast<int>(jc.xelem(i)),
				  static_cast<int>(jd.xelem(i)),
				  static_cast<int>(je.xelem(i)),
				  static_cast<int>(jf.xelem(i)),
				  &result);
	    y.xelem(i) = result.val;
	    err.xelem(i) = result.err;
	}
	retval(0) = octave_value(y);
	retval.append(err);
	return retval;
    }

    return octave_value_list();

}
