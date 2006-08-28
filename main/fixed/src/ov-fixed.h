/*

Copyright (C) 2003 Motorola Inc
Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_fixed_h)
#define octave_fixed_h 1

#include <cstdlib>

#include <iostream>
#include <string>

#include <octave/config.h>

#include <octave/mx-base.h>
#include <octave/oct-alloc.h>
#include <octave/str-vec.h>

#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/ov-base.h>
#include <octave/ov-base-scalar.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov-scalar.h>
#include <octave/ops.h>
#include <octave/ov-re-mat.h>

#include "ov-base-fixed.h"
#include "int/fixed.h"
#include "fixedMatrix.h"
#include "fixedComplex.h"
#include "fixedCMatrix.h"

class Octave_map;
class octave_value_list;

class tree_walker;

// Fixed point values.

class
octave_fixed : public octave_base_fixed<FixedPoint>
{
public:
  
  octave_fixed (void)
    : octave_base_fixed<FixedPoint> (FixedPoint()) { }

  octave_fixed (const octave_fixed& f)
    : octave_base_fixed<FixedPoint> (f) {}
  
  octave_fixed (const FixedPoint& f)
    : octave_base_fixed<FixedPoint> (f) { }

  octave_fixed (const unsigned int& is, const unsigned int& ds,
		const FixedPoint& f)
    : octave_base_fixed<FixedPoint> (is, ds, f) { }

  octave_fixed (const unsigned int& is, const unsigned int& ds,
		const double& d)
    : octave_base_fixed<FixedPoint> (is, ds, FixedPoint(is,ds,d)) { }

  ~octave_fixed (void) { }
      
  octave_value subsasgn (const std::string& type,
			 const std::list<octave_value_list>& idx,
			 const octave_value& rhs);

  octave_value_list dotref (const octave_value_list& idx);

  octave_value all (int = 0) const { return (scalar != FixedPoint()); }

  octave_value any (int = 0) const { return (scalar != FixedPoint()); }

  bool is_real_scalar (void) const { return true; }

  bool is_real_type (void) const { return true; }

  OV_REP_TYPE *clone (void) const { return new octave_fixed (*this); }
  OV_REP_TYPE *empty_clone (void) const { return new octave_fixed (); }

  octave_value do_index_op (const octave_value_list& idx, 
			    bool resize_ok = false);
  idx_vector index_vector (void) const 
    { return idx_vector (::fixedpoint(scalar)); }

  FixedPoint fixed_value (void) const { return scalar; }
  FixedMatrix fixed_matrix_value (void) const 
    { return FixedMatrix (1, 1, scalar); }

  FixedPointComplex fixed_complex_value (void) const
    { return FixedPointComplex(scalar); }
  FixedComplexMatrix fixed_complex_matrix_value (void) const
    { return FixedComplexMatrix(1,1,scalar); }

  NDArray array_value (bool = false) const;

  ComplexNDArray complex_array_value (bool = false) const;

  double scalar_value (bool = false) const { return ::fixedpoint(scalar); }
  double double_value (bool = false) const { return ::fixedpoint(scalar); } 
  Matrix matrix_value (bool = false) const 
    { return Matrix(1, 1, ::fixedpoint(scalar)); }

  Complex complex_value (bool = false) const { return ::fixedpoint(scalar); }
  ComplexMatrix complex_matrix_value (bool = false) const 
    { return ComplexMatrix (1, 1, Complex (::fixedpoint(scalar))); }

  octave_value resize (const dim_vector& dv, bool) const;

  octave_value convert_to_str (bool pad = false) const;

  void increment (void) { ++scalar; }

  void decrement (void) { --scalar; }

  void print_raw (std::ostream& os, bool pr_as_read_syntax = false) const;

  bool save_ascii (std::ostream& os, bool& infnan_warned,
		 bool strip_nan_and_inf);

  bool load_ascii (std::istream& is);

  bool save_binary (std::ostream& os, bool& save_as_floats);
  
  bool load_binary (std::istream& is, bool swap, 
  		    oct_mach_info::float_format fmt);

#if defined (HAVE_HDF5)
  bool save_hdf5 (hid_t loc_id, const char *name, bool save_as_floats);

  bool load_hdf5 (hid_t loc_id, const char *name, bool have_h5giterate_bug);
#endif

private:

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

  DECLARE_OCTAVE_ALLOCATOR
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
