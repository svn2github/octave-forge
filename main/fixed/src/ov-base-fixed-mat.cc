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

#include <config.h>
#include <iostream>
#include <octave/oct-obj.h>
#include <octave/ov-base.h>
#include <octave/ov-base-scalar.h>
#include <octave/pr-output.h>

template <class MT>
octave_value_list
octave_base_fixed_matrix<MT>::dotref (const octave_value_list& idx)
{
  octave_value_list retval;

  assert (idx.length () == 1);

  std::string nm = idx(0).string_value ();

  if (nm == __FIXED_SIGN_STR)
    retval(0) = octave_value (matrix.sign());
  else if (nm == __FIXED_VALUE_STR) 
    retval(0) = octave_value (matrix.fixedpoint());
  else if (nm == __FIXED_DECSIZE_STR)
    retval(0) = octave_value (matrix.getdecsize());
  else if (nm == __FIXED_INTSIZE_STR)
    retval(0) = octave_value (matrix.getintsize());
  else
    error ("fixed point structure has no member `%s'", nm.c_str ());    

  return retval;
}

template <class MT>
octave_value
octave_base_fixed_matrix<MT>::subsref (const std::string& type,
				 const std::list<octave_value_list>& idx)
{
  octave_value retval;

  switch (type[0])
    {
    case '(':
      retval = do_index_op (idx.front ());
      break;

    case '.':
      {
	octave_value_list t = dotref (idx.front ());

	retval = (t.length () == 1) ? t(0) : octave_value (t);
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

  return retval.next_subsref (type, idx);
}

template <class MT>
void
octave_base_fixed_matrix<MT>::assign (const octave_value_list& idx, 
				      const MT& rhs)
{
  int len = idx.length ();

  if (len > 2)
      error ("invalid number of indices (%d) for indexed assignment",
	     len);
  else
    {
      Array<idx_vector> ra_idx (dim_vector (len, 1));

      for (octave_idx_type i = 0; i < len; i++)
	ra_idx(i) = idx(i).index_vector ();

      matrix.assign (ra_idx, rhs, FixedPoint ());
    }
}

template <class MT>
bool
octave_base_fixed_matrix<MT>::is_true (void) const
{
  bool retval = false;

  if (rows () > 0 && columns () > 0)
    {
      boolMatrix m = (matrix.all () . all ());

      retval = (m.rows () == 1 && m.columns () == 1 && m(0,0));
    }

  return retval;
}

template <class MT>
bool
octave_base_fixed_matrix<MT>::valid_as_scalar_index (void) const
{
  // XXX FIXME XXX
  return false;
}

template <class MT>
bool
octave_base_fixed_matrix<MT>::print_as_scalar (void) const
{
  int nr = rows ();
  int nc = columns ();

  return (nr == 1 && nc == 1 || (nr == 0 || nc == 0));
}

template <class MT>
void
octave_base_fixed_matrix<MT>::print (std::ostream& os, bool pr_as_read_syntax) const
{
  print_raw (os, pr_as_read_syntax);
  newline (os);
}

template <class MT>
bool
octave_base_fixed_matrix<MT>::print_name_tag (std::ostream& os,
					const std::string& name) const
{
  bool retval = false;

  indent (os);

  if (print_as_scalar ())
    os << name << " = ";
  else
    {
      os << name << " =";
      newline (os);
      newline (os);
      retval = true;
    }

  return retval;
}

template <class MT>
void
octave_base_fixed_matrix<MT>::print_info (std::ostream& os,
				    const std::string& prefix) const
{
  matrix.print_info (os, prefix);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
