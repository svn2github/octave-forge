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

#if !defined (octave_galois_field_int_h)
#define octave_galois_field_int_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <string>

#include "MArray.h"
#include "MArray2.h"

#include "mx-defs.h"
#include "mx-op-defs.h"

// Maximum value of m
#define __OCTAVE_GALOIS_MAX_M  16

// A0 flag -inf value
#define __OCTAVE_GALOIS_A0  (n)

// The default primitive polynomials for GF(2^(indx+1))
extern int default_galois_primpoly[];

class galois_field_node {
  friend class galois_field_list;
  friend class galois;

private:
  int m;
  int primpoly;
  int n;
  MArray<int> alpha_to;
  MArray<int> index_of;

  galois_field_node *next;
  galois_field_node *prev;

  int count;

public:
  galois_field_node (void);
  galois_field_node (const int& _m = 1, const int& _primpoly = 0);
  galois_field_node & operator = (const galois_field_node &t);
};

class galois_field_list {
private:
  galois_field_node *first;
  galois_field_node *last;

public:
  galois_field_list (void) : first (NULL), last (NULL) { }

  ~galois_field_list( void);

  galois_field_node * find_galois_field(const int& m, const int& primpoly);
  galois_field_node * create_galois_field(const int& m, const int& primpoly);
  int delete_galois_field(galois_field_node *field);

};

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
