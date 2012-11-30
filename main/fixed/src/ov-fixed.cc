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
along with this program; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <iostream>

#include <octave/config.h>
#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/symtab.h>
#include <octave/parse.h>
#include <octave/utils.h>
#include <octave/unwind-prot.h>
#include <octave/variables.h>
#include <octave/data-conv.h>
#include <octave/byte-swap.h>

#include "fixed-def.h"
#include "ov-base-fixed.h"
#include "ov-base-fixed.cc"
#include "int/fixed.h"
#include "ov-fixed.h"
#include "fixed-conv.h"

template class octave_base_fixed<FixedPoint>;

DEFINE_OCTAVE_ALLOCATOR(octave_fixed);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_fixed, "fixed scalar", 
				    "FixedPoint");

NDArray
octave_fixed::array_value (bool) const
{
  return NDArray (dim_vector (1, 1), scalar.fixedpoint ());
}

ComplexNDArray
octave_fixed::complex_array_value (bool) const
{
  return ComplexNDArray (dim_vector (1, 1), Complex (scalar.fixedpoint ()));
}

octave_value 
octave_fixed::resize (const dim_vector& dv, bool) const
{ 
  if (dv.length() > 2)
    {
      error ("Can not resize fixed point to NDArray");
      return octave_value ();
    }
  FixedMatrix retval (dv(0),dv(1)); 
  if (dv.numel()) 
    retval(0) = scalar; 
  return new octave_fixed_matrix (retval); 
}

octave_value
octave_fixed::subsasgn (const std::string& type,
				  const std::list<octave_value_list>& idx,
				  const octave_value& rhs)
{
  octave_value retval;

  switch (type[0])
    {
    case '(':
      {
	if (type.length () == 1)
	  retval = numeric_assign (type, idx, rhs);
	else if ((type.length () == 2) && rhs.is_scalar_type () && 
		 rhs.is_numeric_type ())
	  {
	    std::list<octave_value_list>::const_iterator p = idx.begin ();
	    octave_value_list key_idx = *++p;

	    assert (key_idx.length () == 1);

	    std::string key = key_idx(0).string_value ();

	    if (key == __FIXED_SIGN_STR)
	      error("can not directly change the sign in a fixed structure");
	    else if (key == __FIXED_VALUE_STR) 
	      error("can not directly change the value of a fixed structure");
	    else if (key == __FIXED_DECSIZE_STR)
	      retval = new octave_fixed (scalar.chdecsize(rhs.int_value()));
	    else if (key == __FIXED_INTSIZE_STR)
	      retval = new octave_fixed (scalar.chintsize(rhs.int_value()));
	     else
	      error ("fixed point structure has no member `%s'", 
		     key.c_str ());    
	  }
	else 
	  {
	    std::string nm = type_name ();
	    error ("in indexed assignment of %s, illegal assignment", 
		   nm.c_str ());
	  }
      }
      break;

    case '.':
      {
	octave_value_list key_idx = idx.front ();

	assert (key_idx.length () == 1);

	std::string key = key_idx(0).string_value ();

	if (key == __FIXED_SIGN_STR)
	  error("can not directly change the sign in a fixed structure");
	else if (key == __FIXED_VALUE_STR) 
	  error("can not directly change the value of a fixed structure");
	else if (key == __FIXED_DECSIZE_STR)
	  retval = new octave_fixed (scalar.chdecsize(rhs.int_value()));
	else if (key == __FIXED_INTSIZE_STR)
	  retval = new octave_fixed (scalar.chintsize(rhs.int_value()));
	else
	  error ("fixed point structure has no member `%s'", key.c_str ());    
      }
      break;

    case '{':
      {
	std::string nm = type_name ();
	error ("%s cannot be indexed with %c", nm.c_str (), type[0]);
      }
      break;

    default:
      panic_impossible ();
    }

  return retval;
}

octave_value
octave_fixed::do_index_op (const octave_value_list& idx, bool resize_ok)
{
  // XXX FIXME XXX -- this doesn't solve the problem of
  //
  //   a = 1; a([1,1], [1,1], [1,1])
  //
  // and similar constructions.  Hmm...

  // XXX FIXME XXX -- using this constructor avoids narrowing the
  // 1x1 matrix back to a scalar value.  Need a better solution
  // to this problem.

  octave_value tmp (new octave_fixed_matrix (fixed_matrix_value ()));

  return tmp.do_index_op (idx, resize_ok);
}

octave_value
octave_fixed::convert_to_str (bool) const
{
  octave_value retval;

  int ival = NINT (scalar.fixedpoint());

  if (ival < 0 || ival > UCHAR_MAX)
    {
      // XXX FIXME XXX -- is there something better we could do?

      ival = 0;

      ::warning ("range error for conversion to character value");
    }

  retval = octave_value (std::string (1, static_cast<char> (ival)));
  
  return retval;
}

static void
restore_precision (int *p)
{
  bind_internal_variable ("output_precision", *p);
}

void
octave_fixed::print_raw (std::ostream& os, bool pr_as_read_syntax) const
{
  double min_num = ::abs(scalar).fixedpoint();
  int new_prec = scalar.getdecsize() +
    (min_num >= 1. ? (int)::log10(min_num) + 1 : 0);

  octave_value_list tmp = feval ("output_precision");
  int prec = tmp(0).int_value ();

  unwind_protect frame;

  frame.add_fcn (restore_precision, &prec);

  bind_internal_variable ("output_precision", new_prec);

  indent (os);
  octave_print_internal (os, scalar_value(), pr_as_read_syntax);
}

bool 
octave_fixed::save_ascii (std::ostream& os)
{
  os << scalar.getintsize () << " " 
     << scalar.getdecsize () << " " 
     << scalar.getnumber () << "\n";

  return true;
}

bool 
octave_fixed::load_ascii (std::istream& is)
{
  unsigned int intsize, decsize, number;

  is >> intsize >> decsize >> number;
  scalar = FixedPoint (intsize, decsize, number);

  return is;
}

bool 
octave_fixed::save_binary (std::ostream& os, bool& save_as_floats)
{
  unsigned int itmp;
  char tmp = (char) sizeof (unsigned int);
  os.write (X_CAST (char *, &tmp), 1);

  // intsize and decsize are integers in the range [0:32], so store as char
  tmp = scalar.getintsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  tmp = scalar.getdecsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  itmp = scalar.getnumber ();
  LS_DO_WRITE (unsigned int, &itmp, sizeof (unsigned int), 1, os);

  return true;
}

bool 
octave_fixed::load_binary (std::istream& is, bool swap,
				 oct_mach_info::float_format fmt)
{
  char size;
  unsigned int intsize, decsize, number;

  if (! is.read (X_CAST (char *, &size), 1))
    return false;

  LS_DO_READ_1(&intsize, 1, is);
  LS_DO_READ_1(&decsize, 1, is);

  if (size == 4)
    LS_DO_READ(unsigned int, swap, &number, 4, 1, is);
  else if (size == 8)
    LS_DO_READ(unsigned int, swap, &number, 8, 1, is);
  else
    return false;

  if (error_state || ! is)
    return false;
  
  scalar = FixedPoint (intsize, decsize, number);
  return true;
}

#if defined (HAVE_HDF5)
bool
octave_fixed::save_hdf5 (hid_t loc_id, const char *name, bool save_as_floats)
{
  hid_t group_hid = -1;
#if HAVE_HDF5_18
  group_hid = H5Gcreate (loc_id, name, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
#else
  group_hid = H5Gcreate (loc_id, name, 0);
#endif
  if (group_hid < 0 ) return false;

  hsize_t dims[3];
  hid_t space_hid = -1, data_hid = -1;
  bool retval = true;
  char tmp;
  unsigned int num;

  space_hid = H5Screate_simple (0, dims, (hsize_t*) 0);
  if (space_hid < 0) 
    {
      H5Gclose (group_hid);
      return false;
    }
#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "int", H5T_NATIVE_UCHAR, space_hid,
                        H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "int", H5T_NATIVE_UCHAR, space_hid,
                        H5P_DEFAULT);
#endif
  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  tmp = scalar.getintsize ();
  retval = H5Dwrite (data_hid, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) &tmp) >= 0;
  H5Dclose (data_hid);
  if (!retval)
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }    

#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "dec", H5T_NATIVE_UCHAR, space_hid,
                        H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "dec", H5T_NATIVE_UCHAR, space_hid,
                        H5P_DEFAULT);
#endif

  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  tmp = scalar.getdecsize ();
  retval = H5Dwrite (data_hid, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) &tmp) >= 0;
  H5Dclose (data_hid);
  if (!retval)
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }    

#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "num", H5T_NATIVE_UINT, space_hid, 
                        H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "num", H5T_NATIVE_UINT, space_hid, 
                        H5P_DEFAULT);
#endif
  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  num = scalar.getnumber ();
  retval = H5Dwrite (data_hid, H5T_NATIVE_UINT, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) &num) >= 0;
  H5Dclose (data_hid);
  H5Sclose (space_hid);
  H5Gclose (group_hid);
  return retval;
}

bool
octave_fixed::load_hdf5 (hid_t loc_id, const char *name,
			  bool have_h5giterate_bug)
{
  char intsize, decsize;
  unsigned int number;
  hid_t group_hid, data_hid, space_id;
  hsize_t rank;

#if HAVE_HDF5_18
  group_hid = H5Gopen (loc_id, name, H5P_DEFAULT);
#else
  group_hid = H5Gopen (loc_id, name);
#endif

  if (group_hid < 0 ) return false;

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "int", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "nr");
#endif

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &intsize) < 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }


  H5Dclose (data_hid);

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "dec", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "dec");
#endif

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, H5T_NATIVE_UCHAR, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &decsize) < 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Dclose (data_hid);

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "num", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "num");
#endif

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, H5T_NATIVE_UINT, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &number) < 0)
    { 
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Dclose (data_hid);
  H5Gclose (group_hid);

  scalar = FixedPoint (intsize, decsize, number);

  return true;
}
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

