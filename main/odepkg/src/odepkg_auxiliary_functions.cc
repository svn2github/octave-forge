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

#include "config.h"
#include "oct.h"
#include "oct-map.h"
#include "parse.h"
#include "odepkg_auxiliary_functions.h"

/* -*- texinfo -*-
 * @subsection Source file @file{odepkg_auxiliary_functions.cc}
 *
 * @deftypefn {Function} octave_value odepkg_auxiliary_getmapvalue (std::string vnam, Octave_map vmap)
 *
 * Return the @code{octave_value} from the field that is identified by the string @var{vnam} of the @code{Octave_map} that is given by @var{vmap}. The input arguments of this function are
 *
 * @itemize @minus
 * @item @var{vnam}: The name of the field whose value is returned
 * @item @var{vmap}: The map that is checked for the presence of the field
 * @end itemize
 * @end deftypefn
 */
octave_value odepkg_auxiliary_getmapvalue (std::string vnam, Octave_map vmap) {
  Octave_map::const_iterator viter;
  viter = vmap.seek (vnam);
  return (vmap.contents(viter)(0));
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_idx_type odepkg_auxiliary_isvector (octave_value vval)
 *
 * Return the constant @code{true} if the value of the input argument @var{vval} is a valid numerical vector of @code{length > 1} or return the constant @code{false} otherwise. The input argument of this function is
 *
 * @itemize @minus
 * @item @var{vval}: The @code{octave_value} that is checked for being a valid numerical vector
 * @end itemize
 * @end deftypefn
 */
octave_idx_type odepkg_auxiliary_isvector (octave_value vval) {
  if (vval.is_numeric_type () && 
      vval.ndims () == 2 && // ported from the is_vector.m file
      (vval.rows () == 1 || vval.columns () == 1))
    return (true);
  else
    return (false);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_value_list odepkg_auxiliary_evaleventfun (octave_value veve, octave_value vt, octave_value vy, octave_value_list vextarg, octave_idx_type vdeci)
 *
 * Return the values that come from the evaluation of the @code{Events} user function. The return arguments depend on the call to this function, ie. if @var{vdeci} is @code{0} then initilaization of the @code{Events} function is performed. If @var{vdeci} is @code{1} then a normal evaluation of the @code{Events} function is performed and the information from the @code{Events} evaluation is returned (cf. @file{odepkg_event_handle.m} for further details). If @var{vdeci} is @code{2} then cleanup of the @code{Events} function is performed and nothing is returned. The input arguments of this function are
 * @itemize @minus
 * @item @var{veve}: The @code{Events} function that is evaluated
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of ODEs at time @var{vt}
 * @item @var{vextarg}: Extra arguments that are feed through to the @code{Events} function
 * @item @var{vdeci}: A decision flag that describes what evaluation should be done
 * @end itemize
 * @end deftypefn
 */
octave_value_list odepkg_auxiliary_evaleventfun
  (octave_value veve, octave_value vt, octave_value vy, 
   octave_value_list vextarg, octave_idx_type vdeci) {

  // Set up the input arguments before the 'odepkg_event_handle'
  // function can be called from the file odepkg_event_handle.m
  octave_value_list varin;
  varin(0) = veve;
  varin(1) = vt;
  varin(2) = vy;
  for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
    varin(vcnt+4) = vextarg(vcnt);

  octave_value_list varout;
  switch (vdeci) {
    case 0:
      varin(3) = "init";
      feval ("odepkg_event_handle", varin, 0);
      break;

    case 1:
      varin(3) = "";
      // varout = feval ("odepkg_event_handle", varin, 1);
      varout = feval ("odepkg_event_handle", varin, 1);
      break;

    case 2:
      varin(3) = "done";
      feval ("odepkg_event_handle", varin, 0);
      break;

    default:
      break;
  }

  // varout(0).print_with_name (octave_stdout, "varout{0}", true);
  // varout(1).print_with_name (octave_stdout, "varout{1}", true);
  // varout(2).print_with_name (octave_stdout, "varout{2}", true);
  // varout(3).print_with_name (octave_stdout, "varout{3}", true);
  return (varout);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_idx_type odepkg_auxiliary_evalplotfun (octave_value vplt, octave_value vsel, octave_value vt, octave_value vy, octave_value_list vextarg, octave_idx_type vdeci)
 *
 * Return a constant that comes from the evaluation of the @code{OutputFcn} function. The return argument depends on the call to this function, ie. if @var{vdeci} is @code{0} then initilaization of the @code{OutputFcn} function is performed and nothing is returned. If @var{vdeci} is @code{1} then a normal evaluation of the @code{OutputFcn} function is performed and either the constant @code{true} is returned if solving should be stopped or @code{false} is returned if solving should be continued (cf. @file{odeplot.m} for further details). If @var{vdeci} is @code{2} then cleanup of the @code{OutputFcn} function is performed and nothing is returned. The input arguments of this function are
 * @itemize @minus
 * @item @var{vplt}: The @code{OutputFcn} function that is evaluated
 * @item @var{vsel}: The output selection vector for which values should be treated
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of ODEs at time @var{vt}
 * @item @var{vextarg}: Extra arguments that are feed through to the @code{OutputFcn} function
 * @item @var{vdeci}: A decision flag that describes what evaluation should be done
 * @end itemize
 * @end deftypefn
 */
octave_idx_type odepkg_auxiliary_evalplotfun 
  (octave_value vplt, octave_value vsel, octave_value vt,
   octave_value vy, octave_value_list vextarg, octave_idx_type vdeci) {

  ColumnVector vresult  (vy.vector_value ());
  ColumnVector vreduced (vy.length ());

  // Check if the user has set the option "OutputSel" then create a
  // reduced vector that stores the desired values.
  if (vsel.is_empty ()) {
    for (octave_idx_type vcnt = 0; vcnt < vresult.length (); vcnt++)
      vreduced(vcnt) = vresult(vcnt);
  }
  else {
    vreduced.resize (vsel.length ());
    ColumnVector vselect (vsel.vector_value ());
    for (octave_idx_type vcnt = 0; vcnt < vsel.length (); vcnt++)
      vreduced(vcnt) = vresult(static_cast<int> (vselect(vcnt)-1));
  }

  // Here we are setting up the list of input arguments before
  // evaluating the output function
  octave_value_list varin;
  varin(0) = vt;
  varin(1) = octave_value (vreduced);
  if (vdeci == 0)      varin(2) = "init";
  else if (vdeci == 1) varin(2) = "";
  else if (vdeci == 2) varin(2) = "done";

  for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
    varin(vcnt+3) = vextarg(vcnt);

  // Evaluate the output function and return the value of the output
  // function to the caller function
  if ((vdeci == 0) || (vdeci == 2)) {
    if (vplt.is_function_handle () || vplt.is_inline_function ())
      feval (vplt.function_value (), varin, 0);
    else if (vplt.is_string ()) // String may be used from the caller
      feval (vplt.string_value (), varin, 0);
    return (true);
  }

  else if (vdeci == 1) {
    octave_value_list vout;
    if (vplt.is_function_handle () || vplt.is_inline_function ())
      vout = feval (vplt.function_value (), varin, 1);
    else if (vplt.is_string ()) // String may be used if set automatically
      vout = feval (vplt.string_value (), varin, 1);
    return (vout(0).bool_value ());
  }

  return (true);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_value_list odepkg_auxiliary_evaljacide (octave_value vjac, octave_value vt, octave_value vy, octave_value vdy, octave_value_list vextarg)
 *
 * Return two matrices that come from the evaluation of the @code{Jacobian} function. The input arguments of this function are
 * @itemize @minus
 * @item @var{vjac}: The @code{Jacobian} function that is evaluated
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of IDEs at time @var{vt}
 * @item @var{vdy}: The derivatives of the set of IDEs at time @var{vt}
 * @item @var{vextarg}: Extra arguments that are feed through to the @code{Jacobian} function
 * @end itemize
 *
 * @indent @b{Note:} This function can only be used for IDE problem solvers.
 * @end deftypefn
 */
octave_value_list odepkg_auxiliary_evaljacide
  (octave_value vjac, octave_value vt, octave_value vy, 
   octave_value vdy, octave_value_list vextarg) {

  octave_value_list varout;

  // If vjac is a cell array then we expect that two matrices are
  // returned to the caller function, we can't check for this before
  if (vjac.is_cell () && (vjac.length () == 2)) {
    varout(0) = vjac.cell_value ()(0);
    varout(1) = vjac.cell_value ()(1);
    if (!varout(0).is_matrix_type () || !varout(1).is_matrix_type ()) {
      error_with_id ("OdePkg:InvalidArgument",
        "If Jacobian is a 2x1 cell array then both cells must be matrices");
    }
  }

  // If vjac is a function_hanlde or an inline_function then evaluate
  // the function and return the results
  else if (vjac.is_function_handle () || vjac.is_inline_function ()) {
    octave_value_list varin;
    varin(0) = vt;  // varin(0).print_with_name (octave_stdout, "vt", true);
    varin(1) = vy;  // varin(1).print_with_name (octave_stdout, "vy", true);
    varin(2) = vdy; // varin(2).print_with_name (octave_stdout, "vdy", true);
    // Fill up RHS arguments with extra arguments that are given
    for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
      varin(vcnt+3) = vextarg(vcnt);
    // Evaluate the Jacobian function and return results
    varout = feval (vjac.function_value (), varin, 1);
  }

  // In principle this is not possible because odepkg_structure_check
  // should find all occurences that are not valid
  else {
    error_with_id ("OdePkg:InvalidArgument",
      "Jacobian must be a function handle or a cell array with length two");
  }

  return (varout);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_value odepkg_auxiliary_evaljacode (octave_value vjac, octave_value vt, octave_value vy, octave_value_list vextarg)
 *
 * Return a matrix that comes from the evaluation of the @code{Jacobian} function. The input arguments of this function are
 * @itemize @minus
 * @item @var{vjac}: The @code{Jacobian} function that is evaluated
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of ODEs at time @var{vt}
 * @item @var{vextarg}: Extra arguments that are feed through to the @code{Jacobian} function
 * @end itemize
 *
 * @indent @b{Note:} This function can only be used for ODE and DAE problem solvers.
 * @end deftypefn
 */
octave_value odepkg_auxiliary_evaljacode (octave_value vjac,
  octave_value vt, octave_value vy, octave_value_list vextarg) {

  octave_value vret;

  // If vjac is a matrix then return its value to the caller function
  if (vjac.is_matrix_type ()) {
    vret = vjac;
  }

  // If vjac is a function_hanlde or an inline_function then evaluate
  // the function and return the results
  else if (vjac.is_function_handle () || vjac.is_inline_function ()) {
    octave_value_list varin;
    octave_value_list varout;
    varin(0) = vt;
    varin(1) = vy;
    // Fill up RHS arguments with extra arguments that are given
    for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
      varin(vcnt+2) = vextarg(vcnt);
    // Evaluate the Jacobian function and return results
    varout = feval (vjac.function_value (), varin, 1);
    vret = varout(0);
  }

  // In principle this is not possible because odepkg_structure_check
  // should find all occurences that are not valid
  else {
    error_with_id ("OdePkg:InvalidArgument",
      "Jacobian must be a function handle or a matrix");
  }
  // vret.print (octave_stdout, true);
  return (vret);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_value odepkg_auxiliary_evalmassode (octave_value vmass, octave_value vstate, octave_value vt, octave_value vy, octave_value_list vextarg)
 *
 * Return a matrix that comes from the evaluation of the @code{Mass} function. The input arguments of this function are
 * @itemize @minus
 * @item @var{vmass}: The @code{Mass} function that is evaluated
 * @item @var{vstate}: The state variable that either is the string @code{'none'}, @code{'weak'} or @code{'strong'}
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of ODEs at time @var{vt}
 * @item @var{vextarg}: Extra arguments that are feed through to the @code{Mass} function
 * @end itemize
 *
 * @indent @b{Note:} This function can only be used for ODE and DAE problem solvers.
 * @end deftypefn
 */
octave_value odepkg_auxiliary_evalmassode
  (octave_value vmass, octave_value vstate, octave_value vt,
   octave_value vy, octave_value_list vextarg) {

  octave_value vret;

  // If vmass is a matrix then return its value to the caller function
  if (vmass.is_matrix_type ())
    return (vmass);

  // If vmass is a function_hanlde or an inline_function then evaluate
  // the function and return the results
  else if (vmass.is_function_handle () || vmass.is_inline_function ()) {
    octave_value_list varin;
    octave_value_list varout;
    if (vstate.is_empty () || !vstate.is_string ())
      error_with_id ("OdePkg:InvalidOption",
        "If \"Mass\" value is a handle then \"MStateDependence\" must be given");
 
    else if (vstate.string_value ().compare ("none") == 0) {
      varin(0) = vt;
      for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
	varin(vcnt+1) = vextarg(vcnt);
    }

    else { // If "MStateDependence" is "weak" or "strong"
      varin(0) = vt; varin(1) = vy;
      // Fill up RHS arguments with extra arguments that are given
      for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
	varin(vcnt+2) = vextarg(vcnt);
    }

    // Evaluate the Mass function and return results
    varout = feval (vmass.function_value (), varin, 1);
    vret = varout(0);
  }

  // In principle the execution of the next line is not possible
  // because odepkg_structure_check should find all occurences that
  // are not valid
  else
    error_with_id ("OdePkg:InvalidArgument",
      "Mass must be a function handle or a matrix");

  return (vret);
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_value odepkg_auxiliary_makestats (octave_value_list vstats, octave_idx_type vprnt)
 *
 * Return an @var{octave_value} that contains fields about performance informations of a finished solving process. The input arguments of this function are
 * @itemize @minus
 * @item @var{vstats}: The statistics informations list that has to be handled. The values that are treated have to be ordered as follows
 * @enumerate
 * @item Number of computed steps
 * @item Number of rejected steps
 * @item Number of function evaluations
 * @item Number of Jacobian evaluations
 * @item Number of LU decompositions
 * @item Number of forward backward substitutions
 * @end enumerate
 * @item @var{vprnt}: If @code{true} then the statistics information also is displayed on screen
 * @end itemize
 * @end deftypefn
 */
octave_value odepkg_auxiliary_makestats
  (octave_value_list vstats, octave_idx_type vprnt) {

  Octave_map vretval;

  if (vstats.length () < 5)
    error_with_id ("OdePkg:InvalidArgument",
      "C++ function odepkg_auxiliary_makestats error");
  else {
    vretval.assign ("nsteps",   vstats(0));
    vretval.assign ("nfailed",  vstats(1));
    vretval.assign ("nfevals",  vstats(2));
    vretval.assign ("npds",     vstats(3));
    vretval.assign ("ndecomps", vstats(4));
    vretval.assign ("nlinsols", vstats(5));
  }

  if (vprnt == true) {
    octave_stdout << "Number of function calls:    " << vstats(0).int_value () << std::endl;
    octave_stdout << "Number of failed attempts:   " << vstats(1).int_value () << std::endl;
    octave_stdout << "Number of function evals:    " << vstats(2).int_value () << std::endl;
    octave_stdout << "Number of Jacobian evals:    " << vstats(3).int_value () << std::endl;
    octave_stdout << "Number of LU decompositions: " << vstats(4).int_value () << std::endl;
    octave_stdout << "Number of fwd/backwd subst:  " << vstats(5).int_value () << std::endl;
  }

  return (octave_value (vretval));
}

/* -*- texinfo -*-
 * @deftypefn {Function} octave_idx_type odepkg_auxiliary_solstore (octave_value &vt, octave_value &vy, octave_value vsel, octave_idx_type vdeci)
 *
 * If @var{vdeci} is @code{0} (@var{vt} is a pointer to the initial time step and @var{vy} is a pointer to the initial values vector) then this function is initialized. Otherwise if @var{vdeci} is @code{1} (@var{vt} is a pointer to another time step and @var{vy} is a pointer to the solution vector) the values of @var{vt} and @var{vy} are added to the internal variable, if @var{vdeci} is @code{2} then the internal vectors are returned. The input arguments of this function are
 * @itemize @minus
 * @item @var{vt}: The time stamp at which the events function is called
 * @item @var{vy}: The solutions of the set of ODEs at time @var{vt}
 * @item @var{vsel}: The selection vector for which values should be treated
 * @item @var{vdeci}: A decision flag that describes what evaluation should be done
 * @end itemize
 * @end deftypefn
 */
octave_idx_type odepkg_auxiliary_solstore 
  (octave_value &vt, octave_value &vy, octave_value vsel, octave_idx_type vdeci) {

  // If the option "OutputSel" has been set then prepare a vector with
  // a reduced number of elements. The indexes of the values are given
  // in vsel if vdeci == (0 || 1).
  RowVector vreduced;
  if (vdeci != 2) {
    if (!vsel.is_empty ()) {
      vreduced.resize (vsel.length ());
      RowVector vselect (vsel.vector_value ());
      RowVector vresult (vy.vector_value ());
      for (octave_idx_type vcnt = 0; vcnt < vsel.length (); vcnt++)
        vreduced(vcnt) = vresult(static_cast<int> (vselect(vcnt)-1));
    } 
    else {
      vreduced.resize (vy.length ());
      vreduced = RowVector (vy.vector_value ());
    }
  }

  // Now have a look at the vdeci variable and do 0..initialization,
  // 1..store other elements, 2..return stored elements to the caller
  // function, 3..delete the last line of the matrices
  static ColumnVector vtstore(1);
  static Matrix vystore;

  switch (vdeci) {
    case 0:
      // Keep the resize command here because otherwise we stack the
      // new values of t even if we have already started a new call to
      // the solver
      vtstore.resize(1); vtstore(0) = vt.double_value ();
      vystore = Matrix (vreduced);
      break;

    case 1:
      vtstore = vtstore.stack (vt.column_vector_value ());
      vystore = vystore.stack (Matrix (vreduced));
      break;

    case 2:
      vt = octave_value (vtstore);
      vy = octave_value (vystore);
      break;

    case 3:
      vtstore = vtstore.extract (0, vtstore.length () - 2);
      vystore = vystore.extract (0, 0, vtstore.rows () - 2, vtstore.cols () - 1);

    default: 
      // This can be used for displaying all values at any time,
      // eg. if the code should be debuged or something like this
      vt = octave_value (vtstore);
      vy = octave_value (vystore);
      vt.print_with_name (octave_stdout, "vt", true);
      vy.print_with_name (octave_stdout, "vy", true);
      break;
  }

  return (true);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
