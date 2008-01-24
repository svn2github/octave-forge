/*
Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
OdePkg - Package for solving ordinary differential equations with Octave

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

/*
Compile this file manually and run some tests with the following command

  bash:$ mkoctfile -v -Wall -W -Wshadow odepkg_octsolver_mebdfdae.cc \
    odepkg_auxiliary_functions.cc cash/mebdfdae.f -o odebda.oct
  bash:$ octave --quiet --eval "autoload ('odebda', [pwd, '/odebda.oct']); \
    test 'odepkg_octsolver_mebdfdae.cc'"

If you have installed 'gfortran' or 'g95' on your computer then use
the FFLAGS=-fno-automatic option because otherwise the solver function
will be broken, eg. 

  bash:$ FFLAGS="-fno-automatic ${FFLAGS}" mkoctfile -v -Wall -W \
    -Wshadow odepkg_octsolver_mebdfdae.cc odepkg_auxiliary_functions.cc \
    cash/mebdfdae.f -o odebda.oct
  octave> octave --quiet --eval "autoload ('odebda', [pwd, '/odebda.oct']); \
    test 'odepkg_octsolver_mebdfdae.cc'"

For an explanation about various parts of this source file cf. the source
file odepkg_octsolver_odebdi.cc. The implementation of that file is very
similiar to the implementation of this file.
*/

#include <config.h>
#include <oct.h>
#include <oct-map.h>
#include <f77-fcn.h>
#include <parse.h>
#include "odepkg_auxiliary_functions.h"

typedef octave_idx_type (*odepkg_mebdfdae_usrtype)
  (const octave_idx_type& N, const double& T, const double* Y,
   double* YDOT, const octave_idx_type* IPAR, const double* RPAR,
   const octave_idx_type& IERR);

typedef octave_idx_type (*odepkg_mebdfdae_jactype)
  (const double& T, const double* Y, double* PD,
   const octave_idx_type& N, const octave_idx_type& MEBAND, 
   const octave_idx_type* IPAR, const double* RPAR, 
   const octave_idx_type& IERR);

typedef octave_idx_type (*odepkg_mebdfdae_masstype)
  (const octave_idx_type& N, double* AM, const octave_idx_type* MASBND,
   const double* RPAR, const octave_idx_type* IPAR, const octave_idx_type& IERR);

extern "C" {
  F77_RET_T F77_FUNC (mebdf, MEBDF) // 3 arguments per line
    (const octave_idx_type& N, const double& T0, const double& HO,
     const double* Y0, const double& TOUT, const double& TEND,
     const octave_idx_type& MF, octave_idx_type& IDID, const octave_idx_type& LOUT,
     const octave_idx_type& LWORK, const double* WORK, const octave_idx_type& LIWORK,
     const octave_idx_type* IWORK, const octave_idx_type* MBND, const octave_idx_type* MASBND,
     const octave_idx_type& MAXDER, const octave_idx_type& ITOL, const double* RTOL,
     const double* ATOL, const double* RPAR, const octave_idx_type* IPAR,
     odepkg_mebdfdae_usrtype, odepkg_mebdfdae_jactype, odepkg_mebdfdae_masstype,
     octave_idx_type& IERR);
} // extern "C"

static octave_value_list vmebdfdaeextarg;
static octave_value vmebdfdaeodefun;
static octave_value vmebdfdaejacfun;
static octave_value vmebdfdaemass;
static octave_value vmebdfdaemassstate;

octave_idx_type odepkg_mebdfdae_usrfcn
  (const octave_idx_type& N, const double& T, const double* Y,
   double* YDOT, GCC_ATTR_UNUSED const octave_idx_type* IPAR,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type& IERR) {

  // Copy the values that come from the Fortran function element wise,
  // otherwise Octave will crash if these variables will be freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = Y[vcnt];

  // Fill the variable for the input arguments before evaluating the
  // function that keeps the set of implicit differential equations
  octave_value_list varin;
  varin(0) = T; varin(1) = A;
  for (octave_idx_type vcnt = 0; vcnt < vmebdfdaeextarg.length (); vcnt++)
    varin(vcnt+2) = vmebdfdaeextarg(vcnt);
  octave_value_list vout = feval (vmebdfdaeodefun.function_value (), varin, 1);

  // Return the results from the function evaluation to the Fortran
  // solver, again copy them and don't just create a Fortran vector
  ColumnVector vcol = vout(0).column_vector_value ();
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    YDOT[vcnt] = vcol(vcnt);

  return (true);
}

octave_idx_type odepkg_mebdfdae_jacfcn
  (const double& T, const double* Y, double* PD, const octave_idx_type& N,
   GCC_ATTR_UNUSED const octave_idx_type& MEBAND, GCC_ATTR_UNUSED const octave_idx_type* IPAR,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type& IERR) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = Y[vcnt];

  // Set the values that are needed as input arguments before calling
  // the Jacobian function
  octave_value vt  = octave_value (T);
  octave_value vy  = octave_value (A);
  octave_value_list vout = odepkg_auxiliary_evaljacode
    (vmebdfdaejacfun, vt, vy, vmebdfdaeextarg);

  // Computes the NxN iteration matrix or partial derivatives for the
  // Fortran solver of the form PD=DG/DY+1/CON*(DG/DY')
  // octave_value vbdov = vout(0) + 1/CON * vout(1);
  Matrix vbd = vout(0).matrix_value ();
  for (octave_idx_type vrow = 0; vrow < N; vrow++)
    for (octave_idx_type vcol = 0; vcol < N; vcol++)
      PD[vrow+vcol*N] = vbd (vrow, vcol);

  return (true);
}

octave_idx_type odepkg_mebdfdae_massfcn
  (const octave_idx_type& N, double* AM,
   GCC_ATTR_UNUSED const octave_idx_type* MASBND, GCC_ATTR_UNUSED const double* RPAR, 
   GCC_ATTR_UNUSED const octave_idx_type* IPAR, GCC_ATTR_UNUSED const octave_idx_type& IERR) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = 0.0;

  //  warning_with_id ("OdePkg:InvalidFunctionCall",
  //    "Mebdfdae can only handle M()=const Mass matrices");

  // Set the values that are needed as input arguments before calling
  // the Jacobian function and then call the Jacobian interface
  octave_value vt = octave_value (0.0);
  octave_value vy = octave_value (A);
  octave_value vout = odepkg_auxiliary_evalmassode
    (vmebdfdaemass, vmebdfdaemassstate, vt, vy, vmebdfdaeextarg);
  //  vmebdfdaemass.print_with_name (octave_stdout, "vmebdfdaemass", true);
  //  vmebdfdaemassstate.print_with_name (octave_stdout, "vmebdfdaemassstate", true);

  Matrix vam = vout.matrix_value ();
  for (octave_idx_type vrow = 0; vrow < N; vrow++)
    for (octave_idx_type vcol = 0; vcol < N; vcol++) {
      AM[vrow+vcol*N] = vam (vrow, vcol);
      //      octave_stdout << "AM[" << vrow+vcol*N << "] " << AM[vrow+vcol*N] << std::endl;
    }
  return (true);
}

octave_idx_type odepkg_mebdfdae_error (octave_idx_type verr) {
  
  switch (verr)
    {
    case 0: break; // Everything is fine

    case -1:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to pass one error test (error \
occured in \"mebdfi\" core solver function with error number \"%d\")", verr);
      break;

    case -2:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to pass a repeated error test \
after a successful initialisation step or because of an invalid option \
in RelTol or AbsTol (error occured in \"mebdfi\" core solver function with \
error number \"%d\")", verr);
      break;

    case -3:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to achieve a corrector \
convergence  even after reducing the step size h by a factor of 1e-10 \
(error occured in \"mebdfi\" core solver function with error number \
\"%d\")", verr);
      break;

    case -4:
      error_with_id ("OdePkg:InternalError",
	"Immediate halt because of illegal number or illegal values of input \
arguments (error occured in the \"mebdfi\" core solver function with \
error number \"%d\")", verr);
      break;

    case -5:
      error_with_id ("OdePkg:InternalError",
	"Idid was -1 on input (error occured in \"mebdfi\" core solver function \
with error number \"%d\")", verr);
      break;

    case -6:
      error_with_id ("OdePkg:InternalError",
	"Maximum number of allowed integration steps exceeded (error occured in \
\"mebdfi\" core solver function with error number \"%d\")", verr);
      break;

    case -7:
      error_with_id ("OdePkg:InternalError",
	"Stepsize grew too small (error occured in \"mebdfi\" core solver \
function with error number \"%d\")", verr);
      break;

    case -11:
      error_with_id ("OdePkg:InternalError",
	"Insufficient real workspace for the integration (error occured in \
\"mebdfi\" core solver function with error number \"%d\")", verr);
      break;

    case -12:
      error_with_id ("OdePkg:InternalError",
	"Insufficient integer workspace for the integration (error occured in \
\"mebdfi\" core solver function with error number \"%d\")", verr);
      break;

    default:
      error_with_id ("OdePkg:InternalError",
	"Unknown error (error occured in \"mebdfi\" core solver function with \
error number \"%d\")", verr);
      break;
    }

  return (true);
}

DEFUN_DLD (odebda, args, nargout,
"-*- texinfo -*-\n\
@deftypefn  {Function File} {[@var{}] =} odebda (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
@deftypefnx {Command} {[@var{sol}] =} odebda (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
@deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} odebda (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
\n\
This function file can be used to solve a set of stiff ordinary differential equations (stiff ODEs) and stiff differential algebraic equations (stiff DAEs). This function file is a wrapper file that uses Jeff Cash's Fortran solver @file{mebdfdae.f}.\n\
\n\
If this function is called with no return argument then plot the solution over time in a figure window while solving the set of ODEs that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} is a double vector that defines the time slot, @var{init} is a double vector that defines the initial values of the states, @var{opt} can optionally be a structure array that keeps the options created with the command @command{odeset} and @var{par1}, @var{par2}, @dots{} can optionally be other input arguments of any type that have to be passed to the function defined by @var{@@fun}.\n\
\n\
If this function is called with one return argument then return the solution @var{sol} of type structure array after solving the set of ODEs. The solution @var{sol} has the fields @var{x} of type double column vector for the steps chosen by the solver, @var{y} of type double column vector for the solutions at each time step of @var{x}, @var{solver} of type string for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector that keep the informations of the event function if an event function handle is set in the option argument @var{opt}.\n\
\n\
If this function is called with more than one return argument then return the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector.\n\
\n\
For example,\n\
@example\n\
function y = odepkg_equations_lorenz (t, x)\n\
  y = [10 * (x(2) - x(1));\n\
       x(1) * (28 - x(3));\n\
       x(1) * x(2) - 8/3 * x(3)];\n\
endfunction\n\
\n\
vopt = odeset (\"InitialStep\", 1e-3, \"MaxStep\", 1e-1, \\\n\
               \"OutputFcn\", @@odephas3, \"Refine\", 5);\n\
odebda (@@odepkg_equations_lorenz, [0, 25], [3 15 1], vopt);\n\
@end example\n\
@end deftypefn\n\
\n\
@seealso{odepkg}") {

  octave_idx_type nargin = args.length (); // The number of input arguments
  octave_value_list vretval;               // The cell array of return args
  Octave_map vodeopt;                      // The OdePkg options structure

  // Check number and types of all the input arguments
  if (nargin < 3) {
    print_usage ();
    return (vretval);
  }

  // If args(0)==function_handle is valid then set the vmebdfdaeodefun
  // variable that has been defined "static" before
  if (!args(0).is_function_handle () && !args(0).is_inline_function ()) {
    error_with_id ("OdePkg:InvalidArgument",
      "First input argument must be a valid function handle");
    return (vretval);
  }
  else // We store the args(0) argument in the static variable vmebdfdaeodefun
    vmebdfdaeodefun = args(0);

  // Check if the second input argument is a valid vector describing
  // the time window of solving, it may be of length 2 or longer
  if (args(1).is_scalar_type () || !odepkg_auxiliary_isvector (args(1))) {
    error_with_id ("OdePkg:InvalidArgument",
      "Second input argument must be a valid vector");
    return (vretval);
  }

  // Check if the third input argument is a valid vector describing
  // the initial values of the variables of the IDEs
  if (!odepkg_auxiliary_isvector (args(2))) {
    error_with_id ("OdePkg:InvalidArgument",
      "Third input argument must be a valid vector");
    return (vretval);
  }

  // Check if there are further input arguments ie. the options
  // structure and/or arguments that need to be passed to the
  // OutputFcn, Events and/or Jacobian etc.
  if (nargin >= 4) {

    // Fourth input argument != OdePkg option, need a default structure
    if (!args(3).is_map ()) {
      octave_value_list tmp = feval ("odeset", tmp, 1);
//      tmp = feval ("odepkg_structure_check", tmp, 1);
      vodeopt = tmp(0).map_value ();       // Create a default structure
      for (octave_idx_type vcnt = 3; vcnt < nargin; vcnt++)
        vmebdfdaeextarg(vcnt-3) = args(vcnt); // Save arguments in vmebdfdaeextarg
    }

    // Fourth input argument == OdePkg option, extra input args given too
    else if (nargin > 4) {
      octave_value_list varin;
      varin(0) = args(3); varin(1) = "oders";
      octave_value_list tmp = feval ("odepkg_structure_check", varin, 1);
      vodeopt = tmp(0).map_value ();       // Create structure from args(4)
      for (octave_idx_type vcnt = 4; vcnt < nargin; vcnt++)
        vmebdfdaeextarg(vcnt-4) = args(vcnt); // Save extra arguments
    }

    // Fourth input argument == OdePkg option, no extra input args given
    else {
      octave_value_list varin;
      varin(0) = args(3); varin(1) = "oders"; // Check structure
      octave_value_list tmp = feval ("odepkg_structure_check", varin, 1);
      vodeopt = tmp(0).map_value (); // Create a default structure
    }

  } // if (nargin >= 4)

  else { // if nargin == 3, everything else has been checked before
    octave_value_list tmp = feval ("odeset", tmp, 1);
    vodeopt = tmp(0).map_value (); // Create a default structure
  }

/* Start PREPROCESSING, ie. check which options have been set and
 * print warnings if there are options that can't be handled by this
 * solver or have not been implemented yet
 *******************************************************************/

  // Implementation of the option RelTol has been finished, this
  // option can be set by the user to another value than default value
  octave_value vreltol = odepkg_auxiliary_getmapvalue ("RelTol", vodeopt);
  if (vreltol.is_empty ()) {
    vreltol = 1.0e-6;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"RelTol\" not set, new value %3.1e is used", 
      vreltol.double_value ());
  } // vreltol.print (octave_stdout, true); return (vretval);
  if (!vreltol.is_scalar_type ()) {
    if (vreltol.length () != args(2).length ()) {
      error_with_id ("OdePkg:InvalidOption", 
        "Length of option \"RelTol\" must be the same as the number of equations");
      return (vretval);
     }
  }

  // Implementation of the option AbsTol has been finished, this
  // option can be set by the user to another value than default value
  octave_value vabstol = odepkg_auxiliary_getmapvalue ("AbsTol", vodeopt);
  if (vabstol.is_empty ()) {
    vabstol = 1.0e-6;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"AbsTol\" not set, new value %3.1e is used", 
        vabstol.double_value ());
  } // vabstol.print (octave_stdout, true); return (vretval);
  if (!vabstol.is_scalar_type ()) {
    if (vabstol.length () != args(2).length ()) {
      error_with_id ("OdePkg:InvalidOption", 
        "Length of option \"AbsTol\" must be the same as the number of equations");
      return (vretval);
     }
  }

  // Setting the tolerance type that depends on the types (scalar or
  // vector) of the options RelTol and AbsTol
  octave_idx_type vitol = 0;
  if (vreltol.is_scalar_type () && vabstol.is_scalar_type ())        vitol = 2;
  else if (vreltol.is_scalar_type () && !vabstol.is_scalar_type ())  vitol = 3;
  else if (!vreltol.is_scalar_type () && vabstol.is_scalar_type ())  vitol = 4;
  else if (!vreltol.is_scalar_type () && !vabstol.is_scalar_type ()) vitol = 5;

  // The option NormControl will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vnorm = odepkg_auxiliary_getmapvalue ("NormControl", vodeopt);
  if (!vnorm.is_empty () && (vnorm.string_value ().compare ("off") != 0))
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"NormControl\" will be ignored by this solver");

  // The option NonNegative will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vnneg = odepkg_auxiliary_getmapvalue ("NonNegative", vodeopt);
  if (!vnneg.is_empty ())
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"NonNegative\" will be ignored by this solver");

  // Implementation of the option OutputFcn has been finished, this
  // option can be set by the user to another value than default value
  octave_value vplot = odepkg_auxiliary_getmapvalue ("OutputFcn", vodeopt);
  if (vplot.is_empty () && nargout == 0) vplot = "odeplot";

  // Implementation of the option OutputSel has been finished, this
  // option can be set by the user to another value than default value
  octave_value voutsel = odepkg_auxiliary_getmapvalue ("OutputSel", vodeopt);

  // The option Refine will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vrefine = odepkg_auxiliary_getmapvalue ("Refine", vodeopt);
  if (vrefine.int_value () != 0)
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"Refine\" will be ignored by this solver");

  // Implementation of the option Stats has been finished, this option
  // can be set by the user to another value than default value
  octave_value vstats = odepkg_auxiliary_getmapvalue ("Stats", vodeopt);

  // Implementation of the option InitialStep has been finished, this
  // option can be set by the user to another value than default value
  octave_value vinitstep = odepkg_auxiliary_getmapvalue ("InitialStep", vodeopt);
  if (args(1).length () > 2) {
    if (!vinitstep.is_empty ())
      warning_with_id ("OdePkg:InvalidOption",
       "Option \"InitialStep\" will be ignored if fixed time stamps are given");
    vinitstep = args(1).vector_value ()(1);
  }
  if (vinitstep.is_empty ()) {
    vinitstep = 1.0e-6;
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"InitialStep\" not set, new value %3.1e is used",
      vinitstep.double_value ());
  }

  // Implementation of the option MaxStep has been finished, this
  // option can be set by the user to another value than default value
  octave_value vmaxstep = odepkg_auxiliary_getmapvalue ("MaxStep", vodeopt);
  if (vmaxstep.is_empty () && args(1).length () == 2) {
    vmaxstep = (args(1).vector_value ()(1) - args(1).vector_value ()(0)) / 12.5;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MaxStep\" not set, new value %3.1e is used", 
      vmaxstep.double_value ());
  }

  // Implementation of the option Events has been finished, this
  // option can be set by the user to another value than default
  // value, odepkg_structure_check already checks for a valid value
  octave_value vevents = odepkg_auxiliary_getmapvalue ("Events", vodeopt);
  octave_value_list veveres; // We save the results of Events here

  // The options 'Jacobian', 'JPattern' and 'Vectorized'
  octave_value vjac = odepkg_auxiliary_getmapvalue ("Jacobian", vodeopt);
  octave_idx_type vmebdfdaejac = 22; // We need to set this if no Jac available
  if (!vjac.is_empty ()) {
    vmebdfdaejacfun = vjac; vmebdfdaejac = 21;
  }

  // Implementation of the option 'Mass' has been finished, these
  // options can be set by the user to another value than default
  vmebdfdaemass = odepkg_auxiliary_getmapvalue ("Mass", vodeopt);
  octave_idx_type vmebdfdaemas = 0;
  if (!vmebdfdaemass.is_empty ()) {
    vmebdfdaemas = 1;
    if (vmebdfdaemass.is_function_handle () || vmebdfdaemass.is_inline_function ())
      warning_with_id ("OdePkg:InvalidOption",
        "Option \"Mass\" only supports constant mass matrices M() and not M(t,y)");
  }

  // The option MStateDependence will be ignored by this solver, the
  // core Fortran solver doesn't support this option
  vmebdfdaemassstate = odepkg_auxiliary_getmapvalue ("MStateDependence", vodeopt);
  if (vmebdfdaemassstate.string_value ().compare ("weak") != 0) // 'weak' is default
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"MStateDependence\" will be ignored by this solver");

  // The option MStateDependence will be ignored by this solver, the
  // core Fortran solver doesn't support this option
  octave_value vmvpat = odepkg_auxiliary_getmapvalue ("MvPattern", vodeopt);
  if (!vmvpat.is_empty ())
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"MvPattern\" will be ignored by this solver");

  // The option MassSingular will be ignored by this solver, the
  // core Fortran solver doesn't support this option
  octave_value vmsing = odepkg_auxiliary_getmapvalue ("MassSingular", vodeopt);
  if (!vmsing.is_empty () && (vmsing.string_value ().compare ("maybe") != 0))
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"MassSingular\" will be ignored by this solver");

  // The option InitialSlope will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vinitslope = odepkg_auxiliary_getmapvalue ("InitialSlope", vodeopt);
  if (!vinitslope.is_empty ())
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"InitialSlope\" will be ignored by this solver");

  // Implementation of the option MaxOrder has been finished, this
  // option can be set by the user to another value than default value
  octave_value vmaxder = odepkg_auxiliary_getmapvalue ("MaxOrder", vodeopt);
  if (vmaxder.is_empty ()) {
    vmaxder = 3;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MaxOrder\" not set, new value %1d is used", 
      vmaxder.int_value ());
  }
  if (vmaxder.int_value () < 1) {
    vmaxder = 3;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MaxOrder\" is zero, new value %1d is used", 
      vmaxder.int_value ());
  }

  // The option BDF will be ignored because this is a BDF solver
  octave_value vbdf = odepkg_auxiliary_getmapvalue ("BDF", vodeopt);
  if (vbdf.string_value () != "on") {
    vbdf = "on";
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"BDF\" set \"off\", new value \"on\" is used");
  }

/* Start MAINPROCESSING, set up all variables that are needed by this
 * solver and then initialize the solver function and get into the
 * main integration loop
 ********************************************************************/
  ColumnVector vTIME (args(1).vector_value ());
  NDArray vRTOL   = vreltol.array_value ();
  NDArray vATOL   = vabstol.array_value ();
  NDArray vY0     = args(2).array_value ();
  //  NDArray vYPRIME = args(3).array_value ();

  octave_idx_type N = args(2).length ();
  double T0 = vTIME(0);
  double HO = vinitstep.double_value ();
  double *Y0 = vY0.fortran_vec ();
  //  double *YPRIME = vYPRIME.fortran_vec ();
  double TOUT = T0 + vinitstep.double_value ();
  double TEND = vTIME(vTIME.length ()-1);

  octave_idx_type MF = vmebdfdaejac;
  octave_idx_type IDID = 1;
  octave_idx_type LOUT = 6; // Logical output channel "not opened"
  octave_idx_type LWORK = 42*N+3*N*N+4;
  double WORK[LWORK];
  for (octave_idx_type vcnt = 0; vcnt < LWORK; vcnt++)
    WORK[vcnt] = 0.0;
  octave_idx_type LIWORK = N+14;
  octave_idx_type IWORK[LIWORK];
  for (octave_idx_type vcnt = 0; vcnt < LIWORK; vcnt++)
    IWORK[vcnt] = 0;
  octave_idx_type MBND[4] = {N, N, N, N};
  octave_idx_type MASBND[4] = {0, N, 0, N};
  if (!vmebdfdaemass.is_empty ()) MASBND[0] = 1;
  octave_idx_type MAXDER = vmaxder.int_value ();
  octave_idx_type ITOL = vitol;
  double *RTOL = vRTOL.fortran_vec ();
  double *ATOL = vATOL.fortran_vec ();
  double RPAR[1] = {0.0};
  octave_idx_type IPAR[1] = {0};
  octave_idx_type IERR = 0;

  IWORK[0]  = N;       // Number of variables of index 1
  IWORK[1]  = 0;       // Number of variables of index 2
  IWORK[2]  = 0;       // Number of variables of index 3
  IWORK[13] = 1000000; // The maximum number of steps allowed

  // Check if the user has set some of the options "OutputFcn", "Events"
  // etc. and initialize the plot, events and the solstore functions
  octave_value vtim (T0); octave_value vsol (vY0);
  odepkg_auxiliary_solstore (vtim, vsol, voutsel, 0);
  if (!vplot.is_empty ()) odepkg_auxiliary_evalplotfun 
    (vplot, voutsel, args(1), args(2), vmebdfdaeextarg, 0);
  if (!vevents.is_empty ()) odepkg_auxiliary_evaleventfun 
    (vevents, vtim, args(2), vmebdfdaeextarg, 0);

  // We are calling the core solver here to intialize all variables
  F77_XFCN (mebdf, MEBDF, // Keep 5 arguments per line here
    (N, T0, HO, Y0, TOUT,
     TEND, MF, IDID, LOUT, LWORK,
     WORK, LIWORK, IWORK, MBND, MASBND,
     MAXDER, ITOL, RTOL, ATOL, RPAR, 
     IPAR, odepkg_mebdfdae_usrfcn, odepkg_mebdfdae_jacfcn, odepkg_mebdfdae_massfcn, IERR));
  if (f77_exception_encountered)
    (*current_liboctave_error_handler) ("Unrecoverable error in \"mebdfdae\" core solver function");
  if (IDID < 0) {
    odepkg_mebdfdae_error (IDID);
    return (vretval);
  }

  // We need that variable in the following loop after calling the
  // core solver function and before calling the plot function
  ColumnVector vcres(N);

  if (vTIME.length () == 2) {
    // Before we are entering the solver loop replace the first time
    // stamp value with FirstStep = (InitTime - InitStep)
    TOUT = TOUT - vinitstep.double_value ();

    while (TOUT < TEND) {
      // Calculate the next time stamp for that an solution is required
      TOUT = TOUT + vmaxstep.double_value ();
      TOUT = (TOUT > TEND ? TEND : TOUT);

      // Call the core Fortran solver again and again and check if an
      // exception is encountered, set IDID = 2 every time to hit
      // every point of time that is required exactly
      IDID = 2;
      F77_XFCN (mebdf, MEBDF, // Keep 5 arguments per line here
        (N, T0, HO, Y0, TOUT,
         TEND, MF, IDID, LOUT, LWORK,
         WORK, LIWORK, IWORK, MBND, MASBND,
         MAXDER, ITOL, RTOL, ATOL, RPAR, 
         IPAR, odepkg_mebdfdae_usrfcn, odepkg_mebdfdae_jacfcn, odepkg_mebdfdae_massfcn, IERR));
      if (f77_exception_encountered)
        (*current_liboctave_error_handler) ("Unrecoverable error in mebdfdae");

      if (IDID < 0) {
        odepkg_mebdfdae_error (IDID);
        return (vretval);
      }

      // This call of the Fortran solver has been successful so let us
      // plot the output and save the results
      for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
        vcres(vcnt) = Y0[vcnt];
      vsol = vcres; vtim = TOUT;
      if (!vevents.is_empty ()) {
        veveres = odepkg_auxiliary_evaleventfun (vevents, vtim, vsol, vmebdfdaeextarg, 1);
        if (!veveres(0).cell_value ()(0).is_empty ())
          if (veveres(0).cell_value ()(0).int_value () == 1) {
            ColumnVector vttmp = veveres(0).cell_value ()(2).column_vector_value ();
            Matrix vrtmp = veveres(0).cell_value ()(3).matrix_value ();
            vtim = vttmp.extract (vttmp.length () - 1, vttmp.length () - 1);
            vsol = vrtmp.extract (vrtmp.rows () - 1, 0, vrtmp.rows () - 1, vrtmp.cols () - 1);
            TOUT = TEND; // let's get out here, the Events function told us to finish
          }
      }
      if (!vplot.is_empty ()) {
        if (odepkg_auxiliary_evalplotfun (vplot, voutsel, vtim, vsol, vmebdfdaeextarg, 1)) {
          error ("Missing error message implementation");
          return (vretval);
        }
      }
      odepkg_auxiliary_solstore (vtim, vsol, voutsel, 1);
    }
  }
  else { // if (vTIME.length () > 2) we have all the time values needed
    volatile octave_idx_type vtimecnt = 1;
    octave_idx_type vtimelen = vTIME.length ();
    while (vtimecnt < vtimelen) {
      vtimecnt++; TOUT = vTIME(vtimecnt-1);

      // Call the core Fortran solver again and again and check if an
      // exception is encountered, set IDID = 2 every time to hit
      // every point of time that is required exactly
      IDID = 2;
      F77_XFCN (mebdf, MEBDF, // Keep 5 arguments per line here
        (N, T0, HO, Y0, TOUT,
         TEND, MF, IDID, LOUT, LWORK,
         WORK, LIWORK, IWORK, MBND, MASBND,
         MAXDER, ITOL, RTOL, ATOL, RPAR, 
         IPAR, odepkg_mebdfdae_usrfcn, odepkg_mebdfdae_jacfcn, odepkg_mebdfdae_massfcn, IERR));
      if (f77_exception_encountered)
        (*current_liboctave_error_handler) ("Unrecoverable error in mebdfdae");
      if (IDID < 0) {
        odepkg_mebdfdae_error (IDID);
        return (vretval);
      }

      // The last call of the Fortran solver has been successful so
      // let us plot the output and save the results
      for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
        vcres(vcnt) = Y0[vcnt];
      vsol = vcres; vtim = TOUT;
      if (!vevents.is_empty ()) {
        veveres = odepkg_auxiliary_evaleventfun (vevents, vtim, vsol, vmebdfdaeextarg, 1);
        if (!veveres(0).cell_value ()(0).is_empty ())
          if (veveres(0).cell_value ()(0).int_value () == 1) {
            ColumnVector vttmp = veveres(0).cell_value ()(2).column_vector_value ();
            Matrix vrtmp = veveres(0).cell_value ()(3).matrix_value ();
            vtim = vttmp.extract (vttmp.length () - 1, vttmp.length () - 1);
            vsol = vrtmp.extract (vrtmp.rows () - 1, 0, vrtmp.rows () - 1, vrtmp.cols () - 1);
            vtimecnt = vtimelen; // let's get out here, the Events function told us to finish
          }
      }
      if (!vplot.is_empty ()) {
        if (odepkg_auxiliary_evalplotfun (vplot, voutsel, vtim, vsol, vmebdfdaeextarg, 1)) {
          error ("Missing error message implementation");
          return (vretval);
        }
      }
     odepkg_auxiliary_solstore (vtim, vsol, voutsel, 1);
    }
  }

/* Start POSTPROCESSING, check how many arguments should be returned
 * to the caller and check which extra arguments have to be set
 *******************************************************************/

  // Set up values that come from the last Fortran call and that are
  // needed to call the OdePkg output function one last time again
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++) vcres(vcnt) = Y0[vcnt];
  vsol = vcres; vtim = TOUT;
  if (!vevents.is_empty ())
    odepkg_auxiliary_evaleventfun (vevents, vtim, vsol, vmebdfdaeextarg, 2);
  if (!vplot.is_empty ())
    odepkg_auxiliary_evalplotfun (vplot, voutsel, vtim, vsol, vmebdfdaeextarg, 2);

  // Return the results that have been stored in the
  // odepkg_auxiliary_solstore function
  octave_value vtres, vyres;
  odepkg_auxiliary_solstore (vtres, vyres, voutsel, 2);
  // odepkg_auxiliary_solstore (vtres, vyres, voutsel, 100);

  // Get the stats information as an Octave_map if the option 'Stats'
  // has been set with odeset
  octave_value_list vstatinput;
  vstatinput(0) = IWORK[4];
  vstatinput(1) = IWORK[5];
  vstatinput(2) = IWORK[6];
  vstatinput(3) = IWORK[7];
  vstatinput(4) = IWORK[8];
  vstatinput(5) = IWORK[9];
  octave_value vstatinfo;
  if (vstats.string_value () == "on" && (nargout == 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, false);
  else if (vstats.string_value () == "on" && (nargout != 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, true);


  // Set up output arguments that depends on how many output arguments
  // are desired by the caller
  if (nargout == 1) {
    Octave_map vretmap;
    vretmap.assign ("x", vtres);
    vretmap.assign ("y", vyres);
    vretmap.assign ("solver", "odebda");
    if (vstats.string_value () == "on") 
      vretmap.assign ("stats", vstatinfo);
    if (!vevents.is_empty ()) {
      vretmap.assign ("ie", veveres(0).cell_value ()(1));
      vretmap.assign ("xe", veveres(0).cell_value ()(2));
      vretmap.assign ("ye", veveres(0).cell_value ()(3));
    }
    vretval(0) = octave_value (vretmap);
  }
  else if (nargout == 2) {
    vretval(0) = vtres;
    vretval(1) = vyres;
  }
  else if (nargout == 5) {
    Matrix vempty; // prepare an empty matrix
    vretval(0) = vtres;
    vretval(1) = vyres;
    vretval(2) = vempty;
    vretval(3) = vempty;
    vretval(4) = vempty;
    if (!vevents.is_empty ()) {
      vretval(2) = veveres(0).cell_value ()(2);
      vretval(3) = veveres(0).cell_value ()(3);
      vretval(4) = veveres(0).cell_value ()(1);
    }
  }

  return (vretval);
}

/*
%!function vdy = flor (t, y, varargin)
%!  vdy = [10 * (y(2) - y(1));
%!         y(1) * (28 - y(3));
%!         y(1) * y(2) - 8/3 * y(3)];
%!function vjc = fljc (t, y, varargin)
%!  vjc(1,:) = [10, -10, 0];
%!  vjc(2,:) = [28 - y(3), 0, -y(1)];
%!  vjc(3,:) = [y(2), y(1), -8/3];
%!function vdy = frob (vt, vy, varargin)
%!  vdy(1,1) = -0.04 * vy(1) + 1e4 * vy(2) * vy(3);
%!  vdy(2,1) =  0.04 * vy(1) - 1e4 * vy(2) * vy(3) - 3e7 * vy(2)^2;
%!  vdy(3,1) =  vy(1) + vy(2) + vy(3) - 1;
%!function vjc = fjac (vt, vy, varargin)
%!  vjc(1,:) = [-0.04, 1e4 * vy(3), 1e4 * vy(2)];
%!  vjc(2,:) = [ 0.04, - 1e4 * vy(3) - 6e7 * vy(2), - 1e4 * vy(2)];
%!  vjc(3,:) = [ 1, 1, 1];
%!function vmas = fmas (vt, vy, varargin)
%!  vmas =  [1, 0, 0; 0, 1, 0; 0, 0, 0];
%!function vdy = fbal (vt, vy, varargin)
%!  vdy(1,1) = vy(2) + 3;
%!  vdy(2,1) =     -9.81; %# m/s^2
%!function [veve, vterm, vdir] = feve (vt, vy, varargin)
%!  veve  = vy(1); %# The event component that should be treaded
%!  vterm =     1; %# Terminate solving if an event is found, 1
%!  vdir  =    -1; %# Direction at zero-crossing, -1 for falling
%!
%!error
%!  warning ("off", "OdePkg:InvalidOption");
%!  B = odebda (1, [0 25], [3 15 1]);
%!error
%!  B = odebda (@flor, 1, [3 15 1]);
%!error
%!  B = odebda (@flor, [0 25], 1);
%!test
%!  B = odebda (@flor, [0 0.2], [3 15 1]);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ();
%!  [t, y] = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  [t, y] = odebda (@flor, [0 0.2], [3 15 1], 12, 13, 'KL');
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ();
%!  [t, y] = odebda (@flor, [0 0.2], [3 15 1], A, 12, 13, 'KL');
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('AbsTol', 1e-7, 'RelTol', [1e-7, 1e-7, 1e-7]);
%!  B = odebda (@flor, [0 0.2], [3 15 1]);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('AbsTol', [1e-7, 1e-7, 1e-7], 'RelTol', [1e-7, 1e-7, 1e-7]);
%!  B = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test ## These options are ignored by this solver
%!  A = odeset ('NormControl', 'on', 'NonNegative', [12 34 56]);
%!  B = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%+!test
%+!  A = odeset ('OutputFcn', @odeprint, 'OutputSel', [1 2], 'Refine', 5);
%+!  B = odebda (@flor, [0 0.05 0.1 0.15 0.2], [3 15 1], A);
%+!  assert (B.x(end), 0.2, 1e-12);
%+!  assert (B.y(end,:), [17.536442, -0.160655], 1e-3);
%+!test
%!  A = odeset ('Stats', 'on');
%!  B = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('InitialStep', 1e-10, 'MaxStep', 1e-4);
%!  B = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  B = odebda (@fbal, [0 3], [1 3], A);
%!  assert (B.ie, 1, 0);
%!  assert (B.xe, B.x(end), 0);
%!  assert (B.ye, B.y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  B = odebda (@fbal, [0 3], [1 3], A, 12, 13, 'KL');
%!  assert (B.ie, 1, 0);
%!  assert (B.xe, B.x(end), 0);
%!  assert (B.ye, B.y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  [t, y, xe, ye, ie] = odebda (@fbal, [0 3], [1 3], A);
%!  assert (ie, 1, 0);
%!  assert (xe, t(end), 0);
%!  assert (ye, y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  [t, y, xe, ye, ie] = odebda (@fbal, [0 3], [1 3], A, 12, 13, 'KL');
%!  assert (ie, 1, 0);
%!  assert (xe, t(end), 0);
%!  assert (ye, y(end,:), 0);
%!test
%!  A = odeset ('Stats', 'on');
%!  B = odebda (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-2);
%+!function vdy = fvdp (t, y, varargin)
%+!  vdy = [y(2);
%+!         ((1-y(1)^2)*y(2)-y(1))/1e-6];
%+!  endfunction
%+!function vdy = fvdj (t, y, varargin)
%+!  vdy = [0, 1;
%+!         (-2*y(1)*y(2)-1)/1e-6, (1-y(1)^2)/1e-6];
%+!  endfunction
%+!test
%+!  A = odeset ('Stats', 'on', 'RelTol', 1e-8, 
%+!    'AbsTol', 1e-10, 'InitialStep', 1e-6);
%+!  B = odebda (@fvdp, [0 2], [2 0], A);
%+!  B.stats
%+!test
%+!  C = odeset ('Jacobian', @fvdj, 'Stats', 'on', 'RelTol', 1e-8,
%+!    'AbsTol', 1e-10, 'InitialStep', 1e-6);
%+!  D = odebda (@fvdp, [0 2], [2 0], C);
%+!  D.stats
%-!test
%-!  A = odeset ('Mass', @fmas, 'AbsTol', 1e-6);
%-!  B = odebda (@frob, [0 1e9], [1, 0, 0], A);
%-!  assert (B.x(end), 1e9, 1e-10);
%-!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
%!test
%!  A = odeset ('Mass', @fmas, 'Jacobian', @fjac);
%!  B = odebda (@frob, [0 1e11], [1, 0, 0], A);
%!  assert (B.x(end), 1e11, 1e-10);
%!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
%!test
%!  A = odeset ('Mass', [1, 0, 0; 0, 1, 0; 0, 0, 0], 'Jacobian', @fjac);
%!  B = odebda (@frob, [0 1e11], [1, 0, 0], A);
%!  assert (B.x(end), 1e11, 1e-10);
%!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
%!  warning ("on", "OdePkg:InvalidOption");
*/

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
