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

#if !defined (octave_base_fixed_h)
#define octave_base_fixed_h 1

#include <cstdlib>

#include <iostream>
#include <string>

#include <octave/lo-mappers.h>
#include <octave/lo-utils.h>
#include <octave/oct-alloc.h>
#include <octave/str-vec.h>

#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>

// Real scalar values.

template <class ST>
class
octave_base_fixed : public octave_base_value
{
public:

  octave_base_fixed (void)
    : octave_base_value () { }

  octave_base_fixed (const ST& s)
    : octave_base_value (), scalar (s) { }

  octave_base_fixed (const octave_base_fixed& s)
    : octave_base_value (), scalar (s.scalar) { }

  octave_base_fixed (const unsigned int& is, const unsigned int& ds,
		const ST& s)
    : octave_base_value(), scalar(ST (is, ds, s)) { }

  ~octave_base_fixed (void) { }

  octave_value subsref (const std::string& type,
			const std::list<octave_value_list>& idx);

  octave_value_list subsref (const std::string& type,
			     const std::list<octave_value_list>& idx, int)
    { return subsref (type, idx); }

  octave_value_list dotref (const octave_value_list& idx);

  size_t byte_size (void) const { return sizeof (ST); }

  dim_vector dims (void) const { static dim_vector dv (1, 1); return dv; }

  bool is_constant (void) const { return true; }

  bool is_defined (void) const { return true; }

  bool is_map (void) const { return true; }

  octave_value all (int = 0) const { return (scalar != ST()); }

  octave_value any (int = 0) const { return (scalar != ST()); }

  bool is_scalar_type (void) const { return true; }

  bool is_numeric_type (void) const { return true; }

  bool is_true (void) const { return (scalar != ST()); }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const;

  bool print_name_tag (std::ostream& os, const std::string& name) const;

protected:

  // The value of this scalar.
  ST scalar;
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
