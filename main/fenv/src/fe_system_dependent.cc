/*
## Copyright (C) 2008 Grzegorz Timoszuk <gtimoszuk@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.
##
*/

/* 
## Author: Grzegorz Timoszuk <gtimoszuk@gmail.com>
##

## TODO: use .configure or other Octaveforge package installation procedure to determine the architecture and make system-dependent compilation of the source code, so that only x86 and x86_64 systems would compile the assembly code

## Revision history: 
##
##	2008-10-21, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##		Compile show_flags() code only if X86_PROCESSOR is defined
##	2008-10-10, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##		Code cleanup. Improvements to change_prec() function 
##		(removal of previous side-effects dependence). 
## 		Octave wrappers fenvset{prec,round} to 
##		system_dependent().
##		change_prec() now returns its exit code to system_dependent(),
## 		which passes it by as its return value 
##	2008-10-09, Grzegorz Timoszuk <gtimoszuk@gmail.com>
##		Initial release
##

*/

#include <octave/oct.h>
#include <stdio.h>
#include <string>
#include <fenv.h>
#include <math.h>

using namespace std;

#define FP87_SINGLE_PREC 	0x0000 /* single precision x87 FPU */
#define FP87_DOUBLE_PREC 	0x0200 /* double precision x87 FPU */
#define FP87_DOUBLEEXT_PREC 	0x0300 /* double extended precision x87 FPU */

#define FP87_PREC_MASK	 	0xFCFF /* x87 FPU control word bits: 8 and 9 */

//reads and prints out x86/x86_64 CPU control words for x87 and SSE
//good for debugging
void show_flags() {
#ifdef X86_PROCESSOR
    unsigned short cw;
    unsigned int cww;
    //x87 control word
    asm volatile ("fstcw %0" : : "m" (cw));
    fprintf(stderr, "x87 FPU: %#06x \n", cw);
    //SSE control world
    asm volatile ("stmxcsr %0" : : "m" (cww));
    fprintf(stderr, "MXCSR: %#010x \n", cww);
#endif
}


//Change the rounding mode; returns zero if successful
int change_rounding(int rounding) {
#pragma STDC FENV_ACCESS ON
    return(fesetround(rounding));
#pragma STDC FENV_ACCESS OFF
}

//Changing x86/x86_64 CPU precision for x87
//Note: changing SSE precision is impossible
int change_prec(short prec) {
#ifdef X86_PROCESSOR
	short cw;
	asm volatile ("fstcw %0" : : "m" (cw));
	cw &= FP87_PREC_MASK;
	cw |= prec;
	// show_flags();
	asm volatile ("fldcw %0" : : "m" (cw) );
	// show_flags();
	return(0);
#else
	return(-1);
#endif
}


DEFUN_DLD (fe_system_dependent, args, nargout, "Function usage\n fe_system_dependent ((\"rounding\" (\"zero\"|\"up\"|\"down\"|\"normal\")+)|(\"precision\" (\"single\"|\"double\"|\"double ext\")+)+\n")
{
    //main function making simple parsing of argument and 
    //calling functions that change  rounding method or precision
    octave_value_list retval;
    int args_count = args.length();
    int err = -1; //error code; err == 0 if successful

    if (args_count != 2) {
	print_usage();
    } else {
	if (args(0).string_value().compare("rounding") == 0) {
	    if (args(1).string_value().compare("zero") == 0) {
		err = change_rounding(FE_TOWARDZERO);
	    } else if (args(1).string_value().compare("up") == 0) {
		err = change_rounding(FE_UPWARD);
	    } else if (args(1).string_value().compare("down") == 0) {
		err = change_rounding(FE_DOWNWARD);
	    } else if (args(1).string_value().compare("normal") == 0) {
		err = change_rounding(FE_TONEAREST);
	    } else {
		print_usage();
	    }
	} else if (args(0).string_value().compare("precision") == 0) {
	    if (args(1).string_value().compare("single") == 0) {
		err = change_prec(FP87_SINGLE_PREC);
	    } else if (args(1).string_value().compare("double") == 0) {
		err = change_prec(FP87_DOUBLE_PREC);
	    } else if (args(1).string_value().compare("double ext") == 0) {
		err = change_prec(FP87_DOUBLEEXT_PREC);
	    } else {
		print_usage();
	    }
	} else {
	    print_usage();
	}
    }
    retval(0) = err;
    return retval;
}

