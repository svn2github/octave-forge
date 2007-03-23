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
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_fixed_complex_h)
#define octave_fixed_complex_h 1

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

#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/ov-base.h>
#include <octave/ov-base-scalar.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov-scalar.h>
#include <octave/ops.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-cx-mat.h>

#include "ov-base-fixed.h"
#include "fixedMatrix.h"
#include "int/fixed.h"
#include "fixedComplex.h"
#include "ov-fixed.h"

class Octave_map;
class octave_value_list;

class tree_walker;

// Fixed point values.

class
OCTAVE_FIXED_API
octave_fixed_complex : public octave_base_fixed<FixedPointComplex>
{
public:
  
  octave_fixed_complex (void)
    : octave_base_fixed<FixedPointComplex> (FixedPointComplex()) { }

  octave_fixed_complex (const octave_fixed_complex& f)
    : octave_base_fixed<FixedPointComplex> (f) {}
  
  octave_fixed_complex (const FixedPointComplex& f)
    : octave_base_fixed<FixedPointComplex> (f) { }

  octave_fixed_complex (const unsigned int& is, const unsigned int& ds,
			const FixedPointComplex& f)
    : octave_base_fixed<FixedPointComplex> (is, ds, f) { }

  octave_fixed_complex (const unsigned int& is, const unsigned int& ds,
			const double& d)
    : octave_base_fixed<FixedPointComplex> (is, ds, FixedPointComplex(is,ds,d)) { }

  octave_fixed_complex (const unsigned int& is, const unsigned int& ds,
			const Complex& d)
    : octave_base_fixed<FixedPointComplex> (is, ds, FixedPointComplex(is,ds,d)) { }

  ~octave_fixed_complex (void) { }
      
  octave_value subsasgn (const std::string& type,
			 const std::list<octave_value_list>& idx,
			 const octave_value& rhs);

  octave_value_list dotref (const octave_value_list& idx);

  octave_value all (int = 0) const { return (scalar != FixedPointComplex()); }

  octave_value any (int = 0) const { return (scalar != FixedPointComplex()); }

  bool is_complex_scalar (void) const { return true; }

  bool is_complex_matrix (void) const { return true; }
  
  bool is_complex_type (void) const { return true; }

  bool is_numeric_type (void) const { return true; }

  bool is_true (void) const { return (scalar != FixedPointComplex()); }

  OV_REP_TYPE *clone (void) const { return new octave_fixed_complex (*this); }
  OV_REP_TYPE *empty_clone (void) const 
                     { return new octave_fixed_complex (); }

  OV_REP_TYPE *try_narrowing_conversion (void);

  octave_value do_index_op (const octave_value_list& idx,
			    bool resize_ok = false);

  FixedPoint fixed_value (bool = false) const ;
  FixedPointComplex fixed_complex_value (bool = false) const { return scalar; }

  FixedMatrix fixed_matrix_value (bool = false) const ;
  FixedComplexMatrix fixed_complex_matrix_value (void) const 
    { return FixedComplexMatrix(1,1,scalar); }

  NDArray array_value (bool = false) const;

  ComplexNDArray complex_array_value (bool = false) const;

  double scalar_value (bool frc_str_conv = false) const
    { return double_value (frc_str_conv); }
  double double_value (bool frc_str_conv= false) const 
    { return ::fixedpoint(fixed_value(frc_str_conv)); } 
  Matrix matrix_value (bool frc_str_conv= false) const
    { return ::fixedpoint(fixed_matrix_value(frc_str_conv)); }

  Complex complex_value (bool = false) const { return ::fixedpoint(scalar); }
  ComplexMatrix complex_matrix_value (bool = false) const 
    { return ComplexMatrix (1, 1, ::fixedpoint(scalar)); }

  octave_value resize (const dim_vector& dv, bool) const;

  void increment (void) { scalar += FixedPoint(1,0,1,0); }

  void decrement (void) { scalar -= FixedPoint(1,0,1,0); }

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
