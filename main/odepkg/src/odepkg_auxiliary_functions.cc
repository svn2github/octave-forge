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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "oct.h"
#include "oct-map.h"
#include "parse.h"
#include "odepkg_auxiliary_functions.h"

octave_value odepkg_auxiliary_getmapvalue (std::string vnam, Octave_map vmap) {
  Octave_map::const_iterator viter;
  viter = vmap.seek (vnam);
  return (vmap.contents(viter)(0));
}

octave_idx_type odepkg_auxiliary_isvector (octave_value vval) {
  if (vval.is_numeric_type () && 
      vval.ndims () == 2 && // ported from the is_vector.m file
      (vval.rows () == 1 || vval.columns () == 1))
    return (true);
  else
    return (false);
}

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

octave_value_list odepkg_auxiliary_evaljacide
  (octave_value vjac, octave_value vt, octave_value vy, 
   octave_value vyd, octave_value_list vextarg) {

  octave_value_list varout;

  // Check if vjac either describes a function or if the Jacbian
  // information is a cell array (of two matrices)
  if (!vjac.is_function_handle () && !vjac.is_inline_function () &&
      !vjac.is_cell ()) {
    error_with_id ("OdePkg:InvalidArgument",
      "Jacobian value must be a function handle or a cell array");
  }

  // If vjac is a cell array then we expect that two matrices are
  // returned to the caller function
  else if (vjac.is_cell ()) {
    octave_stdout << "missing implementation in function odepkg_auxiliaryfun_evaljacide" << std::endl;
  }

  else if (vjac.is_function_handle () || vjac.is_inline_function ()) {
    octave_value_list varin;
    varin(0) = vt;
    varin(1) = vy;
    varin(2) = vyd;
    //    varin(0).print_with_name (octave_stdout, "vt", true);
    //    varin(1).print_with_name (octave_stdout, "vy", true);
    //    varin(2).print_with_name (octave_stdout, "vyd", true);
    for (octave_idx_type vcnt = 0; vcnt < vextarg.length (); vcnt++)
      varin(vcnt+3) = vextarg(vcnt);

    varout = feval (vjac.function_value (), varin, 1);
  }

  return (varout);
}

/**
 * odepkg_auxiliary_makestats - Return the Stats structure
 *
 **/
octave_value odepkg_auxiliary_makestats
  (octave_idx_type vsucc, octave_idx_type vfail, octave_idx_type vcall,
   octave_idx_type vpart, octave_idx_type vlude, octave_idx_type vlsol,
   octave_idx_type vprnt) {

  Octave_map vstats;

  vstats.assign ("success", octave_value (vsucc));
  vstats.assign ("failed", octave_value (vfail));
  vstats.assign ("fevals", octave_value (vcall));
  vstats.assign ("partial", octave_value (vpart));
  vstats.assign ("ludecom", octave_value (vlude));
  vstats.assign ("linsol", octave_value (vlsol));

  if (vprnt == true) {
    octave_stdout << "Number of function calls:    " << vsucc << std::endl;
    octave_stdout << "Number of failed attempts:   " << vfail << std::endl;
    octave_stdout << "Number of function evals:    " << vcall << std::endl;
    octave_stdout << "Number of Jacobian evals:    " << vpart << std::endl;
    octave_stdout << "Number of LU decompositions: " << vlude << std::endl;
    octave_stdout << "Number of backward solves:   " << vlsol << std::endl;
  }

  return (octave_value (vstats));
}

octave_idx_type odepkg_auxiliary_mebdfanalysis (octave_idx_type verr) {
  
  switch (verr)
    {
    case 0: break; // Everything is fine

    case -1:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to pass the error test (error occured in \"mebdfi\" core solver function)");
      break;

    case -2:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to pass a repeated error test (error occured in \"mebdfi\" core solver function)");
      break;

    case -3:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to achieve corrector convergence (error occured in \"mebdfi\" core solver function)");
      break;

    case -4:
      error_with_id ("OdePkg:InternalError",
	"Immediate halt because of illegal input arguments (error occured in \"mebdfi\" core solver function)");
      break;

    case -5:
      error_with_id ("OdePkg:InternalError",
	"Idid was -1 on input (error occured in \"mebdfi\" core solver function)");
      break;

    case -6:
      error_with_id ("OdePkg:InternalError",
	"Maximum number of allowed integration steps exceeded (error occured in \"mebdfi\" core solver function)");
      break;

    case -7:
      error_with_id ("OdePkg:InternalError",
	"Stepsize grew too small (error occured in \"mebdfi\" core solver function)");
      break;

    case -11:
      error_with_id ("OdePkg:InternalError",
	"Insufficient real workspace for integration (error occured in \"mebdfi\" core solver function)");
      break;

    case -12:
      error_with_id ("OdePkg:InternalError",
	"Insufficient integer workspace for integration (error occured in \"mebdfi\" core solver function)");
      break;

    case -40:
      error_with_id ("OdePkg:InternalError",
	"Error too small to be attained for the machine precision (error occured in \"mebdfi\" core solver function)");
      break;

    case -41:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument IDID (error occured in \"mebdfi\" core solver function)");
      break;

    case -42:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument ATOL (error occured in \"mebdfi\" core solver function)");
      break;

    case -43:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument RTOL (error occured in \"mebdfi\" core solver function)");
      break;

    case -44:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument N<0 (error occured in \"mebdfi\" core solver function)");
      break;

    case -45:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument (T0-TOUT)*H>0 (error occured in \"mebdfi\" core solver function)");
      break;

    case -46:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument MF!=21 && MF!=22 (error occured in \"mebdfi\" core solver function)");
      break;

    case -47:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument ITOL (error occured in \"mebdfi\" core solver function)");
      break;

    case -48:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument MAXDER (error occured in \"mebdfi\" core solver function)");
      break;

    case -49:
      error_with_id ("OdePkg:InternalError",
	"Illegal input argument INDEX VARIABLES (error occured in \"mebdfi\" core solver function)");
      break;

    default:
      error_with_id ("OdePkg:InternalError",
	"Integration was halted after failing to pass the error test (error occured in \"mebdfi\" core solver function with error number \"%d\")", verr);
      break;
    }

  return (true);
}

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
  switch (vdeci) {
    case 0:
      static ColumnVector vtstore(1);
      static Matrix vystore;

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
