/*

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

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#include <iostream>
#include <octave/unwind-prot.h>
#include "galois.h"
#include "ov-galois.h"

#ifdef USE_OCTAVE_NAN
#define lo_ieee_nan_value() octave_NaN
#endif

DEFINE_OCTAVE_ALLOCATOR(octave_galois);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA(octave_galois, "galois");

octave_value_list
octave_galois::dotref (const octave_value_list& idx)
{
  octave_value_list retval;

  assert (idx.length () == 1);

  std::string nm = idx(0).string_value ();

  if (nm == __GALOIS_PRIMPOLY_STR)
    retval(0) = octave_value ((double)gval.primpoly());
  else if (nm == __GALOIS_ORDER_STR)
    retval(0) = octave_value ((double)gval.m());
  else if (nm == __GALOIS_DATA_STR) {
    int r = gval.rows();
    int c = gval.columns();
    Matrix data(r,c);
    for (int i=0; i< r; i++)
      for (int j=0; j< c; j++)
	data(i,j) = (double)gval.elem(i,j);
    retval(0) = octave_value (data);
  } 
#ifdef GALOIS_DISP_PRIVATES
  else if (nm == __GALOIS_LENGTH_STR)
    retval(0) = octave_value((double)gval.n());
  else if (nm == __GALOIS_ALPHA_TO_STR) {
    int n = gval.n();
    Matrix data(n+1,1);
    for (int i=0; i< n+1; i++)
      data(i,0) = (double)gval.alpha_to(i);
    retval(0) = octave_value (data);
  } else if (nm == __GALOIS_INDEX_OF_STR) {
    int n = gval.n();
    Matrix data(n+1,1);
    for (int i=0; i< n+1; i++)
      data(i,0) = (double)gval.index_of(i);
    retval(0) = octave_value (data);
  }
#endif
  else
    error ("galois structure has no member `%s'", nm.c_str ());    

  return retval;
}

octave_value
octave_galois::do_index_op (const octave_value_list& idx,
			    int resize_ok)
{
  octave_value retval;

  int len = idx.length ();

  switch (len)
    {
    case 2:
      {
	idx_vector i = idx (0).index_vector ();
	idx_vector j = idx (1).index_vector ();
  
	retval = new octave_galois (gval.index (i, j, resize_ok, galois::resize_fill_value ()));
      }
      break;

    case 1:
      {
	idx_vector i = idx (0).index_vector ();

	retval = new octave_galois (gval.index (i, resize_ok, galois::resize_fill_value ()));
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
octave_galois::subsref (const std::string SUBSREF_STRREF type,
			const LIST<octave_value_list>& idx)
{
  octave_value retval;

  int skip = 1;

  switch (type[0])
    {
    case '(':
      retval = do_index_op (idx.front (), true);
      break;

    case '.':
      {
	octave_value_list t = dotref (idx.front ());

	retval = (t.length () == 1) ? t(0) : octave_value (t);
      }
      break;

    case '{':
      error ("%s cannot be indexed with %c", type_name().c_str(), type[0]);
      break;

    default:
      panic_impossible ();
    }

  if (! error_state)
    retval = retval.next_subsref (type, idx, skip);

  return retval;
}

bool
octave_galois::is_true (void) const
{
  bool retval = false;

  if (rows () == 0 || columns () == 0)
    {
      int flag = Vpropagate_empty_matrices;

      if (flag < 0)
	warning ("empty matrix used in conditional expression");
      else if (flag == 0)
	error ("empty matrix used in conditional expression");
    }
  else
    {
      boolMatrix m = (gval.all () . all ());

      retval = (m.rows () == 1 && m.columns () == 1 && m(0,0));
    }

  return retval;
}

bool
octave_galois::print_as_scalar (void) const
{
  int nr = rows ();
  int nc = columns ();

  return (nr == 1 && nc == 1 || (nr == 0 || nc == 0));
}

void
octave_galois::print (std::ostream& os, bool) const
{
  print_raw (os);
}

void
octave_galois::print_raw (std::ostream& os, bool) const
{
  unwind_protect::begin_frame ("octave_galois_print");

  unwind_protect_int (Vstruct_levels_to_print);

  bool first = true;
  int m = gval.m();
  int primpoly = gval.primpoly();
  Matrix data(gval.rows(), gval.cols());

  indent (os);

  if (m == 1)
    os << "GF(2) array.";
  else {
    os << "GF(2^" << m << ") array. Primitive Polynomial = ";

    for (int i=m; i>=0; i--) {
      if (primpoly & (1<<i)) {
	if (i > 0) {
	  if (first) {
	    first = false;
	    os << "D";
	  } else
	    os << "+D";
	  if (i != 1)
	    os << "^" << i;
	} else {
	  if (first) {
	    first = false;
	    os << "1";
	  } else
	    os << "+1";
	}
      }
    }
    os << " (decimal " << primpoly << ")";
  }
  newline (os);
  newline (os);
  indent (os);

  os << "Array elements = ";
  newline (os);
  newline (os);

  for (int i = 0; i < gval.rows(); i++)
    for (int j = 0; j < gval.columns(); j++)
      data(i,j) = (double)gval.elem(i,j);

  octave_print_internal (os, data, false, current_print_indent_level ());
  newline (os);

  unwind_protect::run_frame ("octave_galois_print");
}

bool
octave_galois::print_name_tag (std::ostream& os, const std::string& name) const
{
  bool retval = false;

  indent (os);

  if (Vstruct_levels_to_print < 0)
    os << name << " = ";
  else
    {
      os << name << " =";
      newline (os);
      retval = true;
    }

  return retval;
}

void
octave_galois::print_info (std::ostream& os, const std::string& prefix) const
{
  gval.print_info (os, prefix);
}

double
octave_galois::double_value (bool) const
{
  double retval = lo_ieee_nan_value ();

  // XXX FIXME XXX -- maybe this should be a function, valid_as_scalar()
  if ((rows () == 1 && columns () == 1)
      || (Vdo_fortran_indexing && rows () > 0 && columns () > 0))
    retval = (double) gval (0, 0);
  else
    gripe_invalid_conversion ("galois", "real scalar");

  return retval;
}

Complex
octave_galois::complex_value (bool) const
{
  double tmp = lo_ieee_nan_value ();

  Complex retval (tmp, tmp);

  if ((rows () == 1 && columns () == 1)
      || (Vdo_fortran_indexing && rows () > 0 && columns () > 0))
    retval = (double) gval (0, 0);
  else
    gripe_invalid_conversion ("galois", "complex scalar");

  return retval;
}

Matrix
octave_galois::matrix_value (bool) const
{
  Matrix retval;

  retval.resize(rows(),columns());
  for (int i=0; i<rows(); i++)
    for (int j=0; j<columns(); j++)
      retval(i,j) = gval.elem(i,j);

  return retval;
}

void
octave_galois::assign (const octave_value_list& idx,
			       const galois& rhs)
{
  int len = idx.length ();

  if (gval.have_field() && rhs.have_field()) {
    if ((gval.m() != rhs.m()) || (gval.primpoly() != rhs.primpoly())) {
      (*current_liboctave_error_handler) ("can not assign data between two different Galois Fields");
      return;
    }
  }

  switch (len)
    {
    case 2:
      {
	idx_vector i = idx (0).index_vector ();
	idx_vector j = idx (1).index_vector ();

	gval.set_index (i);
	gval.set_index (j);

	::assign (gval, rhs);
      }
      break;

    case 1:
      {
	idx_vector i = idx (0).index_vector ();

	gval.set_index (i);

	::assign (gval, rhs);
      }
      break;

    default:
      error ("invalid number of indices (%d) for galois assignment",
	     len);
      break;
    }
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
