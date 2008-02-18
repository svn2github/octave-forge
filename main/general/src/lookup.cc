// Copyright (C) 2008 VZLU Prague a.s., Czech Republic
//
// Author: Jaroslav Hajek <highegg@gmail.com>
//
// This file is part of Octave.
//
// Octave is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or (at
// your option) any later version.
//
// Octave is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Octave; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.
//

#include <oct.h>

// use this to select an appropriate output index type
#ifdef USE_64_BIT_IDX_T
typedef octave_uint64 ret_idx_type;
typedef uint64NDArray ret_idx_array;
#else 
typedef octave_uint32 ret_idx_type;
typedef uint32NDArray ret_idx_array;
#endif


// simple function templates & specialization is used
// to avoid writing two versions of the algorithm

// generic comparison
template<bool rev>
inline bool dcomp(const double& a,const double& b);
// normal comparison
template<>
inline bool dcomp<false>(const double& a,const double& b)
{ return a < b; }
// reversed comparison
template<>
inline bool dcomp<true>(const double& a,const double& b)
{ return a > b; }

template<bool rev>
static void do_seq_lookup(const double *begin,const double *end,
    const double *vals,size_t nvals,ret_idx_type *idx)
{
  if (!nvals) return;
  const double *first, *last;
  size_t cur;
  // the trivial case of empty array
  if (begin == end) {
    for(;nvals;--nvals) *(idx++) = 0;
    return;
  }
  // initialize 
  last = end;
  first = begin;

bin_search:    
  {
    size_t dist = last - first, half;

    while (dist > 0) {
      half = dist >> 1;
      last = first + half;
      if (dcomp<rev>(*last,*vals)) {
        first = last + 1;
        dist -= (half + 1);
      }
      else
        dist = half;
    }
    last = first;
  }

store_cur:
  cur = last - begin;

  if (last == begin) {
    // leftmost interval 
    while (nvals) {
      if (dcomp<rev>(*last,*vals)) goto search_forwards;
      *(idx++) = cur;
      nvals--; vals++;
    }
    return;
  } else if (last == end) {
    // rightmost interval 
    first = last - 1;
    while (nvals) {
      if (dcomp<rev>(*vals,*first)) goto search_backwards;
      *(idx++) = cur;
      nvals--; vals++;
    }
    return;
  } else {
    // inner interval 
    first = last - 1;
    while (nvals) {
      if (dcomp<rev>(*last,*vals)) goto search_forwards;
      if (dcomp<rev>(*vals,*first)) goto search_backwards;
      *(idx++) = cur;
      nvals--; vals++;
    }
    return;
  }

search_forwards:
  {
    size_t dist = 1, max = end - last;
    while(true) {
      first = last;
      if (dist < max) 
        last += dist;
      else {
        last = end;
        break;
      }
      if (!dcomp<rev>(*last,*vals)) break;
      max -= dist;
      dist <<= 1;
    }
    if (!(--dist))
      goto store_cur; // a shortcut
    else
      goto bin_search;
  }

search_backwards:
  {
    size_t dist = 1, max = first - begin;
    while(true) {
      last = first;
      if (dist < max) 
        first -= dist;
      else {
        first = begin;
        break;
      }
      if (!dcomp<rev>(*vals,*first)) break;
      max -= dist;
      dist <<= 1;
    }
    if (!(--dist))
      goto store_cur; // a shortcut
    else
      goto bin_search;
  }

}

static void seq_lookup(const double *table,size_t ntable,
    const double *vals,size_t nvals,ret_idx_type *idx)
{
  if (ntable > 1 && table[0] > table[ntable-1]) 
    do_seq_lookup<true>(table,table+ntable,vals,nvals,idx);
  else
    do_seq_lookup<false>(table,table+ntable,vals,nvals,idx);
}

DEFUN_DLD(lookup,args,nargout,"\
-*- texinfo -*- \n\
@deftypefn {Function File} {@var{idx} =} lookup (@var{table}, @var{y}) \n\
Lookup values in a sorted table.  Usually used as a prelude to \n\
interpolation. \n\
 \n\
If table is strictly increasing and @code{idx = lookup (table, y)}, then \n\
@code{table(idx(i)) <= y(i) < table(idx(i+1))} for all @code{y(i)} \n\
within the table.  If @code{y(i)} is before the table, then  \n\
@code{idx(i)} is 0. If @code{y(i)} is after the table then \n\
@code{idx(i)} is @code{table(n)}. \n\
 \n\
If the table is strictly decreasing, then the tests are reversed. \n\
There are no guarantees for tables which are non-monotonic or are not \n\
strictly monotonic. \n\
 \n\
To get an index value which lies within an interval of the table, \n\
use: \n\
 \n\
@example \n\
idx = lookup (table(2:length(table)-1), y) + 1 \n\
@end example \n\
 \n\
@noindent \n\
This expression puts values before the table into the first \n\
interval, and values after the table into the last interval. \n\
 \n\
If complex values are supplied, their magnitudes are used. \n\
@end deftypefn \n") 
{
  int nargin = args.length();

  if (nargin != 2 || nargout > 1) {
    print_usage();
    return octave_value_list();
  }

  octave_value table = args(0), y = args(1);
  NDArray atable;
  // in the case of complex array, absolute values will be used
  // (though it's not too meaningful) 
  if (table.is_real_type()) 
    atable = table.array_value();
  else if (table.is_complex_type())
    atable = table.complex_array_value().abs();
  else {
    error("table is not numeric type");
  }
  if (atable.ndims() > 2 || 
      (atable.rows() > 1 && atable.columns() > 1)) {
    error("table should be a vector");
    return octave_value_list();
  }
  NDArray ay;
  if (y.is_real_type()) 
    ay = y.array_value();
  else if (y.is_complex_type())
    ay = y.complex_array_value().abs();
  else {
    error("y is not numeric type");
  }

  ret_idx_array idx(y.dims());

  seq_lookup(atable.data(),(size_t)atable.numel(),ay.data(),
      (size_t)ay.numel(),idx.fortran_vec());

  return octave_value_list(octave_value(idx));
}  

/*
%!assert (real(lookup(1:3, 0.5)), 0)     # value before table
%!assert (real(lookup(1:3, 3.5)), 3)     # value after table error
%!assert (real(lookup(1:3, 1.5)), 1)     # value within table error
%!assert (real(lookup(1:3, [3,2,1])), [3,2,1])
%!assert (real(lookup([1:4]', [1.2, 3.5]')), [1, 3]');
%!assert (real(lookup([1:4], [1.2, 3.5]')), [1, 3]');
%!assert (real(lookup([1:4]', [1.2, 3.5])), [1, 3]);
%!assert (real(lookup([1:4], [1.2, 3.5])), [1, 3]);
%!assert (real(lookup(1:3, [3, 2, 1])), [3, 2, 1]);
%!assert (real(lookup([3:-1:1], [3.5, 3, 1.2, 2.5, 2.5])), [0, 1, 2, 1, 1])
%!assert (isempty(lookup([1:3], [])))
%!assert (isempty(lookup([1:3]', [])))
%!assert (real(lookup(1:3, [1, 2; 3, 0.5])), [1, 2; 3, 0]);
*/
