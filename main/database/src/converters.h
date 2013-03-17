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

#include <libpq-fe.h>

#define OCT_PQ_NUM_CONVERTERS 13

typedef std::vector<char> oct_pq_dynvec_t;

typedef int (*oct_pq_to_octave_fp_t) (const char *, octave_value &, int);

typedef int (*oct_pq_from_octave_fp_t) (const octave_value &, oct_pq_dynvec_t &);

typedef std::vector<Oid> oct_pq_el_oids_t;

struct oct_pq_conv_t_;

typedef std::vector<struct oct_pq_conv_t_ *> oct_pq_conv_cache_t;

// some objects will be constants, some will be allocated
typedef struct oct_pq_conv_t_
{
  Oid oid; // read from server
  Oid aoid; // array oid // read from server
  oct_pq_el_oids_t el_oids; // element oids, empty for non-composite types
  oct_pq_conv_cache_t conv_cache; // element converter structures for
                                  //composite types
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

std::string &pq_basetype_prefix (void);

// a wrapper class for array of pointers to converters which qualifies
// base type names in initialization
class oct_pq_conv_ptrs_t
{
public:

  oct_pq_conv_ptrs_t (int n, oct_pq_conv_t **ptrs) : converters (ptrs)
  {
    for (int i = 0; i < n; i++)
      {
        std::string prefix = pq_basetype_prefix ();

        converters[i]->name = prefix.append (converters[i]->name);
      }
  }

  oct_pq_conv_t *operator[] (int i) { return converters[i]; }

private:

  oct_pq_conv_t **converters;
};

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

extern oct_pq_conv_ptrs_t conv_ptrs;

// these prototypes are needed because pointers to these functions are
// stored in the converter structures of each found enum type
int to_octave_str_text (const char *c, octave_value &ov, int nb);
int to_octave_bin_text (const char *c, octave_value &ov, int nb);
int from_octave_str_text (const octave_value &ov, oct_pq_dynvec_t &val);
int from_octave_bin_text (const octave_value &ov, oct_pq_dynvec_t &val);

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
