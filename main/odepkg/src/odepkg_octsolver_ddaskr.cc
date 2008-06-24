/*
Copyright (C) 2007-2008, Thomas Treichl <treichl@users.sourceforge.net>
OdePkg - A package for solving ordinary differential equations and more

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

/*
Compile this file manually and run some tests with the following command

  bash:$ mkoctfile -v -W -Wall -Wshadow odepkg_octsolver_ddaskr.cc \
    odepkg_auxiliary_functions.cc daskr/ddaskr.f daskr/dlinpk.f -o odekdi.oct
  octave> octave --quiet --eval "autoload ('odekdi', [pwd, '/odekdi.oct']); \
    test 'odepkg_octsolver_ddaskr.cc'"

If you have installed 'gfortran' or 'g95' on your computer then use
the FFLAGS=-fno-automatic option because otherwise the solver function
will be broken, eg. 

  bash:$ FFLAGS="-fno-automatic ${FFLAGS}" mkoctfile -v -Wall -W \
    -Wshadow odepkg_octsolver_ddaskr.cc odepkg_auxiliary_functions.cc \
    cash/ddaskr.f -o odekdi.oct
  octave> octave --quiet --eval "autoload ('odekdi', [pwd, '/odekdi.oct']); \
    test 'odepkg_octsolver_ddaskr.cc'"
*/

#include <config.h>
#include <oct.h>
#include <oct-map.h>
#include <f77-fcn.h>
#include <parse.h>
#include "odepkg_auxiliary_functions.h"

typedef octave_idx_type (*odepkg_ddaskr_restype)
  (const double& T, const double* Y, const double* YPRIME,
   const double& CJ, double* DELTA, octave_idx_type& IRES,
   const double* RPAR, const octave_idx_type* IPAR);

typedef octave_idx_type (*odepkg_ddaskr_jactype)
  (const double& T, const double* Y, const double* YPRIME,
   double* PD, const double& CJ, const double* RPAR,
   const octave_idx_type* IPAR);

typedef octave_idx_type (*odepkg_ddaskr_psoltype)
  (const octave_idx_type& NEQ, const double& T, const double* Y, 
   const double* YPRIME, const double* SAVR, const double* WK,
   const octave_idx_type& CJ, double* WGHT,const double* WP,
   const octave_idx_type* IWP, double* B, const octave_idx_type& EPLIN,
   octave_idx_type& IER, const double* RPAR, const octave_idx_type* IPAR);

typedef octave_idx_type (*odepkg_ddaskr_rttype)
  (const octave_idx_type& NEQ, const double& T, const double* Y,
   const double* YP, const octave_idx_type& NRT, const double* RVAL,
   const double* RPAR, const octave_idx_type* IPAR);

// typedef octave_idx_type (*odepkg_ddaskr_krylov_jactype)
//   (odepkg_ddaskr_restype, octave_idx_type& IRES, const octave_idx_type& NEQ,
//    const double& T, const double* Y, const double* YPRIME,
//    double* REWT, const double* SAVR, const double* WK,
//    const double& H, const double& CJ, const double* WP,
//    const octave_idx_type* IWP, octave_idx_type& IER,
//    const double* RPAR, const octave_idx_type* IPAR);

// typedef octave_idx_type (*odepkg_ddaskr_krylov_psoltype)
//   (const octave_idx_type& NEQ, const double& T, const double* Y, 
//    const double* YPRIME, const double* SAVR, const double* WK,
//    const octave_idx_type& CJ, double* WGHT,const double* WP,
//    const octave_idx_type* IWP, double* B, const octave_idx_type& EPLIN,
//    octave_idx_type& IER, const double* RPAR, const octave_idx_type* IPAR);

extern "C" {
  F77_RET_T F77_FUNC (ddaskr, DDASKR)
    (odepkg_ddaskr_restype, const octave_idx_type& NEQ, const double& T,
     const double* Y, const double* YPRIME, const double& TOUT,
     const octave_idx_type* INFO, const double* RTOL, const double* ATOL,
     const octave_idx_type& IDID, const double* RWORK, const octave_idx_type& LRW,
     const octave_idx_type* IWORK, const octave_idx_type& LIW, const double* RPAR,
     const octave_idx_type* IPAR, odepkg_ddaskr_jactype, odepkg_ddaskr_psoltype,
     odepkg_ddaskr_rttype, const octave_idx_type& NRT, octave_idx_type* JROOT);
}

static octave_value_list vddaskrextarg;
static octave_value vddaskrodefun;
static octave_value vddaskrjacfun;
static octave_idx_type vddaskrneqn;

octave_idx_type odepkg_ddaskr_resfcn
  (const double& T, const double* Y, const double* YPRIME,
   GCC_ATTR_UNUSED const double& CJ, double* DELTA, GCC_ATTR_UNUSED octave_idx_type& IRES,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

  // Copy the values that come from the Fortran function element wise,
  // otherwise Octave will crash if these variables will be freed
  ColumnVector A(vddaskrneqn), APRIME(vddaskrneqn);
  for (octave_idx_type vcnt = 0; vcnt < vddaskrneqn; vcnt++) {
    A(vcnt) = Y[vcnt]; APRIME(vcnt) = YPRIME[vcnt];
  }

  // Fill the variable for the input arguments before evaluating the
  // function that keeps the set of implicit differential equations
  octave_value_list varin;
  varin(0) = T; varin(1) = A; varin(2) = APRIME;
  for (octave_idx_type vcnt = 0; vcnt < vddaskrextarg.length (); vcnt++)
    varin(vcnt+3) = vddaskrextarg(vcnt);
  octave_value_list vout = feval (vddaskrodefun.function_value (), varin, 1);

  // Return the results from the function evaluation to the Fortran
  // solver, again copy them and don't just create a Fortran vector
  ColumnVector vcol = vout(0).column_vector_value ();
  for (octave_idx_type vcnt = 0; vcnt < vddaskrneqn; vcnt++)
    DELTA[vcnt] = vcol(vcnt);

  return (true);
}

octave_idx_type odepkg_ddaskr_jacfcn
  (const double& T, const double* Y, const double* YPRIME,
   double* PD, const double& CJ, GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(vddaskrneqn), APRIME(vddaskrneqn);
  for (octave_idx_type vcnt = 0; vcnt < vddaskrneqn; vcnt++) {
    A(vcnt) = Y[vcnt]; APRIME(vcnt) = YPRIME[vcnt];
  }

  // Set the values that are needed as input arguments before calling
  // the Jacobian function
  octave_value vt  = octave_value (T);
  octave_value vy  = octave_value (A);
  octave_value vdy = octave_value (APRIME);
  octave_value_list vout = odepkg_auxiliary_evaljacide
    (vddaskrjacfun, vt, vy, vdy, vddaskrextarg);

  // Computes the NxN iteration matrix or partial derivatives for the
  // Fortran solver of the form PD=DG/DY+1/CON*(DG/DY')
  octave_value vbdov = vout(0) + CJ * vout(1);
  Matrix vbd = vbdov.matrix_value ();
  for (octave_idx_type vrow = 0; vrow < vddaskrneqn; vrow++)
    for (octave_idx_type vcol = 0; vcol < vddaskrneqn; vcol++)
      PD[vrow+vcol*vddaskrneqn] = vbd (vrow, vcol);
  // Don't know what my mistake is but the following code line never
  // worked for me (ie. the solver crashes Octave if it is used)
  //   PD = vbd.fortran_vec ();

  return (true);
}

octave_idx_type odepkg_ddaskr_rtfcn // this is a dummy function
  (GCC_ATTR_UNUSED const octave_idx_type& NEQ, GCC_ATTR_UNUSED const double& T, 
   GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* YP, 
   GCC_ATTR_UNUSED const octave_idx_type& NRT, GCC_ATTR_UNUSED const double* RVAL,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR) {
  return (true);
}

octave_idx_type odepkg_ddaskr_psolfcn // this is a dummy function
  (GCC_ATTR_UNUSED const octave_idx_type& NEQ, GCC_ATTR_UNUSED const double& T,
   GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* YPRIME,
   GCC_ATTR_UNUSED const double* SAVR, GCC_ATTR_UNUSED const double* WK,
   GCC_ATTR_UNUSED const octave_idx_type& CJ, GCC_ATTR_UNUSED double* WGHT,
   GCC_ATTR_UNUSED const double* WP, GCC_ATTR_UNUSED const octave_idx_type* IWP,
   GCC_ATTR_UNUSED double* B, GCC_ATTR_UNUSED const octave_idx_type& EPLIN,
   GCC_ATTR_UNUSED octave_idx_type& IER, GCC_ATTR_UNUSED const double* RPAR, 
   GCC_ATTR_UNUSED const octave_idx_type* IPAR) {
  return (true);
}

octave_idx_type odepkg_ddaskr_error (octave_idx_type verr) {
  
  switch (verr)
    {
    case 0: break; // Everything is fine

    case -1:
      break;

    default:
      break;
    }

  return (true);
}

// PKG_ADD: autoload ("odekdi", "dldsolver.oct");
DEFUN_DLD (odekdi, args, nargout,
"-*- texinfo -*-\n\
@deftypefn  {Command} {[@var{}] =} odekdi (@var{@@fun}, @var{slot}, @var{y0}, @var{dy0}, [@var{opt}], [@var{P1}, @var{P2}, @dots{}])\n\
@deftypefnx {Command} {[@var{sol}] =} odekdi (@var{@@fun}, @var{slot}, @var{y0}, @var{dy0}, [@var{opt}], [@var{P1}, @var{P2}, @dots{}])\n\
@deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} odekdi (@var{@@fun}, @var{slot}, @var{y0}, @var{dy0}, [@var{opt}], [@var{P1}, @var{P2}, @dots{}])\n\
\n\
This function file can be used to solve a set of stiff implicit differential equations (IDEs). This function file is a wrapper file that uses the direct method (not the Krylov method) of Petzold's, Brown's, Hindmarsh's and Ulrich's Fortran solver @file{ddaskr.f}.\n\
\n\
If this function is called with no return argument then plot the solution over time in a figure window while solving the set of IDEs that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} is a double vector that defines the time slot, @var{y0} is a double vector that defines the initial values of the states, @var{dy0} is a double vector that defines the initial values of the derivatives, @var{opt} can optionally be a structure array that keeps the options created with the command @command{odeset} and @var{par1}, @var{par2}, @dots{} can optionally be other input arguments of any type that have to be passed to the function defined by @var{@@fun}.\n\
\n\
If this function is called with one return argument then return the solution @var{sol} of type structure array after solving the set of IDEs. The solution @var{sol} has the fields @var{x} of type double column vector for the steps chosen by the solver, @var{y} of type double column vector for the solutions at each time step of @var{x}, @var{solver} of type string for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector that keep the informations of the event function if an event function handle is set in the option argument @var{opt}.\n\
\n\
If this function is called with more than one return argument then return the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector.\n\
\n\
For example,\n\
@example\n\
function res = odepkg_equations_ilorenz (t, y, yd)\n\
  res = [10 * (y(2) - y(1)) - yd(1);\n\
         y(1) * (28 - y(3)) - yd(2);\n\
         y(1) * y(2) - 8/3 * y(3) - yd(3)];\n\
endfunction\n\
\n\
vopt = odeset (\"InitialStep\", 1e-3, \"MaxStep\", 1e-1, \\\n\
               \"OutputFcn\", @@odephas3, \"Refine\", 5);\n\
odekdi (@@odepkg_equations_ilorenz, [0, 25], [3 15 1], \\\n\
        [120 81 42.333333], vopt);\n\
@end example\n\
@end deftypefn\n\
\n\
@seealso{odepkg}") {

  octave_idx_type nargin = args.length (); // The number of input arguments
  octave_value_list vretval;               // The cell array of return args
  Octave_map vodeopt;                      // The OdePkg options structure

  // Check number and types of all the input arguments
  if (nargin < 4) {
    print_usage ();
    return (vretval);
  }

  // If args(0)==function_handle then set the vddaskrodefun variable
  // that has been defined "static" before
  if (!args(0).is_function_handle () && !args(0).is_inline_function ()) {
    error_with_id ("OdePkg:InvalidArgument",
      "First input argument must be a valid function handle");
    return (vretval);
  }
  else // We store the args(0) argument in the static variable vddaskrodefun
    vddaskrodefun = args(0);

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

  // Check if the fourth input argument is a valid vector describing
  // the initial values of the derivatives of the differential equations
  if (!odepkg_auxiliary_isvector (args(3))) {
    error_with_id ("OdePkg:InvalidArgument",
      "Fourth input argument must be a valid vector");
    return (vretval);
  }

  // Check if the third and the fourth input argument (check for
  // vector already was successful before) have the same length
  if (args(2).length () != args(3).length ()) {
    error_with_id ("OdePkg:InvalidArgument",
      "Third and fourth input argument must have the same length");
    return (vretval);
  }

  // Check if there are further input arguments ie. the options
  // structure and/or arguments that need to be passed to the
  // OutputFcn, Events and/or Jacobian etc.
  if (nargin >= 5) {

    // Fifth input argument != OdePkg option, need a default structure
    if (!args(4).is_map ()) {
      octave_value_list tmp = feval ("odeset", tmp, 1);
      vodeopt = tmp(0).map_value ();        // Create a default structure
      for (octave_idx_type vcnt = 4; vcnt < nargin; vcnt++)
        vddaskrextarg(vcnt-4) = args(vcnt); // Save arguments in vddaskrextarg
    }

    // Fifth input argument == OdePkg option, extra input args given too
    else if (nargin > 5) { 
      octave_value_list varin;
      varin(0) = args(4); varin(1) = "odekdi";
      octave_value_list tmp = feval ("odepkg_structure_check", varin, 1);
      if (error_state) return (vretval);
      vodeopt = tmp(0).map_value ();        // Create structure of args(4)
      for (octave_idx_type vcnt = 5; vcnt < nargin; vcnt++)
        vddaskrextarg(vcnt-5) = args(vcnt); // Save extra arguments
    }

    // Fifth input argument == OdePkg option, no extra input args given
    else {
      octave_value_list varin;
      varin(0) = args(4); varin(1) = "odekdi"; // Check structure
      octave_value_list tmp = feval ("odepkg_structure_check", varin, 1);
      if (error_state) return (vretval);
      vodeopt = tmp(0).map_value (); // Create a default structure
    }

  } // if (nargin >= 5)

  else { // if nargin == 4, everything else has been checked before
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
      "Option \"RelTol\" not set, new value 1e-6 is used");
  }
  else if (!vreltol.is_scalar_type ()) {
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
      "Option \"AbsTol\" not set, new value 1e-6 is used");
  }
  else if (!vabstol.is_scalar_type ()) {
    if (vabstol.length () != args(2).length ()) {
      error_with_id ("OdePkg:InvalidOption", 
        "Length of option \"AbsTol\" must be the same as the number of equations");
      return (vretval);
     }
  }

  // Setting the tolerance type that depends on the types (scalar or
  // vector) of the options RelTol and AbsTol
  octave_idx_type vitol;
  if (vreltol.is_scalar_type () && vabstol.is_scalar_type ()) vitol = 0;
  else if (vreltol.length () == vabstol.length ()) vitol = 1;
  else {
    error_with_id ("OdePkg:InvalidOption", 
      "Options \"RelTol\" and \"AbsTol\" must have same length");
    return (vretval);
  }

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
  else if (vinitstep.is_empty ()) {
    vinitstep = 1.0e-6;
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"InitialStep\" not set, new value 1e-6 is used");
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
  if (!vjac.is_empty ()) vddaskrjacfun = vjac;

  // The option Mass will be ignored by this solver. We can't handle
  // Mass-matrix options with IDE problems
  octave_value vmass = odepkg_auxiliary_getmapvalue ("Mass", vodeopt);
  if (!vmass.is_empty ())
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"Mass\" will be ignored by this solver");

  // The option MStateDependence will be ignored by this solver. We
  // can't handle Mass-matrix options with IDE problems
  octave_value vmst = odepkg_auxiliary_getmapvalue ("MStateDependence", vodeopt);
  if (!vmst.is_empty () && (vmst.string_value ().compare ("weak") != 0))
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MStateDependence\" will be ignored by this solver");

  // The option MvPattern will be ignored by this solver. We
  // can't handle Mass-matrix options with IDE problems
  octave_value vmvpat = odepkg_auxiliary_getmapvalue ("MvPattern", vodeopt);
  if (!vmvpat.is_empty ())
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MvPattern\" will be ignored by this solver");

  // The option MvPattern will be ignored by this solver. We
  // can't handle Mass-matrix options with IDE problems
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
      "Option \"MaxOrder\" not set, new value 3 is used");
  }
  else if (vmaxder.int_value () < 1) {
    vmaxder = 3;
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"MaxOrder\" is zero, new value 3 is used");
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
  NDArray vTIME   = args(1).array_value ();
  NDArray vY      = args(2).array_value ();
  NDArray vYPRIME = args(3).array_value ();
  NDArray vRTOL   = vreltol.array_value ();
  NDArray vATOL   = vabstol.array_value ();

  vddaskrneqn = args(2).length ();
  double T       = vTIME(0);
  double TEND    = vTIME(vTIME.length () - 1);
  double *Y      = vY.fortran_vec ();
  double *YPRIME = vYPRIME.fortran_vec ();

  octave_idx_type IDID = 0;
  double *RTOL = vRTOL.fortran_vec ();
  double *ATOL = vATOL.fortran_vec ();
  double RPAR[1] = {0.0};
  octave_idx_type IPAR[1] = {0};

  octave_idx_type NRT = 0;
  OCTAVE_LOCAL_BUFFER (octave_idx_type, JROOT, NRT);
  for (octave_idx_type vcnt = 0; vcnt < NRT; vcnt++) JROOT[vcnt] = 0;

  octave_idx_type LRW = 60 + vddaskrneqn * (9 + vddaskrneqn) + 3 * NRT;
  OCTAVE_LOCAL_BUFFER (double, RWORK, LRW);
  for (octave_idx_type vcnt = 0; vcnt < LRW; vcnt++) RWORK[vcnt] = 0.0;

  octave_idx_type LIW = 40 + vddaskrneqn;
  OCTAVE_LOCAL_BUFFER (octave_idx_type, IWORK, LIW);
  for (octave_idx_type vcnt = 0; vcnt < LIW; vcnt++) IWORK[vcnt] = 0;

  octave_idx_type N = 20;
  OCTAVE_LOCAL_BUFFER (octave_idx_type, INFO, N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++) INFO[vcnt] = 0;

  INFO[0]   = 0;      // Define that it is the initial first call
  INFO[1]   = vitol;  // RelTol/AbsTol are scalars or vectors
  INFO[2]   = 1;      // An intermediate output is wanted
  INFO[3]   = 0;      // Integrate behind TEND
  if (!vjac.is_empty ()) INFO[4]   = 1;
  else INFO[4] = 0;   // Internally calculate a Jacobian? 0..yes
  INFO[5]   = 0;      // Have a full Jacobian matrix? 0..yes
  INFO[6]   = 1;      // Use the value for maximum step size
  INFO[7]   = 1;      // The initial step size
  INFO[8]   = 1;      // Use MaxOrder 5 as default? 1..no
  INFO[11]  = 0;      // direct method (not krylov)

  RWORK[1] = vmaxstep.double_value ();  // MaxStep value
  RWORK[2] = vinitstep.double_value (); // InitialStep value
  IWORK[2] = vmaxder.int_value ();      // MaxOrder value

  // If the user has set an OutputFcn or an Events function then
  // initialize these IO-functions for further use
  octave_value vtim (T); octave_value vsol (vY); octave_value vyds (vYPRIME);
  odepkg_auxiliary_solstore (vtim, vsol, voutsel, 0);
  if (!vplot.is_empty ()) 
    odepkg_auxiliary_evalplotfun (vplot, voutsel, args(1), args(2), vddaskrextarg, 0);

  octave_value_list veveideargs;
  veveideargs(0) = vsol; 
  veveideargs(1) = vyds;
  Cell veveidearg (veveideargs);
  if (!vevents.is_empty ())
    odepkg_auxiliary_evaleventfun (vevents, vtim, veveidearg, vddaskrextarg, 0);

  // We are calling the core solver here to intialize all variables
  F77_XFCN (ddaskr, DDASKR, // Keep 5 arguments per line here
    (odepkg_ddaskr_resfcn, vddaskrneqn, T, Y, YPRIME,
     TEND, INFO, RTOL, ATOL, IDID, 
     RWORK, LRW, IWORK, LIW, RPAR, 
     IPAR, odepkg_ddaskr_jacfcn, odepkg_ddaskr_psolfcn, odepkg_ddaskr_rtfcn, NRT, 
     JROOT));

  if (IDID < 0) {
    odepkg_ddaskr_error (IDID);
    return (vretval);
  }

  // We need that variable in the following loop after calling the
  // core solver function and before calling the plot function
  ColumnVector vcres(vddaskrneqn);
  ColumnVector vydrs(vddaskrneqn);

  if (vTIME.length () == 2) {

    INFO[0] = 1; // Set this info variable ie. continue solving

    while (T < TEND) {
      F77_XFCN (ddaskr, DDASKR, // Keep 5 arguments per line here
        (odepkg_ddaskr_resfcn, vddaskrneqn, T, Y, YPRIME,
         TEND, INFO, RTOL, ATOL, IDID, 
         RWORK, LRW, IWORK, LIW, RPAR, 
         IPAR, odepkg_ddaskr_jacfcn, odepkg_ddaskr_psolfcn, odepkg_ddaskr_rtfcn, NRT, 
         JROOT));

      if (IDID < 0) {
        odepkg_ddaskr_error (IDID);
        return (vretval);
      }

      // This call of the Fortran solver has been successful so let us
      // plot the output and save the results
      for (octave_idx_type vcnt = 0; vcnt < vddaskrneqn; vcnt++) {
	vcres(vcnt) = Y[vcnt]; vydrs(vcnt) = YPRIME[vcnt];
      }
      vsol = vcres; vyds = vydrs; vtim = T;

      if (!vevents.is_empty ()) {
        veveideargs(0) = vsol;
        veveideargs(1) = vyds;
	veveidearg = veveideargs;
        veveres = odepkg_auxiliary_evaleventfun (vevents, vtim, veveidearg, vddaskrextarg, 1);
        if (!veveres(0).cell_value ()(0).is_empty ())
          if (veveres(0).cell_value ()(0).int_value () == 1) {
            ColumnVector vttmp = veveres(0).cell_value ()(2).column_vector_value ();
            Matrix vrtmp = veveres(0).cell_value ()(3).matrix_value ();
            vtim = vttmp.extract (vttmp.length () - 1, vttmp.length () - 1);
            vsol = vrtmp.extract (vrtmp.rows () - 1, 0, vrtmp.rows () - 1, vrtmp.cols () - 1);
            T = TEND; // let's get out here, the Events function told us to finish
          }
      }

      if (!vplot.is_empty ()) {
        if (odepkg_auxiliary_evalplotfun (vplot, voutsel, vtim, vsol, vddaskrextarg, 1)) {
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
  // needed to call the OdePkg output function a last time again
  for (octave_idx_type vcnt = 0; vcnt < vddaskrneqn; vcnt++) {
    vcres(vcnt) = Y[vcnt]; vydrs(vcnt) = YPRIME[vcnt];
  }
  vsol = vcres; vyds = vydrs; vtim = T;
  veveideargs(0) = vsol;
  veveideargs(1) = vyds;
  veveidearg = veveideargs;
  if (!vevents.is_empty ())
    odepkg_auxiliary_evaleventfun (vevents, vtim, vsol, vddaskrextarg, 2);
  if (!vplot.is_empty ())
    odepkg_auxiliary_evalplotfun (vplot, voutsel, vtim, vsol, vddaskrextarg, 2);

  // Return the results that have been stored in the
  // odepkg_auxiliary_solstore function
  octave_value vtres, vyres;
  odepkg_auxiliary_solstore (vtres, vyres, voutsel, 2);

  // Get the stats information as an Octave_map if the option 'Stats'
  // has been set with odeset 
  // "nsteps", "nfailed", "nfevals", "npds", "ndecomps", "nlinsols"
  octave_value_list vstatinput;
  vstatinput(0) = IWORK[10];
  vstatinput(1) = IWORK[14];
  vstatinput(2) = IWORK[11];
  vstatinput(3) = IWORK[12];
  vstatinput(4) = 0;
  vstatinput(5) = IWORK[18];
  octave_value vstatinfo;
  if ((vstats.string_value ().compare ("on") == 0) && (nargout == 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, false);
  else if ((vstats.string_value ().compare ("on") == 0) && (nargout != 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, true);

  // Set up output arguments that depend on how many output arguments
  // are desired -- check the nargout variable
  if (nargout == 1) {
    Octave_map vretmap;
    vretmap.assign ("x", vtres);
    vretmap.assign ("y", vyres);
    vretmap.assign ("solver", "odekdi");
    if (vstats.string_value ().compare ("on") == 0)
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
%! # We are using the "Van der Pol" implementation for all tests that
%! # are done for this function. We also define a Jacobian, Events,
%! # pseudo-Mass implementation. For further tests we also define a
%! # reference solution (computed at high accuracy) and an OutputFcn
%!function [vres] = fpol (vt, vy, vyd, varargin)
%!  vres = [vy(2) - vyd(1); 
%!          (1 - vy(1)^2) * vy(2) - vy(1) - vyd(2)];
%!function [vjac, vyjc] = fjac (vt, vy, vyd, varargin) %# its Jacobian
%!  vjac = [0, 1; -1 - 2 * vy(1) * vy(2), 1 - vy(1)^2];
%!  vyjc = [-1, 0; 0, -1];
%!function [vjac, vyjc] = fjcc (vt, vy, vyd, varargin) %# sparse type
%!  vjac = sparse ([0, 1; -1 - 2 * vy(1) * vy(2), 1 - vy(1)^2]);
%!  vyjc = sparse ([-1, 0; 0, -1]);
%!function [vval, vtrm, vdir] = feve (vt, vy, vyd, varargin)
%!  vval = vyd;         %# We use the derivatives
%!  vtrm = zeros (2,1); %# that's why component 2
%!  vdir = ones (2,1);  %# seems to not be exact
%!function [vval, vtrm, vdir] = fevn (vt, vy, vyd, varargin)
%!  vval = vyd;         %# We use the derivatives
%!  vtrm = ones (2,1); %# that's why component 2
%!  vdir = ones (2,1);  %# seems to not be exact
%!function [vref] = fref () %# The computed reference solut
%!  vref = [0.32331666704577, -1.83297456798624];
%!function [vout] = fout (vt, vy, vflag, varargin)
%!  if (regexp (char (vflag), 'init') == 1)
%!    if (size (vt) != [2, 1] && size (vt) != [1, 2])
%!      error ('"fout" step "init"');
%!    end
%!  elseif (isempty (vflag))
%!    if (size (vt) ~= [1, 1]) error ('"fout" step "calc"'); end
%!    vout = false;
%!  elseif (regexp (char (vflag), 'done') == 1)
%!    if (size (vt) ~= [1, 1]) error ('"fout" step "done"'); end
%!  else error ('"fout" invalid vflag');
%!  end
%!
%! %# Turn off output of warning messages for all tests, turn them on
%! %# again if the last test is called
%!error %# input argument number one
%!  warning ('off', 'OdePkg:InvalidOption');
%!  vsol = odekdi (1, [0, 2], [2; 0], [0; -2]);
%!error %# input argument number two
%!  vsol = odekdi (@fpol, 1, [2; 0], [0; -2]);
%!error %# input argument number three
%!  vsol = odekdi (@fpol, [0, 2], 1, [0; -2]);
%!error %# input argument number four
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], 1);
%!test %# one output argument
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2]);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!  assert (isfield (vsol, 'solver'));
%!  assert (vsol.solver, 'odekdi');
%!test %# two output arguments
%!  [vt, vy] = odekdi (@fpol, [0, 2], [2; 0], [0; -2]);
%!  assert ([vt(end), vy(end,:)], [2, fref], 1e-3);
%!test %# five output arguments and no Events
%!  [vt, vy, vxe, vye, vie] = odekdi (@fpol, [0, 2], [2; 0], [0; -2]);
%!  assert ([vt(end), vy(end,:)], [2, fref], 1e-3);
%!  assert ([vie, vxe, vye], []);
%!test %# anonymous function instead of real function
%!  fvdb = @(vt,vy,vyd) [vy(2)-vyd(1); (1-vy(1)^2)*vy(2)-vy(1)-vyd(2)];
%!  vsol = odekdi (fvdb, [0, 2], [2; 0], [0; -2]);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# extra input arguments passed trhough
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], 12, 13, 'KL');
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# empty OdePkg structure *but* extra input arguments
%!  vopt = odeset;
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt, 12, 13, 'KL');
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!error %# strange OdePkg structure
%!  vopt = struct ('foo', 1);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!test %# AbsTol option
%!  vopt = odeset ('AbsTol', 1e-4);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# AbsTol and RelTol option
%!  vopt = odeset ('AbsTol', 1e-8, 'RelTol', 1e-8);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# RelTol and NormControl option -- higher accuracy
%!  vopt = odeset ('RelTol', 1e-8, 'NormControl', 'on');
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-4);
%!test %# Keeps initial values while integrating
%!  vopt = odeset ('NonNegative', 2);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-1);
%!test %# Details of OutputSel and Refine can't be tested
%!  vopt = odeset ('OutputFcn', @fout, 'OutputSel', 1, 'Refine', 5);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!test %# Stats must add further elements in vsol
%!  vopt = odeset ('Stats', 'on');
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert (isfield (vsol, 'stats'));
%!  assert (isfield (vsol.stats, 'nsteps'));
%!test %# InitialStep option
%!  vopt = odeset ('InitialStep', 1e-8);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(2)-vsol.x(1)], [1e-8], 1e-7);
%!test %# MaxStep option
%!  vopt = odeset ('MaxStep', 1e-3);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end-1)-vsol.x(end-2)], [1e-2], 1e-1);
%!test %# Events option add further elements in vsol
%!  vopt = odeset ('Events', @feve);
%!  vsol = odekdi (@fpol, [0, 10], [2; 0], [0; -2], vopt);
%!  assert (isfield (vsol, 'ie'));
%!  assert (vsol.ie(1), 2);
%!  assert (isfield (vsol, 'xe'));
%!  assert (isfield (vsol, 'ye'));
%!test %# Events option, now stop integration
%!  warning ('off', 'OdePkg:HideWarning');
%!  vopt = odeset ('Events', @fevn, 'MaxStep', 0.1);
%!  vsol = odekdi (@fpol, [0, 10], [2; 0], [0; -2], vopt);
%!  assert ([vsol.ie, vsol.xe, vsol.ye], ...
%!    [2.0, 2.49537, -0.82867, -2.67469], 1e-1);
%!test %# Events option, five output arguments
%!  vopt = odeset ('Events', @fevn, 'MaxStep', 0.1);
%!  [vt, vy, vxe, vye, vie] = odekdi (@fpol, [0, 10], [2; 0], [0; -2], vopt);
%!  assert ([vie, vxe, vye], ...
%!    [2.0, 2.49537, -0.82867, -2.67469], 1e-1);
%!  warning ('on', 'OdePkg:HideWarning');
%!test %# Jacobian option
%!  vopt = odeset ('Jacobian', @fjac, 'InitialStep', 1e-12);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Jacobian option and sparse return value
%!  vopt = odeset ('Jacobian', @fjcc);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!
%! %# test for JPattern option is missing
%! %# test for Vectorized option is missing
%! %# test for Mass option is missing
%! %# test for MStateDependence option is missing
%! %# test for MvPattern option is missing
%! %# test for InitialSlope option is missing
%!
%!test %# MaxOrder option
%!  vopt = odeset ('MaxOrder', 5);
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# BDF option
%!  vopt = odeset ('BDF', 'on');
%!  vsol = odekdi (@fpol, [0, 2], [2; 0], [0; -2], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!
%!  warning ('on', 'OdePkg:InvalidOption');
*/

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
