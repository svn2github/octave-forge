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

#if !defined (octave_fixed_matrix_h)
#define octave_fixed_matrix_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <cstdlib>

#include <iostream>
#include <string>

#include <octave/config.h>

#include <octave/lo-mappers.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/mx-base.h>
#include <octave/oct-alloc.h>
#include <octave/str-vec.h>

#include <octave/error.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>
#include <octave/CMatrix.h>

#include "ov-base-fixed-mat.h"
#include "fixedRowVector.h"
#include "fixedColVector.h"
#include "fixedMatrix.h"
#include "fixedCMatrix.h"

class Octave_map;
class octave_value_list;

class tree_walker;

// Real matrix values.

class
octave_fixed_matrix : public octave_base_fixed_matrix<FixedMatrix>
{
public:

  octave_fixed_matrix (void)
    : octave_base_fixed_matrix<FixedMatrix> (FixedMatrix()) { }

  octave_fixed_matrix (const FixedMatrix& m)
    : octave_base_fixed_matrix<FixedMatrix> (m) { }

  octave_fixed_matrix (const FixedRowVector& v)
    : octave_base_fixed_matrix<FixedMatrix> (FixedMatrix(v)) { }

  octave_fixed_matrix (const FixedColumnVector& v)
    : octave_base_fixed_matrix<FixedMatrix> (FixedMatrix(v)) { }

  octave_fixed_matrix (const FixedPoint& v)
    : octave_base_fixed_matrix<FixedMatrix> (FixedMatrix(1,1,v)) { }

  ~octave_fixed_matrix (void) { }

  octave_value *clone (void) const { return new octave_fixed_matrix (*this); }
  octave_value *empty_clone (void) const { return new octave_fixed_matrix (); }

  octave_value do_index_op (const octave_value_list& idx)
    { return do_index_op (idx, 0); }

  octave_value do_index_op (const octave_value_list& idx,
			    int resize_ok);

  octave_value subsasgn (const std::string& type,
			 const std::list<octave_value_list>& idx,
			 const octave_value& rhs);

  octave_value *try_narrowing_conversion (void);

  bool is_real_matrix (void) const { return true; }

  bool is_real_type (void) const { return true; }

  void print_raw (std::ostream& os, bool pr_as_read_syntax = false) const;

  double double_value (bool = false) const;

  double scalar_value (bool frc_str_conv = false) const
    { return double_value (frc_str_conv); }

  Matrix matrix_value (bool = false) const;

  FixedMatrix fixed_matrix_value (bool = false) const { return matrix; }

  FixedComplexMatrix fixed_complex_matrix_value (bool = false) const 
         { return FixedComplexMatrix(matrix); }

  Complex complex_value (bool = false) const;

  ComplexMatrix complex_matrix_value (bool = false) const
    { return ComplexMatrix (matrix_value()); }

#ifdef HAVE_ND_ARRAYS
  NDArray array_value (bool = false) const;

  ComplexNDArray complex_array_value (bool = false) const;
#endif

#if defined (HAVE_OCTAVE_CONCAT) || defined (HAVE_OLD_OCTAVE_CONCAT)
  octave_value resize (const dim_vector& dv) const;
#endif

  void increment (void) { matrix += FixedPoint(1,0,1,0); }

  void decrement (void) { matrix -= FixedPoint(1,0,1,0); }

  octave_value convert_to_str (bool pad = false) const;

#ifdef CLASS_HAS_LOAD_SAVE
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
#endif

private:
  FixedMatrix do_index_intern (const octave_value_list& idx, int resize_ok);

  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
