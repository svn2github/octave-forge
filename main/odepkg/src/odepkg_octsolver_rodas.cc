/*
Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
OdePkg - Package for solving ordinary differential equations with this software

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

 bash:~$ mkoctfile -v -Wall -W -Wshadow odepkg_octsolver_rodas.cc \
   odepkg_auxiliary_functions.cc hairer/rodas.f hairer/dc_decsol.f \
   hairer/decsol.f -o oders.oct
  octave> octave --quiet --eval "autoload ('oders', [pwd, '/oders.oct']); \
    test 'odepkg_octsolver_rodas.cc'"
*/

#include <config.h>
#include <oct.h>
#include <f77-fcn.h>
#include <oct-map.h>
#include <parse.h>
#include "odepkg_auxiliary_functions.h"

/* -*- texinfo -*-
 * @subsection Source File @file{odepkg_octsolver_rodas.cc}
 *
 * @deftp {Typedef} {octave_idx_type (*odepkg_rodas_usrtype)}
 * This @code{typedef} is used to define the input and output arguments of the user function for the DAE problem that is further needed by the Fortran core solver @code{rodas}. The implementation of this @code{typedef} is
 *
 * @example
 * typedef octave_idx_type (*odepkg_rodas_usrtype)
 *   (const octave_idx_type& N, const double& X, const double* Y,
 *    double* F, GCC_ATTR_UNUSED const double* RPAR,
 *    GCC_ATTR_UNUSED const octave_idx_type* IPAR);
 * @end example
 * @end deftp
 */
typedef octave_idx_type (*odepkg_rodas_usrtype)
  (const octave_idx_type& N, const double& X, const double* Y, double* F,
   GCC_ATTR_UNUSED const double* RPAR, 
   GCC_ATTR_UNUSED const octave_idx_type* IPAR);

/* -*- texinfo -*-
 * @deftp {Typedef} {octave_idx_type (*odepkg_rodas_jactype)}
 *
 * This @code{typedef} is used to define the input and output arguments of the @code{Jacobian} function for the DAE problem that is further needed by the Fortran core solver @code{rodas}. The implementation of this @code{typedef} is
 *
 * @example
 * typedef octave_idx_type (*odepkg_rodas_jactype)
 *   (const octave_idx_type& N, const double& X, const double* Y, 
 *    double* DFY, GCC_ATTR_UNUSED const octave_idx_type* LDFY,
 *   GCC_ATTR_UNUSED const double* RPAR,
 *   GCC_ATTR_UNUSED const octave_idx_type* IPAR);
 * @end example
 * @end deftp
 */
typedef octave_idx_type (*odepkg_rodas_jactype)
  (const octave_idx_type& N, const double& X, const double* Y, double* DFY,
   GCC_ATTR_UNUSED const octave_idx_type& LDFY,
   GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR);

/* -*- texinfo -*-
 * @deftp {Typedef} {octave_idx_type (*odepkg_rodas_masstype)}
 *
 * This @code{typedef} is used to define the input and output arguments of the @code{Mass} function for the DAE problem that is further needed by the Fortran core solver @code{rodas}. The implementation of this @code{typedef} is
 *
 * @example
 * typedef octave_idx_type (*odepkg_rodas_masstype)
 *   (const octave_idx_type& N, double* AM, 
 *    GCC_ATTR_UNUSED const octave_idx_type* LMAS, 
 *    GCC_ATTR_UNUSED const double* RPAR,
 *    GCC_ATTR_UNUSED const octave_idx_type* IPAR);
 * @end example
 * @end deftp
 */
typedef octave_idx_type (*odepkg_rodas_masstype)
  (const octave_idx_type& N, double* AM, 
   GCC_ATTR_UNUSED const octave_idx_type* LMAS, 
   GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR);

/* -*- texinfo -*-
 * @deftp {Typedef} {octave_idx_type (*odepkg_rodas_soltype)}
 *
 * This @code{typedef} is used to define the input and output arguments of the @code{Solution} function for the DAE problem that is further needed by the Fortran core solver @code{rodas}. The implementation of this @code{typedef} is
 *
 * @example
 * typedef octave_idx_type (*odepkg_rodas_soltype)
 *   (const octave_idx_type& NR, const double& XOLD, const double& X,
 *    const double* Y, const double* CONT, const octave_idx_type* LRC,
 *    const octave_idx_type& N, GCC_ATTR_UNUSED const double* RPAR,
 *    GCC_ATTR_UNUSED const octave_idx_type* IPAR, octave_idx_type& IRTRN);
 * @end example
 * @end deftp
 */
typedef octave_idx_type (*odepkg_rodas_soltype)
  (const octave_idx_type& NR, const double& XOLD, const double& X,
   const double* Y, const double* CONT, const octave_idx_type* LRC,
   const octave_idx_type& N, GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR, octave_idx_type& IRTRN);

/* -*- texinfo -*-
 * @deftp {Typedef} {octave_idx_type (*odepkg_rodas_dfxtype)}
 *
 * This @code{typedef} is used to define the input and output arguments of the @code{DFX} function for the DAE problem that is further needed by the Fortran core solver @code{rodas}. The implementation of this @code{typedef} is
 *
 * @example
 * typedef octave_idx_type (*odepkg_rodas_dfxtype)
 *   (GCC_ATTR_UNUSED const octave_idx_type& N,
 *    GCC_ATTR_UNUSED const double& X,
 *    GCC_ATTR_UNUSED const double* Y,
 *    GCC_ATTR_UNUSED const double* FX,
 *    GCC_ATTR_UNUSED const double* RPAR,
 *    GCC_ATTR_UNUSED const octave_idx_type* IPAR);
 * @end example
 * @end deftp
 */
typedef octave_idx_type (*odepkg_rodas_dfxtype)
  (GCC_ATTR_UNUSED const octave_idx_type& N, GCC_ATTR_UNUSED const double& X,
   GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* FX,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR);

extern "C" {
/* -*- texinfo -*-
 * @deftp {Prototype} {F77_RET_T F77_FUNC (rodas, RODAS)} (const octave_idx_type& N, odepkg_rodas_usrtype, const octave_idx_type& IFCN, const octave_idx_type& X, const double* Y, const double& XEND, const double& H, const double* RTOL, const double* ATOL, const octave_idx_type& ITOL, odepkg_rodas_jactype, const octave_idx_type& IJAC, const octave_idx_type& MLJAC, const octave_idx_type& MUJAC, odepkg_rodas_dfxtype, const octave_idx_type& IDFX, odepkg_rodas_masstype, const octave_idx_type& IMAS, const octave_idx_type& MLMAS, const octave_idx_type& MUMAS, odepkg_rodas_soltype, const octave_idx_type& IOUT, const double* WORK, const octave_idx_type& LWORK, const octave_idx_type* IWORK, const octave_idx_type& LIWORK, GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR, const octave_idx_type& IDID);
 *
 * The prototype @code{F77_FUNC (rodas, RODAS)} is used to represent the information about the Fortran core solver @code{rodas} that is defined in the Fortran source file @file{rodas.f} (cf. the Fortran source file @file{rodas.f} for further details).
 * @end deftp
 */
  F77_RET_T F77_FUNC (rodas, RODAS)
    (const octave_idx_type& N, odepkg_rodas_usrtype, const octave_idx_type& IFCN,
     const octave_idx_type& X, const double* Y, const double& XEND,
     const double& H, const double* RTOL, const double* ATOL,
     const octave_idx_type& ITOL, odepkg_rodas_jactype, const octave_idx_type& IJAC,
     const octave_idx_type& MLJAC, const octave_idx_type& MUJAC, odepkg_rodas_dfxtype,
     const octave_idx_type& IDFX, odepkg_rodas_masstype, const octave_idx_type& IMAS,
     const octave_idx_type& MLMAS, const octave_idx_type& MUMAS, odepkg_rodas_soltype,
     const octave_idx_type& IOUT, const double* WORK, const octave_idx_type& LWORK,
     const octave_idx_type* IWORK, const octave_idx_type& LIWORK,
     GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR,
     const octave_idx_type& IDID);

/* -*- texinfo -*-
 * @deftp {Prototype} {double F77_FUNC (contro, CONTRO)} (const octave_idx_type& I, const double* S, const double* CONT, const octave_idx_type* LRC);
 *
 * The prototype @code{F77_FUNC (contro, CONTRO)} is used to represent the information about a continous output calculation for the @code{rodas} algorithm that is defined in the Fortran source file @file{rodas.f} (cf. the Fortran source file @file{rodas.f} for further details).
 * @end deftp
 */
  double F77_FUNC (contro, CONTRO)
    (const octave_idx_type& I, const double& S,
     const double* CONT, const octave_idx_type* LRC);

/* -*- texinfo -*-
 * @deftp {Prototype} {F77_RET_T F77_FUNC (dfx, DFX)} (GCC_ATTR_UNUSED const octave_idx_type& N, GCC_ATTR_UNUSED const double& X, GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* FX, GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR);
 *
 * The prototype @code{F77_RET_T F77_FUNC (dfx, DFX)} is used to represent the information about a DFX dummy function (that will never be called because it is not supported) for the @code{rodas} algorithm that is defined in the Fortran source file @file{rodas.f} (cf. the Fortran source file @file{rodas.f} for further details).
 * @end deftp
 */
  F77_RET_T F77_FUNC (dfx, DFX)
    (GCC_ATTR_UNUSED const octave_idx_type& N, GCC_ATTR_UNUSED const double& X,
     GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* FX,
     GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR);
} // extern "C"

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value_list} {vrodasextarg}
 *
 * This static variable is used to store the extra arguments that are needed by some or by all of the @code{OutputFcn}, the @code{Jacobian} function, the @code{Mass} function and the @code{Events} function while solving the DAE problem.
 * @end deftypevr
 */
static octave_value_list vrodasextarg;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasodefun}
 *
 * This static variable is used to store the value for the user function that defines the set of DAEs.
 * @end deftypevr
 */
static octave_value vrodasodefun;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasjacfun}
 *
 * This static variable is used to store the value for the @code{Jacobian} function that may be needed from the Fortran core solver while solving.
 * @end deftypevr
 */
static octave_value vrodasjacfun;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasevefun}
 *
 * This static variable is used to store the value for the @code{Events} function that may be needed from the Fortran core solver while solving.
 * @end deftypevr
 */
static octave_value vrodasevefun;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasevesol}
 *
 * This static variable is used to store the results that come from the @code{Events} function while solving.
 * @end deftypevr
 */
static octave_value_list vrodasevesol;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodaspltfun}
 *
 * This static variable is used to store the value for the @code{OutputFcn} function if any.
 * @end deftypevr
 */
static octave_value vrodaspltfun;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasoutsel}
 *
 * This static variable is used to store the value for the @code{OutputSel} vector if any.
 * @end deftypevr
 */
static octave_value vrodasoutsel;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasrefine}
 *
 * This static variable is used to store the value for the @code{Refine} option if any.
 * @end deftypevr
 */
static octave_value vrodasrefine;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasmass}
 *
 * This static variable is used to store the value for the @code{Mass} function while solving.
 * @end deftypevr
 */
static octave_value vrodasmass;

/* -*- texinfo -*-
 * @deftypevr {Variable} {static octave_value} {vrodasmassstate}
 *
 * This static variable is used to store the value for the @code{MStateDependence} string if any.
 * @end deftypevr
 */
static octave_value vrodasmassstate;

/* -*- texinfo -*-
 * @deftypefn {Function} {octave_idx_type} {odepkg_rodas_usrfcn} (const octave_idx_type& N, const double& X, const double* Y, double* F, GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR)
 *
 * Return @code{true} if the evaluation of the user type function (that is defined for a special DAE problem in Octave) was successful, otherwise return @code{false}. This function is directly called from the Fortran core solver @code{rodas}. The input arguments of this function are
 *
 * @itemize @minus
 * @item @var{N}: The number of equations that are defined for the DAE--problem
 * @item @var{X}: The actual time stamp for the current function evaluation
 * @item @var{Y}: The function values from the last successful integration step of length @var{N}
 * @item @var{F}: The solution vector that needs to be calculated of length @var{N}
 * @item @var{RPAR}: The real parameters that are passed to the user function (unused)
 * @item @var{IPAR}: The integer parameters that are passed to the user function (unused)
 * @end itemize
 * @end deftypefn
 */
octave_idx_type odepkg_rodas_usrfcn
  (const octave_idx_type& N, const double& X, const double* Y, 
   double* F, GCC_ATTR_UNUSED const double* RPAR, 
   GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

  // Copy the values that come from the Fortran function element wise,
  // otherwise Octave will crash if these variables will be freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++) {
    A(vcnt) = Y[vcnt];
    //    octave_stdout << "bin hier Y[" << vcnt << "] " << Y[vcnt] << std::endl;
    //    octave_stdout << "bin hier T " << X << std::endl;
  }

  // Fill the variable for the input arguments before evaluating the
  // function that keeps the set of differential algebraic equations
  octave_value_list varin;
  varin(0) = X; varin(1) = A;
  for (octave_idx_type vcnt = 0; vcnt < vrodasextarg.length (); vcnt++)
    varin(vcnt+2) = vrodasextarg(vcnt);
  octave_value_list vout = feval (vrodasodefun.function_value (), varin, 1);

  // Return the results from the function evaluation to the Fortran
  // solver, again copy them and don't just create a Fortran vector
  ColumnVector vcol = vout(0).column_vector_value ();
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    F[vcnt] = vcol(vcnt);

  return (true);
}

/* -*- texinfo -*-
 * @deftypefn {Function} {octave_idx_type} {odepkg_mebdfi_jacfcn} (const octave_idx_type& N, const double& X, const double* Y, double* DFY, GCC_ATTR_UNUSED const octave_idx_type& LDFY, GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR)
 *
 * Return @code{true} if the evaluation of the @code{Jacobian} function (that is defined for a special DAE problem in Octave) was successful, otherwise return @code{false}. This function is directly called from the Fortran core solver @code{rodas}. The input arguments of this function are
 *
 * @itemize @minus
 * @item @var{N}: The number of equations that are defined for the DAE--problem
 * @item @var{X}: The actual time stamp for the current function evaluation
 * @item @var{Y}: The function values from the last successful integration step of length @var{N}
 * @item @var{DFY}: The values of partial derivatives of the Jacobian matrix of size @var{N}
 * @item @var{LDFY}:
 * @item @var{RPAR}: The real parameters that are passed to the user function (unused)
 * @item @var{IPAR}: The integer parameters that are passed to the user function (unused)
 * @end itemize
 * @end deftypefn
 */
octave_idx_type odepkg_rodas_jacfcn
  (const octave_idx_type& N, const double& X, const double* Y,
   double* DFY, GCC_ATTR_UNUSED const octave_idx_type& LDFY,
   GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = Y[vcnt];
  // octave_stdout << "bin drinne" << std::endl;

  // Set the values that are needed as input arguments before calling
  // the Jacobian function and then call the Jacobian interface
  octave_value vt = octave_value (X);
  octave_value vy = octave_value (A);
  octave_value vout = odepkg_auxiliary_evaljacode
    (vrodasjacfun, vt, vy, vrodasextarg);

   Matrix vdfy = vout.matrix_value ();
   for (octave_idx_type vcol = 0; vcol < N; vcol++)
     for (octave_idx_type vrow = 0; vrow < N; vrow++)
       DFY[vrow+vcol*N] = vdfy (vrow, vcol);

  return (true);
}

/* -*- texinfo -*-
 * odepkg_rodas_massfcn - TODO
 */
F77_RET_T odepkg_rodas_massfcn
  (const octave_idx_type& N, double* AM,
   GCC_ATTR_UNUSED const octave_idx_type* LMAS,
   GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = 0.0;

  //  warning_with_id ("OdePkg:InvalidFunctionCall",
  //    "Rodas can only handle M()=const Mass matrices");

  // Set the values that are needed as input arguments before calling
  // the Jacobian function and then call the Jacobian interface
  octave_value vt = octave_value (0.0);
  octave_value vy = octave_value (A);
  octave_value vout = odepkg_auxiliary_evalmassode
    (vrodasmass, vrodasmassstate, vt, vy, vrodasextarg);

  Matrix vam = vout.matrix_value ();
  for (octave_idx_type vrow = 0; vrow < N; vrow++)
    for (octave_idx_type vcol = 0; vcol < N; vcol++)
      AM[vrow+vcol*N] = vam (vrow, vcol);

  return (true);
}

/* -*- texinfo -*-
 * odepkg_rodas_solfcn - TODO
 */
octave_idx_type odepkg_rodas_solfcn
  (const octave_idx_type& NR, const double& XOLD, const double& X,
   const double* Y, const double* CONT, const octave_idx_type* LRC,
   const octave_idx_type& N, GCC_ATTR_UNUSED const double* RPAR,
   GCC_ATTR_UNUSED const octave_idx_type* IPAR, octave_idx_type& IRTRN) {

  // Copy the values that come from the Fortran function element-wise,
  // otherwise Octave will crash if these variables are freed
  ColumnVector A(N);
  for (octave_idx_type vcnt = 0; vcnt < N; vcnt++)
    A(vcnt) = Y[vcnt];

  // Set the values that are needed as input arguments before calling
  // the Output function, the solstore function or the Events function
  octave_value vt = octave_value (X);
  octave_value vy = octave_value (A);

  // Check if an 'Events' function has been set by the user
  if (!vrodasevefun.is_empty ()) {
    vrodasevesol = odepkg_auxiliary_evaleventfun 
      (vrodasevefun, vt, vy, vrodasextarg, 1);
    if (!vrodasevesol(0).cell_value ()(0).is_empty ())
      if (vrodasevesol(0).cell_value ()(0).int_value () == 1) {
	ColumnVector vttmp = vrodasevesol(0).cell_value ()(2).column_vector_value ();
	Matrix vrtmp = vrodasevesol(0).cell_value ()(3).matrix_value ();
	vt = vttmp.extract (vttmp.length () - 1, vttmp.length () - 1);
	vy = vrtmp.extract (vrtmp.rows () - 1, 0, vrtmp.rows () - 1, vrtmp.cols () - 1);
	IRTRN = (vrodasevesol(0).cell_value ()(0).int_value () ? -1 : 0);
      }
  }

  // Save the solutions that come from the Fortran core solver if this
  // is not the initial first call to this function
  if (NR > 1) odepkg_auxiliary_solstore (vt, vy, vrodasoutsel, 1);

  // Check if an 'OutputFcn' has been set by the user (including the
  // values of the options for 'OutputSel' and 'Refine')
  if (!vrodaspltfun.is_empty ()) {
    if (vrodasrefine.int_value () > 0) {
      ColumnVector B(N); double vtb = 0.0;
      for (octave_idx_type vcnt = 1; vcnt < vrodasrefine.int_value (); vcnt++) {

	// Calculate time stamps between XOLD and X and get the
	// results at these time stamps
	vtb = (X - XOLD) * vcnt / vrodasrefine.int_value () + XOLD;
	for (octave_idx_type vcou = 0; vcou < N; vcou++)
	  B(vcou) = F77_FUNC (contro, CONTRO) (vcou+1, vtb, CONT, LRC);

	// Evaluate the 'OutputFcn' with the approximated values from
	// the F77_FUNC before the output of the results is done
	octave_value vyr = octave_value (B);
	octave_value vtr = octave_value (vtb);
	odepkg_auxiliary_evalplotfun
	  (vrodaspltfun, vrodasoutsel, vtr, vyr, vrodasextarg, 1);
      }
    }
    // Evaluate the 'OutputFcn' with the results from the solver, if
    // the OutputFcn returns true then set a negative value in IRTRN
    IRTRN = - odepkg_auxiliary_evalplotfun
      (vrodaspltfun, vrodasoutsel, vt, vy, vrodasextarg, 1);
  }

  //  if (NR > 10) IRTRN = -1;

  return (true);
}

/* -*- texinfo -*-
 * odepkg_rodas_solfcn - TODO dummy function
 */
octave_idx_type odepkg_rodas_dfxfcn
  (GCC_ATTR_UNUSED const octave_idx_type& N, GCC_ATTR_UNUSED const double& X,
   GCC_ATTR_UNUSED const double* Y, GCC_ATTR_UNUSED const double* FX,
   GCC_ATTR_UNUSED const double* RPAR, GCC_ATTR_UNUSED const octave_idx_type* IPAR) {

   warning_with_id ("OdePkg:InvalidFunctionCall",
     "function odepkg_rodas_dfxfcn: This warning message should never appear");
   return (true);
}

DEFUN_DLD (oders, args, nargout, 
"-*- texinfo -*-\n\
@deftypefn  {Function File} {[@var{}] =} oders (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
@deftypefnx {Command} {[@var{sol}] =} oders (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
@deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} oders (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])\n\
\n\
This function file can be used to solve a set of non--stiff ordinary differential equations (non--stiff ODEs) and non-stiff differential algebraic equations (non-stiff DAEs). This function file is a wrapper to @file{odepkg_mexsolver_rodas.c} that uses Hairer's and Wanner's Fortran solver @file{rodas.f}.\n\
\n\
If this function is called with no return argument then plot the solution over time in a figure window while solving the set of ODEs that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} is a double vector that defines the time slot, @var{init} is a double vector that defines the initial values of the states, @var{opt} can optionally be a structure array that keeps the options created with the command @command{odeset} and @var{par1}, @var{par2}, @dots{} can optionally be other input arguments of any type that have to be passed to the function defined by @var{@@fun}.\n\
\n\
If this function is called with one return argument then return the solution @var{sol} of type structure array after solving the set of ODEs. The solution @var{sol} has the fields @var{x} of type double column vector for the steps chosen by the solver, @var{y} of type double column vector for the solutions at each time step of @var{x}, @var{solver} of type string for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector that keep the informations of the event function if an event function handle is set in the option argument @var{opt}.\n\
\n\
If this function is called with more than one return argument then return the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector.\n\
\n\
Run examples with the command\n\
@example\n\
demo oders\n\
@end example\n\
@end deftypefn\n\
\n\
@seealso{odepkg}") {

  octave_idx_type nargin = args.length (); // The number of input arguments
  octave_value_list vretval;               // The cell array of return args
  Octave_map vodeopt;                      // The OdePkg options structure

  // Check number and types of all input arguments
  if (nargin < 3) {
    print_usage ();
    return (vretval);
  }

  // If args(0)==function_handle is valid then set the vrodasodefun
  // variable that has been defined "static" before
  if (!args(0).is_function_handle () && !args(0).is_inline_function ()) {
    error_with_id ("OdePkg:InvalidArgument",
      "First input argument must be a valid function handle");
    return (vretval);
  }
  else // We store the args(0) argument in the static variable vrodasodefun
    vrodasodefun = args(0);

  // Check if the second input argument is a valid vector describing
  // the time window that should be solved, it may be of length 2 ONLY
  if (args(1).is_scalar_type () || !odepkg_auxiliary_isvector (args(1))) {
    error_with_id ("OdePkg:InvalidArgument",
      "Second input argument must be a valid vector");
    return (vretval);
  }

  // Check if the thirt input argument is a valid vector describing
  // the initial values of the variables of the differential equations
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
        vrodasextarg(vcnt-3) = args(vcnt); // Save arguments in vrodasextarg
    }

    // Fourth input argument == OdePkg option, extra input args given too
    else if (nargin > 4) {
      octave_value_list varin;
      varin(0) = args(3); varin(1) = "oders";
      octave_value_list tmp = feval ("odepkg_structure_check", varin, 1);
      vodeopt = tmp(0).map_value ();       // Create structure from args(4)
      for (octave_idx_type vcnt = 4; vcnt < nargin; vcnt++)
        vrodasextarg(vcnt-4) = args(vcnt); // Save extra arguments
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
  if (vreltol.is_scalar_type () && (vreltol.length () == vabstol.length ()))
    vitol = 0;
  else if (!vreltol.is_scalar_type () && (vreltol.length () == vabstol.length ()))
    vitol = 1;
  else {
    error_with_id ("OdePkg:InvalidOption",
      "Values of \"RelTol\" and \"AbsTol\" must have same length");
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
  vrodaspltfun = odepkg_auxiliary_getmapvalue ("OutputFcn", vodeopt);
  if (vrodaspltfun.is_empty () && nargout == 0) vrodaspltfun = "odeplot";

  // Implementation of the option OutputSel has been finished, this
  // option can be set by the user to another value than default value
  vrodasoutsel = odepkg_auxiliary_getmapvalue ("OutputSel", vodeopt);

  // Implementation of the option OutputSel has been finished, this
  // option can be set by the user to another value than default value
  vrodasrefine = odepkg_auxiliary_getmapvalue ("Refine", vodeopt);

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
  vrodasevefun = odepkg_auxiliary_getmapvalue ("Events", vodeopt);

  // Implementation of the option 'Jacobian' has been finished, these
  // options can be set by the user to another value than default
  vrodasjacfun = odepkg_auxiliary_getmapvalue ("Jacobian", vodeopt);
  octave_idx_type vrodasjac = 0; // We need to set this if no Jac available
  if (!vrodasjacfun.is_empty ()) vrodasjac = 1;

  // The option JPattern will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vrodasjacpat = odepkg_auxiliary_getmapvalue ("JPattern", vodeopt);
  if (!vrodasjacpat.is_empty ())
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"JPattern\" will be ignored by this solver");

  // The option Vectorized will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vrodasvectorize = odepkg_auxiliary_getmapvalue ("Vectorized", vodeopt);
  if (vrodasvectorize.string_value ().compare ("off") != 0)
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"Vectorized\" will be ignored by this solver");

  // Implementation of the option 'Mass' has been finished, these
  // options can be set by the user to another value than default
  vrodasmass = odepkg_auxiliary_getmapvalue ("Mass", vodeopt);
  octave_idx_type vrodasmas = 0;
  if (!vrodasmass.is_empty ()) {
    vrodasmas = 1;
    if (vrodasmass.is_function_handle () || vrodasmass.is_inline_function ())
      warning_with_id ("OdePkg:InvalidOption",
        "Option \"Mass\" only supports constant mass matrices M() and not M(t,y)");
  }

  // The option MStateDependence will be ignored by this solver, the
  // core Fortran solver doesn't support this option
  vrodasmassstate = odepkg_auxiliary_getmapvalue ("MStateDependence", vodeopt);
  if (vrodasmassstate.string_value ().compare ("weak") != 0) // 'weak' is default
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

  // The option MaxOrder will be ignored by this solver, the core
  // Fortran solver doesn't support this option
  octave_value vmaxder = odepkg_auxiliary_getmapvalue ("MaxOrder", vodeopt);
  if (!vmaxder.is_empty ())
    warning_with_id ("OdePkg:InvalidOption",
      "Option \"MaxOrder\" will be ignored by this solver");

  // The option BDF will be ignored by this solver, the core Fortran
  // solver doesn't support this option
  octave_value vbdf = odepkg_auxiliary_getmapvalue ("BDF", vodeopt);
  if (vbdf.string_value ().compare ("off") != 0)
    warning_with_id ("OdePkg:InvalidOption", 
      "Option \"BDF\" will be ignored by this solver");

/* Start MAINPROCESSING, set up all variables that are needed by this
 * solver and then initialize the solver function and get into the
 * main integration loop
 ********************************************************************/
  NDArray vY0 = args(2).array_value ();
  NDArray vRTOL = vreltol.array_value ();
  NDArray vATOL = vabstol.array_value ();

  octave_idx_type N = args(2).length ();
  octave_idx_type IFCN = 1;
  double X = args(1).vector_value ()(0);
  double* Y = vY0.fortran_vec ();
  double XEND = args(1).vector_value ()(1);
  double H = vinitstep.double_value ();
  double *RTOL = vRTOL.fortran_vec ();
  double *ATOL = vATOL.fortran_vec ();
  octave_idx_type ITOL = vitol;
  octave_idx_type IJAC = vrodasjac;
  octave_idx_type MLJAC=N;
  octave_idx_type MUJAC=N;

  octave_idx_type IDFX=0;
  octave_idx_type IMAS=vrodasmas;
  octave_idx_type MLMAS=N;
  octave_idx_type MUMAS=N;
  octave_idx_type IOUT = 1; // The SOLOUT function will always be called
  octave_idx_type LWORK = N*(N+N+N+14)+20;
  double WORK[LWORK];
  for (octave_idx_type vcnt = 0; vcnt < LWORK; vcnt++) WORK[vcnt] = 0.0;
  octave_idx_type LIWORK = N+20;
  octave_idx_type IWORK[LIWORK];
  for (octave_idx_type vcnt = 0; vcnt < LIWORK; vcnt++) IWORK[vcnt] = 0;
  double RPAR[1] = {0.0};
  octave_idx_type IPAR[1] = {0};
  octave_idx_type IDID = 0;

  WORK[1] = vmaxstep.double_value (); // Set the maximum step size

  // Check if the user has set some of the options "OutputFcn", "Events"
  // etc. and initialize the plot, events and the solstore functions
  octave_value vtim = args(1).vector_value ()(0);
  octave_value vsol = args(2);
  odepkg_auxiliary_solstore (vtim, vsol, vrodasoutsel, 0);
  if (!vrodaspltfun.is_empty ()) odepkg_auxiliary_evalplotfun 
    (vrodaspltfun, vrodasoutsel, args(1), args(2), vrodasextarg, 0);
  if (!vrodasevefun.is_empty ())
    odepkg_auxiliary_evaleventfun (vrodasevefun, vtim, args(2), vrodasextarg, 0);

  // We are calling the core solver and solve the set of ODEs or DAEs
  F77_XFCN (rodas, RODAS, // Keep 5 arguments per line here
            (N, odepkg_rodas_usrfcn, IFCN, X, Y, 
	     XEND, H, RTOL, ATOL, ITOL, 
	     odepkg_rodas_jacfcn, IJAC, MLJAC, MUJAC, odepkg_rodas_dfxfcn,
	     IDFX, odepkg_rodas_massfcn, IMAS, MLMAS, MUMAS, 
	     odepkg_rodas_solfcn, IOUT, WORK, LWORK, IWORK,
	     LIWORK, RPAR, IPAR, IDID));

  if (f77_exception_encountered)
    (*current_liboctave_error_handler) 
      ("Unrecoverable error in \"rodas\" core solver function");

  if (IDID < 0) {
    // odepkg_auxiliary_mebdfanalysis (IDID);
    error_with_id ("hugh:hugh", "error after solving");
    vretval(0) = 0.0;
    return (vretval);
  }

/* Start POSTPROCESSING, check how many arguments should be returned
 * to the caller and check which extra arguments have to be set
 *******************************************************************/

  // Return the results that have been stored in the
  // odepkg_auxiliary_solstore function
  octave_value vtres, vyres;
  odepkg_auxiliary_solstore (vtres, vyres, vrodasoutsel, 2);

  // Set up variables to make it possible to call the cleanup
  // functions of 'OutputFcn' and 'Events' if any
  Matrix vlastline;
  vlastline = vyres.matrix_value ();
  vlastline = vlastline.extract (vlastline.rows () - 1, 0,
                                 vlastline.rows () - 1, vlastline.cols () - 1);
  octave_value vted = octave_value (XEND);
  octave_value vfin = octave_value (vlastline);

  if (!vrodaspltfun.is_empty ()) odepkg_auxiliary_evalplotfun
    (vrodaspltfun, vrodasoutsel, vted, vfin, vrodasextarg, 2);
  if (!vrodasevefun.is_empty ()) odepkg_auxiliary_evaleventfun
    (vrodasevefun, vted, vfin, vrodasextarg, 2);
  
  // Get the stats information as an Octave_map if the option 'Stats'
  // has been set with odeset
  octave_value_list vstatinput;
  vstatinput(0) = IWORK[16];
  vstatinput(1) = IWORK[17];
  vstatinput(2) = IWORK[13];
  vstatinput(3) = IWORK[14];
  vstatinput(4) = IWORK[18];
  vstatinput(5) = IWORK[19];
  octave_value vstatinfo;
  if ((vstats.string_value ().compare ("on") == 0) && (nargout == 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, false);
  else if ((vstats.string_value ().compare ("on") == 0) && (nargout != 1))
    vstatinfo = odepkg_auxiliary_makestats (vstatinput, true);

  // Set up output arguments that depend on how many output arguments
  // are desired from the caller
  if (nargout == 1) {
    Octave_map vretmap;
    vretmap.assign ("x", vtres);
    vretmap.assign ("y", vyres);
    vretmap.assign ("solver", "oders");
    if (!vstatinfo.is_empty ()) // Event implementation
      vretmap.assign ("stats", vstatinfo);
    if (!vrodasevefun.is_empty ()) {
      vretmap.assign ("ie", vrodasevesol(0).cell_value ()(1));
      vretmap.assign ("xe", vrodasevesol(0).cell_value ()(2));
      vretmap.assign ("ye", vrodasevesol(0).cell_value ()(3));
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
    if (!vrodasevefun.is_empty ()) {
      vretval(2) = vrodasevesol(0).cell_value ()(2);
      vretval(3) = vrodasevesol(0).cell_value ()(3);
      vretval(4) = vrodasevesol(0).cell_value ()(1);
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
%!error
%!  warning ("off", "OdePkg:InvalidOption");
%!  B = oders (1, [0 25], [3 15 1]);
%!error
%!  B = oders (@flor, 1, [3 15 1]);
%!error
%!  B = oders (@flor, [0 25], 1);
%!test
%!  B = oders (@flor, [0 0.2], [3 15 1]);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ();
%!  [t, y] = oders (@flor, [0 0.2], [3 15 1], A);
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  [t, y] = oders (@flor, [0 0.2], [3 15 1], 12, 13, 'KL');
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ();
%!  [t, y] = oders (@flor, [0 0.2], [3 15 1], A, 12, 13, 'KL');
%!  assert (t(end), 0.2, 1e-12);
%!  assert (y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!error
%!  A = odeset ('AbsTol', 1e-7, 'RelTol', [1e-7, 1e-7, 1e-7]);
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
%!test
%!  A = odeset ('AbsTol', [1e-7, 1e-7, 1e-7], 'RelTol', [1e-7, 1e-7, 1e-7]);
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test ## These options are ignored by this solver
%!  A = odeset ('NormControl', 'on', 'NonNegative', [12 34 56]);
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%+!test
%+!  A = odeset ('OutputFcn', @odeplot, 'OutputSel', [1 2], 'Refine', 5);
%+!  B = oders (@flor, [0 0.2], [3 15 1], A);
%+!  assert (B.x(end), 0.2, 1e-12);
%+!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('Stats', 'on');
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('InitialStep', 1e-10, 'MaxStep', 1e-4);
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
%!  assert (B.x(end), 0.2, 1e-12);
%!  assert (B.y(end,:), [17.536442, -0.160655, 52.696175], 1e-3);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  B = oders (@fbal, [0 3], [1 3], A);
%!  assert (B.ie, 1, 0);
%!  assert (B.xe, B.x(end), 0);
%!  assert (B.ye, B.y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  B = oders (@fbal, [0 3], [1 3], A, 12, 13, 'KL');
%!  assert (B.ie, 1, 0);
%!  assert (B.xe, B.x(end), 0);
%!  assert (B.ye, B.y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  [t, y, xe, ye, ie] = oders (@fbal, [0 3], [1 3], A);
%!  assert (ie, 1, 0);
%!  assert (xe, t(end), 0);
%!  assert (ye, y(end,:), 0);
%!test
%!  A = odeset ('Events', @feve, 'AbsTol', 1e-10);
%!  [t, y, xe, ye, ie] = oders (@fbal, [0 3], [1 3], A, 12, 13, 'KL');
%!  assert (ie, 1, 0);
%!  assert (xe, t(end), 0);
%!  assert (ye, y(end,:), 0);
%!test
%!  A = odeset ('Stats', 'on');
%!  B = oders (@flor, [0 0.2], [3 15 1], A);
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
%+!  B = oders (@fvdp, [0 2], [2 0], A);
%+!  B.stats
%+!test
%+!  C = odeset ('Jacobian', @fvdj, 'Stats', 'on', 'RelTol', 1e-8,
%+!    'AbsTol', 1e-10, 'InitialStep', 1e-6);
%+!  D = oders (@fvdp, [0 2], [2 0], C);
%+!  D.stats
%!test
%!  A = odeset ('Mass', @fmas);
%!  B = oders (@frob, [0 1e11], [1, 0, 0], A);
%!  assert (B.x(end), 1e11, 1e-10);
%!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
%!test
%!  A = odeset ('Mass', [1, 0, 0; 0, 1, 0; 0, 0, 0]);
%!  B = oders (@frob, [0 1e11], [1, 0, 0], A);
%!  assert (B.x(end), 1e11, 1e-10);
%!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
%!test
%!  A = odeset ('Mass', [1, 0, 0; 0, 1, 0; 0, 0, 0], 'Jacobian', @fjac);
%!  B = oders (@frob, [0 1e11], [1, 0, 0], A);
%!  assert (B.x(end), 1e11, 1e-10);
%!  assert (B.y(end,:), [0.20833e-7, 0.83333e-13, 0.99999e0], 1e-3);
*/

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
