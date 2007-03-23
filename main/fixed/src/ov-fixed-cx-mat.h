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
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_fixed_complex_matrix_h)
#define octave_fixed_complex_matrix_h 1

#include <cstdlib>

#include <iostream>
#include <string>

#include <octave/mx-base.h>
#include <octave/oct-alloc.h>
#include <octave/str-vec.h>

#include <octave/error.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>

#include "ov-base-fixed-mat.h"
#include "fixedCRowVector.h"
#include "fixedCColVector.h"
#include "fixedCMatrix.h"

class Octave_map;
class octave_value_list;

class tree_walker;

// Complex matrix values.

class
OCTAVE_FIXED_API
octave_fixed_complex_matrix : 
  public octave_base_fixed_matrix<FixedComplexMatrix>
{
public:

  octave_fixed_complex_matrix (void)
    : octave_base_fixed_matrix<FixedComplexMatrix> (FixedComplexMatrix()) { }

  octave_fixed_complex_matrix (const FixedComplexMatrix& m)
    : octave_base_fixed_matrix<FixedComplexMatrix> (m) { }

  octave_fixed_complex_matrix (const FixedComplexRowVector& v)
    : octave_base_fixed_matrix<FixedComplexMatrix> (FixedComplexMatrix (v)) { }

  octave_fixed_complex_matrix (const FixedComplexColumnVector& v)
    : octave_base_fixed_matrix<FixedComplexMatrix> (FixedComplexMatrix (v)) { }

  octave_fixed_complex_matrix (const FixedPointComplex& v)
    : octave_base_fixed_matrix<FixedComplexMatrix> 
      (FixedComplexMatrix (1, 1, v)) { }

  octave_fixed_complex_matrix (const FixedMatrix& fr, const FixedMatrix& fi)
    : octave_base_fixed_matrix<FixedComplexMatrix> 
      (FixedComplexMatrix (fr, fi)) { }

  ~octave_fixed_complex_matrix (void) { }

  OV_REP_TYPE *clone (void) const { return new octave_fixed_complex_matrix (*this); }
  OV_REP_TYPE *empty_clone (void) const { return new octave_fixed_complex_matrix (); }

  octave_value do_index_op (const octave_value_list& idx)
    { return do_index_op (idx, 0); }

  octave_value do_index_op (const octave_value_list& idx,
			    bool resize_ok = false);

  octave_value subsasgn (const std::string& type,
			 const std::list<octave_value_list>& idx,
			 const octave_value& rhs);

  OV_REP_TYPE *try_narrowing_conversion (void);

  bool is_complex_matrix (void) const { return true; }

  bool is_complex_type (void) const { return true; }

  void print_raw (std::ostream& os, bool pr_as_read_syntax = false) const;

  double double_value (bool = false) const;

  double scalar_value (bool frc_str_conv = false) const
    { return double_value (frc_str_conv); }

  FixedPoint fixed_value (bool = false) const;

  Matrix matrix_value (bool = false) const;

  FixedMatrix fixed_matrix_value (bool = false) const;

  FixedComplexMatrix fixed_complex_matrix_value (bool = false) const 
    { return matrix; }

  Complex complex_value (bool = false) const;

  ComplexMatrix complex_matrix_value (bool = false) const
    { return matrix.fixedpoint(); }

  NDArray array_value (bool = false) const;

  ComplexNDArray complex_array_value (bool = false) const;

  octave_value resize (const dim_vector& dv, bool) const;

  void increment (void) { matrix += FixedPoint(1,0,1,0); }

  void decrement (void) { matrix -= FixedPoint(1,0,1,0); }

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
  FixedComplexMatrix do_index_intern (const octave_value_list& idx, 
				      bool resize_ok = false);

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
