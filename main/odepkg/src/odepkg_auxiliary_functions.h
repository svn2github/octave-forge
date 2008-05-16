/*
Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
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

#if !defined (odepkg_auxiliary_functions_h)
#define odepkg_auxiliary_functions_h 1

octave_value odepkg_auxiliary_getmapvalue 
  (std::string vnam, Octave_map vmap);

octave_idx_type odepkg_auxiliary_isvector 
  (octave_value vval);

octave_value_list odepkg_auxiliary_evaleventfun
  (octave_value veve, octave_value vt, octave_value vy, 
   octave_value_list vextarg, octave_idx_type vdeci);

octave_idx_type odepkg_auxiliary_evalplotfun
  (octave_value vplt, octave_value vsel, octave_value vt,
   octave_value vy, octave_value_list vextarg, octave_idx_type vdeci);

octave_value_list odepkg_auxiliary_evaljacide
  (octave_value vjac, octave_value vt, octave_value vy, 
   octave_value vyd, octave_value_list vextarg);

octave_value odepkg_auxiliary_evaljacode (octave_value vjac,
  octave_value vt, octave_value vy, octave_value_list vextarg);

octave_value odepkg_auxiliary_evalmassode
  (octave_value vmass, octave_value vstate, octave_value vt,
   octave_value vy, octave_value_list vextarg);

octave_value odepkg_auxiliary_makestats
  (octave_value_list vstats, octave_idx_type vprnt);

octave_idx_type odepkg_auxiliary_solstore
  (octave_value &vt, octave_value &vy, octave_value vsel, 
   octave_idx_type vdeci);

#endif /* odepkg_auxiliary_functions_h */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
