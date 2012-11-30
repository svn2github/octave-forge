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
#include <octave/gripes.h>
#include <octave/symtab.h>
#include <octave/parse.h>
#include <octave/utils.h>
#include <octave/unwind-prot.h>
#include <octave/variables.h>
#include <octave/data-conv.h>
#include <octave/byte-swap.h>
#include <octave/ls-hdf5.h>

#include "fixed-def.h"
#include "ov-base-fixed.h"
#include "ov-base-fixed.cc"
#include "int/fixed.h"
#include "fixedComplex.h"
#include "ov-fixed-complex.h"
#include "fixed-conv.h"

template class octave_base_fixed<FixedPointComplex>;

DEFINE_OCTAVE_ALLOCATOR (octave_fixed_complex);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_fixed_complex, "fixed complex",
				     "FixedPoint");

NDArray
octave_fixed_complex::array_value (bool force_conversion) const
{
  NDArray retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex", "matrix");

  retval = NDArray (dim_vector (1, 1), std::real (scalar.fixedpoint ()));

  return retval;
}

ComplexNDArray
octave_fixed_complex::complex_array_value (bool) const
{
  return ComplexNDArray (dim_vector (1, 1), scalar.fixedpoint ());
}

octave_value 
octave_fixed_complex::resize (const dim_vector& dv, bool) const
{ 
  if (dv.length() > 2)
    {
      error ("Can not resize fixed point to NDArray");
      return octave_value ();
    }
  FixedComplexMatrix retval (dv(0),dv(1)); 
  if (dv.numel()) 
    retval(0) = scalar; 
  return new octave_fixed_complex_matrix (retval); 
}

octave_value
octave_fixed_complex::subsasgn (const std::string& type,
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
	      retval = new octave_fixed_complex (scalar.chdecsize(
				rhs.complex_value()));
	    else if (key == __FIXED_INTSIZE_STR)
	      retval = new octave_fixed_complex (scalar.chintsize(
				rhs.complex_value()));
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
	  retval = new octave_fixed_complex (scalar.chdecsize(
				rhs.complex_value()));
	else if (key == __FIXED_INTSIZE_STR)
	  retval = new octave_fixed_complex (scalar.chintsize(
				rhs.complex_value()));
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

OV_REP_TYPE *
octave_fixed_complex::try_narrowing_conversion (void)
{
  OV_REP_TYPE *retval = 0;

  if (::imag (scalar) == FixedPoint())
    retval = new octave_fixed (::real (scalar));

  return retval;
}

octave_value
octave_fixed_complex::do_index_op (const octave_value_list& idx, bool resize_ok)
{
  // XXX FIXME XXX -- this doesn't solve the problem of
  //
  //   a = 1; a([1,1], [1,1], [1,1])
  //
  // and similar constructions.  Hmm...

  // XXX FIXME XXX -- using this constructor avoids narrowing the
  // 1x1 matrix back to a scalar value.  Need a better solution
  // to this problem.

  octave_value tmp (new octave_fixed_complex_matrix (fixed_complex_matrix_value ()));

  return  tmp.do_index_op (idx, resize_ok);
}

FixedPoint
octave_fixed_complex::fixed_value (bool force_conversion) const
{
  FixedPoint retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex", "fixed scalar");

  retval = FixedPoint(::real (scalar));

  return retval;
}

FixedMatrix
octave_fixed_complex::fixed_matrix_value (bool force_conversion) const
{
  FixedMatrix retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex", "fixed matrix");
    
  retval = FixedMatrix(1,1,::real (scalar));

  return retval;
}

static void
restore_precision (int *p)
{
  bind_internal_variable ("output_precision", *p);
}

void
octave_fixed_complex::print_raw (std::ostream& os, 
				 bool pr_as_read_syntax) const
{
  double min_num = std::max(::abs(::real(scalar)).fixedpoint(),
			    ::abs(::imag(scalar)).fixedpoint());
  int new_prec = (int)std::max(std::real(scalar.getdecsize()),
			       std::imag(scalar.getdecsize()))
    + (min_num >= 1. ? (int)::log10(min_num) + 1 : 0);

  octave_value_list tmp = feval ("output_precision");
  int prec = tmp(0).int_value ();

  unwind_protect frame;

  frame.add_fcn (restore_precision, &prec);

  bind_internal_variable ("output_precision", new_prec);

  indent (os);
  octave_print_internal (os, complex_value(), pr_as_read_syntax);
}

bool 
octave_fixed_complex::save_ascii (std::ostream& os)
{
  os << scalar.real ().getintsize () << " " 
     << scalar.imag ().getintsize () << " " 
     << scalar.real ().getdecsize () << " " 
     << scalar.imag ().getdecsize () << " " 
     << scalar.real ().getnumber () << " "
     << scalar.imag ().getnumber () << "\n";

  return true;
}

bool 
octave_fixed_complex::load_ascii (std::istream& is)
{
  unsigned int iintsize, rintsize, idecsize, rdecsize, rnumber, inumber;

  is >> rintsize >> iintsize >> rdecsize >> idecsize>> rnumber >> inumber;
  scalar = FixedPointComplex (FixedPoint (rintsize, rdecsize, rnumber),
			      FixedPoint (iintsize, idecsize, inumber));

  return is;
}

bool 
octave_fixed_complex::save_binary (std::ostream& os, bool& save_as_floats)
{
  unsigned int itmp;
  char tmp = (char) sizeof (unsigned int);
  os.write (X_CAST (char *, &tmp), 1);

  FixedPoint rnumber = scalar.real (), inumber = scalar.imag ();

  // intsize and decsize are integers in the range [0:32], so store as char
  tmp = rnumber.getintsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  tmp = inumber.getintsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  tmp = rnumber.getdecsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  tmp = inumber.getdecsize ();
  LS_DO_WRITE (char, &tmp, 1, 1, os);
  itmp = rnumber.getnumber ();
  LS_DO_WRITE (unsigned int, &itmp, sizeof (unsigned int), 1, os);
  itmp = inumber.getnumber ();
  LS_DO_WRITE (unsigned int, &itmp, sizeof (unsigned int), 1, os);

  return true;
}

bool 
octave_fixed_complex::load_binary (std::istream& is, bool swap,
				 oct_mach_info::float_format fmt)
{
  char size;
  unsigned int iintsize, rintsize, idecsize, rdecsize, inumber, rnumber;

  if (! is.read (X_CAST (char *, &size), 1))
    return false;

  LS_DO_READ_1(&rintsize, 1, is);
  LS_DO_READ_1(&iintsize, 1, is);
  LS_DO_READ_1(&rdecsize, 1, is);
  LS_DO_READ_1(&idecsize, 1, is);

  if (size == 4)
    {
      LS_DO_READ(unsigned int, swap, &rnumber, 4, 1, is);
      LS_DO_READ(unsigned int, swap, &inumber, 4, 1, is);
    }
  else if (size == 8)
    {
      LS_DO_READ(unsigned int, swap, &rnumber, 8, 1, is);
      LS_DO_READ(unsigned int, swap, &inumber, 8, 1, is);
    }
  else
    return false;

   if (error_state || ! is)
    return false;
  
  scalar = FixedPointComplex (FixedPoint (rintsize, rdecsize, rnumber),
			      FixedPoint (iintsize, idecsize, inumber));
  return true;
}

#if defined (HAVE_HDF5)
bool
octave_fixed_complex::save_hdf5 (hid_t loc_id, const char *name, 
				 bool save_as_floats)
{
  hid_t group_hid = -1;

#if HAVE_HDF5_18
  group_hid = H5Gcreate (loc_id, name, 0, H5P_DEFAULT, H5P_DEFAULT);
#else
  group_hid = H5Gcreate (loc_id, name, 0);
#endif

  if (group_hid < 0 ) return false;

  hsize_t dims[3];
  hid_t space_hid = -1, data_hid = -1, type_hid = -1;
  bool retval = true;

  space_hid = H5Screate_simple (0, dims, (hsize_t*) 0);
  if (space_hid < 0) 
    {
      H5Gclose (group_hid);
      return false;
    }
  
  type_hid = hdf5_make_fixed_complex_type (H5T_NATIVE_UCHAR, 1);
  if (type_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }

#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "int", type_hid, space_hid, H5P_DEFAULT,
                        H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "int", type_hid, space_hid, H5P_DEFAULT);
#endif

  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Tclose (type_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  OCTAVE_LOCAL_BUFFER(char, tmp, 2);
  tmp[0] = scalar.real ().getintsize ();
  tmp[1] = scalar.imag ().getintsize ();

  retval = H5Dwrite (data_hid, type_hid, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) tmp) >= 0;
  H5Dclose (data_hid);
  if (!retval)
    {
      H5Sclose (space_hid);
      H5Tclose (type_hid);
      H5Gclose (group_hid);
      return false;
    }    

#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "dec", type_hid, space_hid, H5P_DEFAULT,
                        H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "dec", type_hid, space_hid, H5P_DEFAULT);
#endif

  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Tclose (type_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  tmp[0] = scalar.real ().getdecsize ();
  tmp[1] = scalar.imag ().getdecsize ();

  retval = H5Dwrite (data_hid, type_hid, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) tmp) >= 0;
  H5Dclose (data_hid);
  H5Tclose (type_hid);
  if (!retval)
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }    

  type_hid = hdf5_make_fixed_complex_type (H5T_NATIVE_UINT, 
					   sizeof (unsigned int));
  if (type_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Gclose (group_hid);
      return false;
    }

#if HAVE_HDF5_18
  data_hid = H5Dcreate (group_hid, "num", type_hid, space_hid, H5P_DEFAULT,
                        H5P_DEFAULT, H5P_DEFAULT);
#else
  data_hid = H5Dcreate (group_hid, "num", type_hid, space_hid, H5P_DEFAULT);
#endif

  if (data_hid < 0) 
    {
      H5Sclose (space_hid);
      H5Tclose (type_hid);
      H5Gclose (group_hid);
      return false;
    }
  
  OCTAVE_LOCAL_BUFFER(unsigned int, num, 2);
  num[0] = scalar.real ().getnumber ();
  num[1] = scalar.imag ().getnumber ();

  retval = H5Dwrite (data_hid, type_hid, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) num) >= 0;
  H5Dclose (data_hid);
  H5Sclose (space_hid);
  H5Tclose (type_hid);
  H5Gclose (group_hid);
  return retval;
}

bool
octave_fixed_complex::load_hdf5 (hid_t loc_id, const char *name,
			  bool have_h5giterate_bug)
{
  char intsize[2], decsize[2];
  unsigned int number[2];
  hid_t group_hid, data_hid, type_hid, space_id;
  hsize_t rank;

#if HAVE_HDF5_18
  group_hid = H5Gopen (loc_id, name, H5P_DEFAULT);
#else
  group_hid = H5Gopen (loc_id, name);
#endif

  if (group_hid < 0 ) return false;

  hid_t complex_type = hdf5_make_fixed_complex_type (H5T_NATIVE_UCHAR, 1);

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "int", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "int");
#endif

  type_hid = H5Dget_type (data_hid);

  if (! hdf5_types_compatible (type_hid, complex_type))
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &intsize) < 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Tclose(type_hid);
  H5Dclose (data_hid);

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "dec", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "dec");
#endif

  type_hid = H5Dget_type (data_hid);

  if (! hdf5_types_compatible (type_hid, complex_type))
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &decsize) < 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Tclose(complex_type);
  H5Tclose(type_hid);
  H5Dclose (data_hid);

  complex_type = hdf5_make_fixed_complex_type (H5T_NATIVE_UINT, 
					       sizeof(unsigned int));

#if HAVE_HDF5_18
  data_hid = H5Dopen (group_hid, "num", H5P_DEFAULT);
#else
  data_hid = H5Dopen (group_hid, "num");
#endif

  type_hid = H5Dget_type (data_hid);

  if (! hdf5_types_compatible (type_hid, complex_type))
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  space_id = H5Dget_space (data_hid);
  rank = H5Sget_simple_extent_ndims (space_id);

  if (rank != 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  if (H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, 
	       H5P_DEFAULT, (void *) &number) < 0)
    { 
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Tclose(complex_type);
  H5Tclose(type_hid);
  H5Dclose (data_hid);
  H5Gclose (group_hid);

  scalar = FixedPointComplex (FixedPoint (intsize[0], decsize[0], number[0]),
			      FixedPoint (intsize[1], decsize[1], number[1]));

  return true;
}
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
