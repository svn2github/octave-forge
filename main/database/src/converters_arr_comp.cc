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

#include <octave/oct.h>
#include <octave/ov-struct.h>
#include <octave/Cell.h>
#include <octave/lo-ieee.h>

#include <stdint.h>
#include <endian.h>

#include "command.h"

octave_idx_type command::count_row_major_order (dim_vector &dv,
                                                count_state &state, bool init)
{
  if (init)
    {
      state.nd = dv.length ();

      state.cur.resize (state.nd);

      state.pd.resize (state.nd);

      // cannot be done with resize in multiple initializations
      // (resizing to n<2 not possible) and there is no fill() method
      for (octave_idx_type i = 0; i < state.nd; i++)
        {
          state.cur(i) = 0;
          state.pd(i) = 1;
        }

      for (octave_idx_type i = 0; i < state.nd - 1; i++)
        {
           state.pd(i + 1) = state.pd(i) * dv(i);
        }

      return 0;
    }
  else
    {
      octave_idx_type nd = state.nd;

      if (nd > 0)
        {
          octave_idx_type ret = 0;

          state.cur(nd - 1)++;

          for (octave_idx_type i = nd - 1; i > 0; i--)
            {
              if (state.cur(i) == dv(i))
                {
                  state.cur(i) = 0;
                  state.cur(i - 1)++;
                }

              ret += state.cur(i) * state.pd(i);
            }

          if (state.cur(0) == dv(0))
            ret = -1; // signals overflow
          else
            ret += state.cur(0) * state.pd(0);

          return ret;
        }
      else
        return -1;
    }
}

int command::from_octave_bin_array (octave_value &oct_arr, oct_pq_dynvec_t &val,
                                    oct_pq_conv_t *conv)
{
  octave_scalar_map m = oct_arr.scalar_map_value ();
  if (error_state)
    {
      error ("%s: Postgresql array parameter no Octave structure",
             caller.c_str ());
      return 1;
    }

  if (! m.isfield ("ndims") || ! m.isfield ("data"))
    {
      error ("%s: field 'ndims' or 'data' missing in parameter for Postgresql array", caller.c_str ());
      return 1;
    }

  octave_idx_type nd_pq = m.contents ("ndims").int_value ();
  Cell arr = m.contents ("data").cell_value ();
  if (error_state || nd_pq < 0)
    {
      error ("%s: 'ndims' and 'data' could not be converted to non-negative integer and cell-array in parameter for Postgresql array", caller.c_str ());
      return 1;
    }

  RowVector lb;

  // Are lbounds given?
  if (m.isfield ("lbounds"))
    {
      lb = m.contents ("lbounds").row_vector_value ();
      if (error_state)
        {
          error ("%s: could not convert given enumeration bases for array to row vector", caller.c_str ());
          return 1;
        }
    }

  octave_idx_type nl = arr.numel ();

  // dimensions of Octaves representation of postgresql array
  dim_vector d = arr.dims ();
  d.chop_trailing_singletons ();
  int nd_oct = d.length ();
  if (nd_oct == 2 && d(1) == 1)
    nd_oct = 1;

  // check dimensions
  if (nd_oct > nd_pq)
    {
      error ("given representation of postgresql array has more dimensions than specified");
      return 1;
    }

  // check lbounds
  if (nd_pq > 0 && lb.is_empty ())
    lb.resize (nd_pq, 1); // fill with 1
  else if (lb.length () != nd_pq)
    {
      error ("number of specified enumeration bases for array does not match specified number of dimensions");
      return 1;
    }

  // ndim
  OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) nd_pq))
  // always make a NULL-bitmap, we don't scan for NULLs to see if it
  // is really necessary
  OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) 1))
  // element OID
  OCT_PQ_PUT(val, uint32_t, htobe32 ((uint32_t) conv->oid))
  // dims, lbounds
  for (int i = 0; i < nd_pq; i++)
    {
      OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) (i < nd_oct ? d(i) : 1)))
      OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) lb(i)))
    }
  // elements
  count_state state;
  count_row_major_order (d, state, true); // initialize counter
  for (int i = 0, ti = 0; ti < nl;
       ti++, i = count_row_major_order (d, state, false))
    {
      if (arr(i).is_real_scalar () && arr(i).isna ().bool_value ())
        // a length value (uint32_t) would not have the 6 highest bits
        // set (while this has all bits set)
        { OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) -1)) }
      else
        {
          OCT_PQ_SET_UINT32_PLACEHOLDER(val, temp_pos)

            if (conv->is_composite)
              {
                if (from_octave_bin_composite (arr(i), val, conv))
                  return 1;
              }
            else
              {
                if (conv->from_octave_bin (arr(i), val))
                  return 1;
              }

          OCT_PQ_FILL_UINT32_PLACEHOLDER(val, temp_pos)
        }
    }

  return 0;
}

int command::from_octave_bin_composite (octave_value &oct_comp,
                                        oct_pq_dynvec_t &val,
                                        oct_pq_conv_t *conv)
{
  Cell rec (oct_comp.cell_value ());
  if (error_state)
    {
      error ("%s: Octaves representation of a composite type could not be converted to cell-array", caller.c_str ());
      return 1;
    }

  octave_idx_type nl = rec.numel ();

  std::vector<Oid> oids;
  if (conn.octave_pq_get_cols (conv->relid, oids))
    return 1;

  if (nl != oids.size ())
    {
      error ("%s: Octaves representation of a composite type has incorrect number of elements (%i, should have %i)", caller.c_str (), nl, oids.size ());
      return 1;
    }

  // ncols
  OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) nl))
  // elements
  for (int i = 0; i < nl; i++)
    {
      // element OID
      OCT_PQ_PUT(val, uint32_t, htobe32 ((uint32_t) oids[i]))
      if (rec(i).is_real_scalar () && rec(i).isna ().bool_value ())
        // a length value (uint32_t) would not have the 6 highest bits
        // set (while this has all bits set)
        { OCT_PQ_PUT(val, int32_t, htobe32 ((int32_t) -1)) }
      else
        {
          OCT_PQ_SET_UINT32_PLACEHOLDER(val, temp_pos)

          oct_pq_conv_t *el_conv;
          oct_type_t oct_type;

          if (! (el_conv = pgtype_from_spec (oids[i], oct_type)))
            return 1;

          switch (oct_type)
            {
            case simple:
              if (el_conv->from_octave_bin (rec(i), val))
                return 1;
              break;

            case array:
              if (from_octave_bin_array (rec(i), val, el_conv))
                return 1;
              break;

            case composite:
              if (from_octave_bin_composite (rec(i), val, el_conv))
                return 1;
              break;

            default:
              // should not get here
              error ("%s: internal error, undefined type identifier",
                     caller.c_str ());
              return 1;
            }

          OCT_PQ_FILL_UINT32_PLACEHOLDER(val, temp_pos)
        }
    }

  return 0;
}

int command::from_octave_str_array (octave_value &oct_arr, oct_pq_dynvec_t &val,
                                    octave_value &type)
{
  // not implemented
  error ("not implemented");
  return 1;

  return 0;
}

int command::from_octave_str_composite (octave_value &oct_comp,
                                        oct_pq_dynvec_t &val,
                                        octave_value &type)
{
  // not implemented
  error ("not implemented");
  return 1;

  return 0;
}

int command::to_octave_bin_array (char *v, octave_value &ov, int nb,
                                  oct_pq_conv_t *conv)
{
  char *p = v;

  // ndim
  OCT_PQ_DECL_GET_INT32(ndim, p, int32_t)
  // has NULL bitmap, this information is not used
  OCT_PQ_DECL_GET_INT32(hasnull, p, int32_t)
  // element OID
  OCT_PQ_DECL_GET_INT32(oid, p, uint32_t)

  // check element OID
  if (oid != conv->oid)
    {
      error ("%s: element oid %i sent by server does not match element oid %i expected for array with oid %i",
             caller.c_str (), oid, conv->oid, conv->aoid);
      return 1;
    }

  // dims, lbounds
  dim_vector dv;
  dv.resize (ndim, 0); // ndim < 2 is treated as ndim == 2
  if (ndim == 1)
    dv(1) = 1;

  RowVector lbounds (ndim);

  for (int i = 0; i < ndim; i++)
    {
      OCT_PQ_GET_INT32(dv(i), p, int32_t)
      OCT_PQ_GET_INT32(lbounds(i), p, int32_t)
    }
  //

  // elements
  octave_idx_type nl = dv.numel ();
  Cell c (dv);
  count_state state;
  count_row_major_order (dv, state, true); // initialize counter
  for (int i = 0, ti = 0; ti < nl;
       ti++, i = count_row_major_order (dv, state, false))
    {
      OCT_PQ_DECL_GET_INT32(null_id, p, int32_t)
      if (null_id == -1)
        // NULL
        c(i) = octave_value (octave_NA);
      else
        {
          uint32_t nb_el = uint32_t (null_id);

          octave_value ov_el;

          if (conv->is_composite)
            {
              if (to_octave_bin_composite (p, ov_el, nb_el))
                return 1;
            }
          else
            {
              if (conv->to_octave_bin (p, ov_el, nb_el))
                return 1;
            }

          p += nb_el;

          c(i) = ov_el;
        }
    }

  octave_scalar_map m;
  m.assign ("data", octave_value (c));
  m.assign ("ndims", octave_value (ndim));
  m.assign ("lbounds", octave_value (lbounds));

  ov = octave_value (m);

  return 0;
}

int command::to_octave_bin_composite (char *v, octave_value &ov, int nb)
{
  char *p = v;

  // ncols
  OCT_PQ_DECL_GET_INT32(nl, p, int32_t)

  // elements
  Cell c (nl, 1);
  for (int i = 0; i < nl; i++)
    {
      // element OID
      OCT_PQ_DECL_GET_INT32(oid, p, uint32_t)

      OCT_PQ_DECL_GET_INT32(null_id, p, int32_t)

      if (null_id == -1)
        // NULL
        c(i) = octave_value (octave_NA);
      else
        {
          uint32_t nb_el = uint32_t (null_id);

          oct_pq_conv_t *el_conv;
          oct_type_t oct_type;

          if (! (el_conv = pgtype_from_spec (oid, oct_type)))
            return 1;

          octave_value el;
          switch (oct_type)
            {
            case simple:
              if (el_conv->to_octave_bin (p, el, nb_el))
                return 1;
              break;

            case array:
              if (to_octave_bin_array (p, el, nb_el, el_conv))
                return 1;
              break;

            case composite:
              if (to_octave_bin_composite (p, el, nb_el))
                return 1;
              break;

            default:
              // should not get here
              error ("%s: internal error, undefined type identifier",
                     caller.c_str ());
              return 1;
            }

          p += nb_el;

          c(i) = el;
        }
    }

  ov = octave_value (c);

  return 0;
}


int command::to_octave_str_array (char *v, octave_value &ov, int nb,
                                  oct_pq_conv_t *conv)
{
  // not implemented
  error ("not implemented");
  return 1;

  return 0;
}

int command::to_octave_str_composite (char *v, octave_value &ov, int nb)
{
  // not implemented
  error ("not implemented");
  return 1;

  return 0;
}
