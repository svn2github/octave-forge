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

#if !defined (octave_base_fixed_mat_h)
#define octave_base_fixed_mat_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <cstdlib>

#include <iostream>
#include <string>

#include <octave/mx-base.h>
#include <octave/str-vec.h>

#include <octave/error.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>

class Octave_map;
class octave_value_list;

class tree_walker;

template <class MT>
class
octave_base_fixed_matrix : public octave_base_value
{
public:

  octave_base_fixed_matrix (void)
    : octave_base_value () { }

  octave_base_fixed_matrix (const MT& m)
    : octave_base_value (), matrix (m) { }

  octave_base_fixed_matrix (const octave_base_fixed_matrix& m)
    : octave_base_value (), matrix (m.matrix) { }

  ~octave_base_fixed_matrix (void) { }

  octave_value subsref (const std::string& type,
			const std::list<octave_value_list>& idx);

  octave_value_list subsref (const std::string& type,
			     const std::list<octave_value_list>& idx,
    			     int nargout)
    {
      panic_impossible ();
      return octave_value_list ();
    }

  octave_value_list dotref (const octave_value_list& idx);

  void assign (const octave_value_list& idx, const MT& rhs);

#ifdef HAVE_ND_ARRAYS
  dim_vector dims (void) const { return matrix.dims (); }
#else
  int rows (void) const { return matrix.rows (); }
  int columns (void) const { return matrix.columns (); }

  int length (void) const
  {
    int r = rows ();
    int c = columns ();

    return (r == 0 || c == 0) ? 0 : ((r > c) ? r : c);
  }
#endif

  octave_value all (int dim = 0) const { return matrix.all (dim); }
  octave_value any (int dim = 0) const { return matrix.any (dim); }

  bool is_matrix_type (void) const { return true; }

  bool is_numeric_type (void) const { return true; }

  bool is_defined (void) const { return true; }

  bool is_constant (void) const { return true; }

  bool is_true (void) const;

  bool is_map (void) const { return true; }

  bool valid_as_scalar_index (void) const;

  virtual bool print_as_scalar (void) const;

  void print (std::ostream& os, bool pr_as_read_syntax = false) const;

  bool print_name_tag (std::ostream& os, const std::string& name) const;

  void print_info (std::ostream& os, const std::string& prefix) const;

protected:

  MT matrix;
};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
