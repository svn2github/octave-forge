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

#if !defined (odepkg_auxiliary_functions_h)
#define odepkg_auxiliary_functions_h 1

/**
 * odepkg_auxiliary_getmapvalue - Return a value of a map field
 * @vnam: The name of the field whose value is returned
 * @vmap: The map that has to be checked for the field
 *
 * Return an octave_value from the Octave_map @vmap from the field
 * that is given by the string @vnam.
 *
 * Return value: An octave_value.
 **/
octave_value odepkg_auxiliary_getmapvalue (std::string vnam, Octave_map vmap);

/**
 * odepkg_auxiliary_isvector - Return %true for vector
 * @vval: The input argument that has to be checked
 *
 * Return a boolean value that either is %true if the octave_value
 * @vval is a vector or %false if @vval is not a vector.
 *
 * Return value: On success the constant %true, otherwise %false.
 **/
octave_idx_type odepkg_auxiliary_isvector (octave_value vval);

octave_value_list odepkg_auxiliary_evaleventfun
  (octave_value veve, octave_value vt, octave_value vy, 
   octave_value_list vextarg, octave_idx_type vdeci);

/**
 * odepkg_auxiliary_evalplotfun - Evaluates the output function
 * @vplt: The function handle to the plot function
 * @vsel: The vector ....
 *
 * TODO
 *
 * Return value: %true if success and %false if error
 **/
octave_idx_type odepkg_auxiliary_evalplotfun
  (octave_value vplt, octave_value vsel, octave_value vt,
   octave_value vy, octave_value_list vextarg, octave_idx_type vdeci);

octave_value_list odepkg_auxiliary_evaljacide
  (octave_value vjac, octave_value vt, octave_value vy, 
   octave_value vyd, octave_value_list vextarg);

octave_value odepkg_auxiliary_makestats
  (octave_idx_type vsucc, octave_idx_type vfail, octave_idx_type vcall,
   octave_idx_type vpart, octave_idx_type vlude, octave_idx_type vlsol,
   octave_idx_type vprnt);

/**
 * odepkg_mebdfi_errfcn - 
 **/
octave_idx_type odepkg_auxiliary_mebdfanalysis (octave_idx_type verr);

/**
 * odepkg_auxiliary_solstore - Stores a time- and solution vector
 * @vt: A pointer to the time value mxArray
 * @vy: A pointer to the mxArray solution vector
 * @vsel: A vector of selection indices
 * @vdeci: The decision for what has to be done
 *
 * If @vdeci is 0 (@vt is a pointer to the initial time step and @vy
 * is a pointer to the initial values vector) then this function is
 * initialized. Otherwise if @vdeci is 1 (@vt is a pointer to another
 * time step and @vy is a pointer to the solution vector) the values
 * of @vt and @vy are added to the internal variable, if @vdeci is 2
 * then the internal vectors are returned.
 *
 * This function is used to suppress global variables for storing a
 * time and solution vector.
 *
 * Return value: On success the constant %true, otherwise %false.
 **/
octave_idx_type odepkg_auxiliary_solstore
  (octave_value &vt, octave_value &vy, octave_value vsel, octave_idx_type vdeci);

#endif /* odepkg_auxiliary_functions_h */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
