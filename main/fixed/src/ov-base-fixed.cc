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

template <class ST>
octave_value_list
octave_base_fixed<ST>::dotref (const octave_value_list& idx)
{
  octave_value_list retval;

  assert (idx.length () == 1);

  std::string nm = idx(0).string_value ();

  if (nm == __FIXED_SIGN_STR)
    retval(0) = octave_value (scalar.sign());
  else if (nm == __FIXED_VALUE_STR) 
    retval(0) = octave_value (scalar.fixedpoint());
  else if (nm == __FIXED_DECSIZE_STR)
    retval(0) = octave_value (scalar.getdecsize());
  else if (nm == __FIXED_INTSIZE_STR)
    retval(0) = octave_value (scalar.getintsize());
  else
    error ("fixed point structure has no member `%s'", nm.c_str ());    

  return retval;
}

template <class ST>
octave_value
octave_base_fixed<ST>::subsref (const std::string& type,
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

template <class ST>
void
octave_base_fixed<ST>::print (std::ostream& os, bool pr_as_read_syntax) const
{
  print_raw (os, pr_as_read_syntax);
  newline (os);
}

template <class ST>
bool
octave_base_fixed<ST>::print_name_tag (std::ostream& os,
					const std::string& name) const
{
  indent (os);
  os << name << " = ";
  return false;    
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
