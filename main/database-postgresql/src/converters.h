/*

Copyright (C) 2012, 2013 Olaf Till <i7tiol@t-online.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef __OCT_PQ_CONVERTERS__

#define __OCT_PQ_CONVERTERS__

#include <octave/oct.h>

#include <stdint.h>
#include <endian.h>

#include <vector>
#include <string>

#include <postgresql/libpq-fe.h>

#define OCT_PQ_NUM_CONVERTERS 13

typedef std::vector<char> oct_pq_dynvec_t;

typedef int (*oct_pq_to_octave_fp_t) (char *, octave_value &, int);

typedef int (*oct_pq_from_octave_fp_t) (octave_value &, oct_pq_dynvec_t &);

// some objects will be constants, some will be allocated
typedef struct
{
  Oid oid; // read from server
  Oid aoid; // array oid // read from server
  Oid relid; // pg_attribute.attrelid, zero for non-composite types
  bool is_composite; // false for constant objects
  bool is_enum; // false for constant objects
  bool is_not_constant; // false for constant objects
  // const char *name; not all constants, use std::string
  std::string name;
  oct_pq_to_octave_fp_t to_octave_str;
  oct_pq_to_octave_fp_t to_octave_bin;
  oct_pq_from_octave_fp_t from_octave_str;
  oct_pq_from_octave_fp_t from_octave_bin;
}
  oct_pq_conv_t;

// a wrapper class around oct_pq_conv_t* to provide a default
// constructor which nullifies it, for efficient use of maps, where
// checking for the presence of a key while inserting it can rely on a
// newly generated key mapping to a value of NULL
class oct_pq_conv_wrapper_t
{
public:

  oct_pq_conv_wrapper_t (void) : conv (NULL) {}

  oct_pq_conv_wrapper_t (oct_pq_conv_t *c) : conv (c) {}

  operator oct_pq_conv_t *&(void) { return conv; }

  oct_pq_conv_t *&operator->(void) { return conv; }

private:

  oct_pq_conv_t *conv;
};

// helper function for debugging
void print_conv (oct_pq_conv_t *);

extern oct_pq_conv_t *conv_ptrs[OCT_PQ_NUM_CONVERTERS];

// append bytes of value 'val' of type 'type' to dynamic char vector 'dv'
#define OCT_PQ_PUT(dv, type, val)                       \
  dv.resize (dv.size () + sizeof (type));               \
  *((type *) &(dv.end ()[-sizeof (type)])) = val;

// increase size of dynamic char vector 'dv' by size of uint32 and
// store the new size in a variable named 'var' of octave_idx_type;
// after further increasing 'dv', OCT_PQ_FILL_UINT32_PLACEHOLDER
// should be used with equal arguments
#define OCT_PQ_SET_UINT32_PLACEHOLDER(dv, var)          \
  octave_idx_type var = dv.size () + sizeof (uint32_t); \
  dv.resize (var);
// to be used after OCT_PQ_SET_UINT32_PLACEHOLDER with equal
// arguments; calculate difference between current size of dynamic
// char vector 'dv' and a previous size stored in a variable named
// 'var', and write this difference, converted to uint32_t in network
// byte order, to the placeholder within 'dv' just before the position
// stored in 'var'
#define OCT_PQ_FILL_UINT32_PLACEHOLDER(dv, var)                         \
  *((uint32_t *) &(dv[var - sizeof (uint32_t)])) = htobe32 (dv.size () - var);

#define OCT_PQ_DECL_GET_INT32(retvar, pointer, type)    \
  type retvar = be32toh (*((type *) pointer));          \
  pointer += 4;

#define OCT_PQ_GET_INT32(retvar, pointer, type)         \
  retvar = be32toh (*((type *) pointer));          \
  pointer += 4;

#endif // __OCT_PQ_CONVERTERS__
