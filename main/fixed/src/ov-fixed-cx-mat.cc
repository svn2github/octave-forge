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

#include <climits>
#include <iostream>
#include <iomanip>

#include <octave/config.h>
#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/lo-ieee.h>
#include <octave/gripes.h>
#include <octave/unwind-prot.h>
#include <octave/cmd-edit.h>
#include <octave/symtab.h>
#include <octave/parse.h>
#include <octave/utils.h>
#include <octave/unwind-prot.h>
#include <octave/variables.h>
#include <octave/data-conv.h>
#include <octave/byte-swap.h>
#include <octave/ls-oct-ascii.h>
#include <octave/ls-hdf5.h>
#include <octave/quit.h>

#include "fixed-def.h"
#include "ov-base-fixed-mat.h"
#include "ov-base-fixed-mat.cc"
#include "int/fixed.h"
#include "fixed-var.h"
#include "ov-fixed.h"
#include "ov-fixed-mat.h"
#include "ov-fixed-complex.h"
#include "ov-fixed-cx-mat.h"
#include "fixed-conv.h"

#if ! defined (UCHAR_MAX)
#define UCHAR_MAX 255
#endif

template class octave_base_fixed_matrix<FixedComplexMatrix>;

DEFINE_OCTAVE_ALLOCATOR (octave_fixed_complex_matrix);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_fixed_complex_matrix, 
				     "fixed complex matrix",
				     "FixedPoint");

NDArray
octave_fixed_complex_matrix::array_value (bool force_conversion) const
{
  NDArray retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex", "matrix");

  int nr = rows ();
  int nc = columns ();
  dim_vector dv(nr,nc);
  retval.resize (dv);

  for (int i=0; i<nr; i++)
    for (int j=0; j<nc; j++)
      retval(i + j*nr) = std::real (matrix(i,j).fixedpoint());

  return retval;
}

ComplexNDArray
octave_fixed_complex_matrix::complex_array_value (bool) const
{
  int nr = rows ();
  int nc = columns ();
  dim_vector dv(nr,nc);
  ComplexNDArray retval (dv);

  for (int i=0; i<nr; i++)
    for (int j=0; j<nc; j++)
      retval(i + j*nr) = matrix(i,j).fixedpoint();

  return retval;
}

octave_value
octave_fixed_complex_matrix::resize (const dim_vector& dv, bool) const
{
  if (dv.length() > 2)
    {
      error ("Can not resize fixed point to NDArray");
      return octave_value ();
    }
  FixedComplexMatrix retval (matrix); 
  retval.resize (dv); 
  return new octave_fixed_complex_matrix (retval);
}

FixedComplexMatrix
octave_fixed_complex_matrix::do_index_intern (const octave_value_list& idx,
				     bool resize_ok)
{
  FixedComplexMatrix retval;

  int len = idx.length ();

  switch (len)
    {
    case 2:
      {
	idx_vector i = idx (0).index_vector ();
	idx_vector j = idx (1).index_vector ();
	retval = FixedComplexMatrix( matrix.index (i, j, resize_ok));
      }
      break;

    case 1:
      {
	idx_vector i = idx (0).index_vector ();
	retval = FixedComplexMatrix( matrix.index (i, resize_ok));
      }
      break;

    default:
      {
	std::string n = type_name ();

	error ("invalid number of indices (%d) for %s value",
	       len, n.c_str ());
      }
      break;
    }

  return retval;
}

octave_value
octave_fixed_complex_matrix::do_index_op (const octave_value_list& idx,
				     bool resize_ok)
{
  octave_value retval;

  FixedComplexMatrix new_matrix = do_index_intern (idx, resize_ok);
  
  if (!error_state) {
    retval = new octave_fixed_complex_matrix ( new_matrix);
    retval.maybe_mutate();
  }

  return retval;
}

octave_value
octave_fixed_complex_matrix::subsasgn (const std::string& type,
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
	else if (type.length () == 2) 
	  {
	    std::list<octave_value_list>::const_iterator p = idx.begin ();
	    octave_value_list key_idx = *++p;

	    assert (key_idx.length () == 1);

	    std::string key = key_idx(0).string_value ();

	    if (key == __FIXED_SIGN_STR)
	      error("can not directly change the sign in a fixed structure");
	    else if (key == __FIXED_VALUE_STR) 
	      error("can not directly change the value of a fixed structure");
	    else if (key == __FIXED_DECSIZE_STR) {
	      if (rhs.is_matrix_type()) {
		FixedComplexMatrix old_matrix = 
		  do_index_intern(idx.front());
		octave_value new_matrix = new octave_fixed_complex_matrix(
		    old_matrix.chdecsize(rhs.complex_matrix_value()));
		retval = numeric_assign (type, idx, new_matrix);
	      } else {
		FixedComplexMatrix old_matrix = 
		  do_index_intern(idx.front());
		octave_value new_matrix = new octave_fixed_complex_matrix(
		    old_matrix.chdecsize(rhs.complex_value()));
		retval = numeric_assign (type, idx, new_matrix);
	      }
	    } else if (key == __FIXED_INTSIZE_STR) {
	      if (rhs.is_matrix_type()) {
		FixedComplexMatrix old_matrix = 
		  do_index_intern(idx.front());
		octave_value new_matrix = new octave_fixed_complex_matrix(
		    old_matrix.chintsize(rhs.complex_matrix_value()));
		retval = numeric_assign (type, idx, new_matrix);
	      } else {
		FixedComplexMatrix old_matrix = 
		  do_index_intern(idx.front());
		octave_value new_matrix = new octave_fixed_complex_matrix(
		    old_matrix.chintsize(rhs.complex_value()));
		retval = numeric_assign (type, idx, new_matrix);
	      }
	    } else
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
	else if (key == __FIXED_DECSIZE_STR) {
	  if (rhs.is_matrix_type())
	    retval = new octave_fixed_complex_matrix (matrix.chdecsize(
				rhs.complex_matrix_value()));
	  else
	    retval = new octave_fixed_complex_matrix (matrix.chdecsize(
				rhs.complex_value()));
	} else if (key == __FIXED_INTSIZE_STR) {
	  if (rhs.is_matrix_type())
	    retval = new octave_fixed_complex_matrix (matrix.chintsize(
				rhs.complex_matrix_value()));
	  else
	    retval = new octave_fixed_complex_matrix (matrix.chintsize(
				rhs.complex_value()));
	} else
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
octave_fixed_complex_matrix::try_narrowing_conversion (void)
{
  OV_REP_TYPE *retval = 0;

  int nr = matrix.rows ();
  int nc = matrix.cols ();

  // Why doesn't this work!!! Got to get it to work !!!
  if (nr == 1 && nc == 1)
    {
      FixedPointComplex c = matrix (0, 0);

      if (imag (c) == 0)
	retval = new octave_fixed (real (c));
      else
	retval = new octave_fixed_complex (c);
    }
  else if (nr == 0 || nc == 0)
    retval = new octave_fixed_matrix (FixedMatrix (nr, nc));
  else if (matrix.all_elements_are_real ())
    retval = new octave_fixed_matrix (::real (matrix));

  return retval;
}

double
octave_fixed_complex_matrix::double_value (bool force_conversion) const
{
  double retval = lo_ieee_nan_value ();

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex matrix", "real scalar");

  if (rows () > 0 && columns () > 0)
    {
      gripe_implicit_conversion ("Octave:array-as-scalar",
				 "real matrix", "real scalar");
	  
      retval = std::real (matrix (0, 0) .fixedpoint());
    }
  else
    gripe_invalid_conversion ("fixed complex matrix", "real scalar");

  return retval;
}

FixedPoint
octave_fixed_complex_matrix::fixed_value (bool force_conversion) const
{
  FixedPoint retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex matrix", "fixed scalar");

  if (rows () > 0 && columns () > 0)
    {
      gripe_implicit_conversion ("Octave:array-as-scalar",
				 "real matrix", "real scalar");

      retval = ::real( matrix (0, 0));
    }
  else
    gripe_invalid_conversion ("fixed complex matrix", "fixed scalar");

  return retval;
}

Matrix
octave_fixed_complex_matrix::matrix_value (bool force_conversion) const
{
  Matrix retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex matrix", "real matrix");


  retval = ::real (matrix.fixedpoint());

  return retval;
}

FixedMatrix
octave_fixed_complex_matrix::fixed_matrix_value (bool force_conversion) const
{
  FixedMatrix retval;

  if (! force_conversion)
    gripe_implicit_conversion ("Octave:imag-to-real",
			       "fixed complex matrix", "fixed matrix");

  retval = ::real (matrix);

  return retval;
}

Complex
octave_fixed_complex_matrix::complex_value (bool) const
{
  double tmp = lo_ieee_nan_value ();

  Complex retval (tmp, tmp);

  if (rows () > 0 && columns () > 0)
    {
      gripe_implicit_conversion ("Octave:array-as-scalar",
				 "real matrix", "real scalar");
	  
      retval = matrix (0, 0) .fixedpoint();
    }
  else
    gripe_invalid_conversion ("fixed matrix", "complex scalar");

  return retval;
}

static void
restore_precision (int *p)
{
  bind_internal_variable ("output_precision", *p);
}

void
octave_fixed_complex_matrix::print_raw (std::ostream& os,
				   bool pr_as_read_syntax) const
{
  double min_num = std::max(::abs(::real(matrix)).row_min().min().fixedpoint(),
			    ::abs(::imag(matrix)).row_min().min().fixedpoint());
  int new_prec = (int)std::max(::real(matrix).getdecsize().row_max().max(),
			       ::imag(matrix).getdecsize().row_max().max()) +
    (min_num >= 1. ? (int)::log10(min_num) + 1 : 0);

  octave_value_list tmp = feval ("output_precision");
  int prec = tmp(0).int_value ();

  unwind_protect frame;

  frame.add_fcn (restore_precision, &prec);

  bind_internal_variable ("output_precision", new_prec);

  octave_print_internal (os, complex_matrix_value(), false, 
			 current_print_indent_level ());
}

bool 
octave_fixed_complex_matrix::save_ascii (std::ostream& os) 
{
  dim_vector d = dims ();
  os << "# ndims: " << d.length () << "\n";

  for (int i=0; i < d.length (); i++)
    os << " " << d (i);

  FixedMatrix re (::real (matrix));
  FixedMatrix im (::imag (matrix));
  os << "\n" << re.getintsize () << im.getintsize ()
     << re.getdecsize () << im.getdecsize () 
     << re.fixedpoint() << im.fixedpoint ();

  return true;
}

bool 
octave_fixed_complex_matrix::load_ascii (std::istream& is)
{
  int mdims;
  bool success = true;

  if (extract_keyword (is, "ndims", mdims))
    {
      dim_vector dv;
      dv.resize (mdims);
      
      for (int i = 0; i < mdims; i++)
	is >> dv(i);

      if (dv.length() != 2)
	{
	  error ("load: N-D fixed arrays not supported");
	  success = false;
	}
      else
	{
	  Matrix rintsize (dv(0), dv(1)), rdecsize (dv(0), dv(1)), 
	    rnumber (dv(0), dv(1));
	  Matrix iintsize (dv(0), dv(1)), idecsize (dv(0), dv(1)), 
	    inumber (dv(0), dv(1));

	  is >> rintsize >> iintsize >> rdecsize >> idecsize 
	     >> rnumber >> inumber;

	  if (!is) 
	    {
	      error ("load: failed to load matrix constant");
	      success = false;
	    }
	  matrix = 
	    FixedComplexMatrix (FixedMatrix (rintsize, rdecsize, rnumber),
				FixedMatrix (iintsize, idecsize, inumber));

	}
    }
  else 
    {
      error ("load: failed to extract dimension of fixed point variable");
      success = false;
    }

  return success;;
}

bool 
octave_fixed_complex_matrix::save_binary (std::ostream& os, 
					  bool& save_as_floats)
{
  dim_vector d = dims ();

  // Only treat 2-D array for now
  if (d.length() != 2)
    return false;

  // Use negative value for ndims to be consistent with other types
  int32_t tmp = - d.length();
  os.write (X_CAST (char *, &tmp), 4);
  for (int i=0; i < d.length (); i++)
    {
      tmp = d(i);
      os.write (X_CAST (char *, &tmp), 4);
    }

  char size = (char) sizeof (unsigned int);
  os.write (X_CAST (char *, &size), 1);

  // intsize and decsize are integers in the range [0:32], so store as char
  FixedMatrix re (::real (matrix)), im (::imag (matrix));
  LS_DO_WRITE (char, re.getintsize ().fortran_vec (), 1, d.numel (), os);
  LS_DO_WRITE (char, im.getintsize ().fortran_vec (), 1, d.numel (), os);
  LS_DO_WRITE (char, re.getdecsize ().fortran_vec (), 1, d.numel (), os);
  LS_DO_WRITE (char, im.getdecsize ().fortran_vec (), 1, d.numel (), os);
  LS_DO_WRITE (unsigned int, re.getnumber ().fortran_vec (), 
	       sizeof (unsigned int), d.numel (), os);
  LS_DO_WRITE (unsigned int, im.getnumber ().fortran_vec (), 
	       sizeof (unsigned int), d.numel (), os);

  return true;
}

bool 
octave_fixed_complex_matrix::load_binary (std::istream& is, bool swap,
				 oct_mach_info::float_format fmt)
{
  int32_t mdims;
  if (! is.read (X_CAST (char *, &mdims), 4))
    return false;
  if (swap)
    swap_bytes <4> (X_CAST (char *, &mdims));

  if (mdims != -2)
    return false;

  mdims = - mdims;
  int32_t di;
  dim_vector dv;
  dv.resize (mdims);

  for (int i = 0; i < mdims; i++)
    {
      if (! is.read (X_CAST (char *, &di), 4))
	return false;
      if (swap)
	swap_bytes <4> (X_CAST (char *, &di));
      dv(i) = di;
    }

  char size;
  Matrix rintsize (dv(0), dv(1)), rdecsize (dv(0), dv(1)), 
    rnumber (dv(0), dv(1));
  Matrix iintsize (dv(0), dv(1)), idecsize (dv(0), dv(1)), 
    inumber (dv(0), dv(1));

  if (! is.read (X_CAST (char *, &size), 1))
    return false;

  LS_DO_READ_1(rintsize.fortran_vec (), dv.numel (), is);
  LS_DO_READ_1(iintsize.fortran_vec (), dv.numel (), is);
  LS_DO_READ_1(rdecsize.fortran_vec (), dv.numel (), is);
  LS_DO_READ_1(idecsize.fortran_vec (), dv.numel (), is);

  if (size == 4)
    {
      LS_DO_READ(unsigned int, swap, rnumber.fortran_vec (), 4, 
		 dv.numel (), is);
      LS_DO_READ(unsigned int, swap, inumber.fortran_vec (), 4, 
		 dv.numel (), is);
    }
  else if (size == 8)
    {
      LS_DO_READ(unsigned int, swap, rnumber.fortran_vec (), 8, 
		 dv.numel (), is);
      LS_DO_READ(unsigned int, swap, inumber.fortran_vec (), 8, 
		 dv.numel (), is);
    }
  else
    return false;

  if (error_state || ! is)
    return false;
  
  // This is ugly, is there a better way?
  matrix.resize (dim_vector (dv(0), dv(1)));
  for (int i = 0; i < dv(0); i++)
    for (int j = 0; j < dv(1); j++)
      matrix (i, j) = 
	FixedPointComplex (FixedPoint ((unsigned int)rintsize (i, j), 
				       (unsigned int)rdecsize (i, j), 
				       (unsigned int)rnumber (i, j)),
			   FixedPoint ((unsigned int)iintsize (i, j), 
				       (unsigned int)idecsize (i, j), 
				       (unsigned int)inumber (i, j)));
  
  return true;
}

#if defined (HAVE_HDF5)
bool
octave_fixed_complex_matrix::save_hdf5 (hid_t loc_id, const char *name, 
					bool save_as_floats)
{
  hid_t group_hid = -1;

#if HAVE_HDF5_18
  group_hid = H5Gcreate (loc_id, name, 0, H5P_DEFAULT, H5P_DEFAULT);
#else
  group_hid = H5Gcreate (loc_id, name, 0);
#endif

  if (group_hid < 0 ) return false;

  dim_vector d = dims ();
  OCTAVE_LOCAL_BUFFER(hsize_t, hdims, d.length () > 2 ? d.length () : 3);
  hid_t space_hid = -1, data_hid = -1, type_hid = -1;
  int rank = ( (d (0) == 1) && (d.length () == 2) ? 1 : d.length ());
  bool retval = true;

  // Octave uses column-major, while HDF5 uses row-major ordering
  for (int i = 0, j = d.length() - 1; i < d.length (); i++, j--)
    hdims[i] = d (j);

  space_hid = H5Screate_simple (rank, hdims, (hsize_t*) 0);
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
  
  Complex * m = matrix.getintsize ().fortran_vec ();
  OCTAVE_LOCAL_BUFFER(unsigned char, tmp, 2 * d.numel ());
  for (int i = 0; i < d.numel (); i++)
    {
      tmp[i<<1] = (unsigned char) std::real (m[i]);
      tmp[(i<<1)+1] = (unsigned char) std::imag (m[i]);
    }
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
  
  m = matrix.getdecsize (). fortran_vec ();
  for (int i = 0; i < d.numel (); i++)
    {
      tmp[i<<1] = (unsigned char) std::real (m[i]);
      tmp[(i<<1)+1] = (unsigned char) std::imag (m[i]);
    }
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
  
  m = matrix.getnumber ().fortran_vec ();
  OCTAVE_LOCAL_BUFFER(unsigned int, num, 2*d.numel ());
  for (int i = 0; i < d.numel (); i++)
    {
      num[i<<1] = (unsigned int) std::real (m[i]);
      num[(i<<1)+1] = (unsigned int) std::imag (m[i]);
    }
  retval = H5Dwrite (data_hid, type_hid, H5S_ALL, H5S_ALL, H5P_DEFAULT,
		     (void*) num) >= 0;
  H5Dclose (data_hid);
  H5Sclose (space_hid);
  H5Tclose (type_hid);
  H5Gclose (group_hid);
  return retval;
}

bool
octave_fixed_complex_matrix::load_hdf5 (hid_t loc_id, const char *name,
					bool have_h5giterate_bug)
{
  herr_t retval = -1;
  hid_t group_hid, data_hid, space_id, type_hid;
  hsize_t rank, rank_old;

#if HAVE_HDF5_18
  group_hid = H5Gopen (loc_id, name, H5P_DEFAULT);
#else
  group_hid = H5Gopen (loc_id, name);
#endif

  if (group_hid < 0 ) return false;

  hid_t complex_type = hdf5_make_fixed_complex_type (H5T_NATIVE_UINT, 
						     sizeof(unsigned int));

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
  rank_old = rank;

  if (rank < 1 || rank > 2)
    {
      // No N-D array yet
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  OCTAVE_LOCAL_BUFFER (hsize_t, hdims, rank);
  OCTAVE_LOCAL_BUFFER (hsize_t, maxdims, rank);

  H5Sget_simple_extent_dims (space_id, hdims, maxdims);

  dim_vector dv;
  dim_vector dv_old;

  // Octave uses column-major, while HDF5 uses row-major ordering
  if (rank == 1)
    {
      dv.resize (2);
      dv(0) = 1;
      dv(1) = hdims[0];
    }
  else
    {
      dv.resize (rank);
      for (int i = 0, j = rank - 1; i < (int)rank; i++, j--)
	dv(j) = hdims[i];
    }
  dv_old = dv;

  OCTAVE_LOCAL_BUFFER (unsigned int, intsize, 2 * dv.numel ());
  if (H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, 
	       (void *) intsize) < 0) 
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
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

  if (rank != rank_old)
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Sget_simple_extent_dims (space_id, hdims, maxdims);

  // Octave uses column-major, while HDF5 uses row-major ordering
  if (rank == 1)
    {
      dv.resize (2);
      dv(0) = 1;
      dv(1) = hdims[0];
    }
  else
    {
      dv.resize (rank);
      for (int i = 0, j = rank - 1; i < (int)rank; i++, j--)
	dv(j) = hdims[i];
    }

  if (dv_old != dv)
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  OCTAVE_LOCAL_BUFFER (unsigned int, decsize, 2 * dv.numel ());
  if (H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, H5P_DEFAULT, 
	       (void *) decsize) < 0) 
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }
  H5Tclose(type_hid);
  H5Dclose (data_hid);

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

  if (rank != rank_old)
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  H5Sget_simple_extent_dims (space_id, hdims, maxdims);

  // Octave uses column-major, while HDF5 uses row-major ordering
  if (rank == 1)
    {
      dv.resize (2);
      dv(0) = 1;
      dv(1) = hdims[0];
    }
  else
    {
      dv.resize (rank);
      for (int i = 0, j = rank - 1; i < (int)rank; i++, j--)
	dv(j) = hdims[i];
    }

  if (dv_old != dv)
    {
      H5Tclose(complex_type);
      H5Tclose(type_hid);
      H5Sclose (space_id);
      H5Dclose (data_hid);
      H5Gclose (group_hid);
      return false;
    }

  OCTAVE_LOCAL_BUFFER (unsigned int, number, 2 * dv.numel ());
  retval = H5Dread (data_hid, complex_type, H5S_ALL, H5S_ALL, 
		    H5P_DEFAULT, (void *) number); 
  H5Tclose(complex_type);
  H5Tclose(type_hid);
  H5Dclose (data_hid);
  H5Sclose (space_id);
  H5Gclose (group_hid);
  if (retval < 0)
    return false;

  // This is ugly, is there a better way?
  matrix.resize (dim_vector (dv(0), dv(1)));
  unsigned int * ivec = intsize;
  unsigned int * dvec = decsize;
  unsigned int * nvec = number;
  for (int j = 0; j < dv(1); j++)
    for (int i = 0; i < dv(0); i++)
      matrix (i, j) = 
	FixedPointComplex (FixedPoint (*ivec++, *dvec++, *nvec++),
			   FixedPoint (*ivec++, *dvec++, *nvec++));


  return true;
}
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
