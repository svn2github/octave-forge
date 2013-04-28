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
#include <octave/ov-float.h>
#include <octave/ov-uint8.h>
#include <octave/Cell.h>

#include <libpq-fe.h>

#include "converters.h"
#include "pq_connection.h"

// remember to adjust OCT_PQ_NUM_CONVERTERS in converters.h

// helper function for debugging
void print_conv (oct_pq_conv_t *c)
{
  printf ("oid: %u, aoid: %u, c: %i, e: %i, nc: %i, n: %s, to_s: %i, to_b: %i, fr_s: %i, fr_b: %i,",
          c->oid, c->aoid, c->is_composite, c->is_enum, c->is_not_constant, c->name.c_str (), c->to_octave_str ? 1 : 0, c->to_octave_bin ? 1 : 0, c->from_octave_str ? 1 : 0, c->from_octave_bin ? 1 : 0);

  printf (", el_oids:");
  for (size_t i = 0; i < c->el_oids.size (); i++)
    printf (" %u", c->el_oids[i]);

  printf ("\n");
}

/* type bool */

int to_octave_str_bool (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  bool tp = (*c == 't' ? true : false);

  ov = octave_value (tp);

  return 0;
}

int to_octave_bin_bool (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = octave_value (bool (*c));

  return 0;
}

int from_octave_str_bool (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  bool b = ov.bool_value ();

  if (error_state)
    {
      error ("can not convert octave_value to bool value");
      return 1;
    }

  val.push_back (b ? '1' : '0');
  val.push_back ('\0');

  return 0;
}

int from_octave_bin_bool (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  bool b = ov.bool_value ();

  if (error_state)
    {
      error ("can not convert octave_value to bool value");
      return 1;
    }

  val.push_back (char (b));

  return 0;
}

oct_pq_conv_t conv_bool = {0, // 16
                           0, // 1000
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "bool",
                           &to_octave_str_bool,
                           &to_octave_bin_bool,
                           &from_octave_str_bool,
                           &from_octave_bin_bool};

/* end type bool */

/* type oid */

int to_octave_str_oid (const octave_pq_connection &conn,
                       const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_oid (const octave_pq_connection &conn,
                       const char *c, octave_value &ov, int nb)
{
  ov = octave_value (octave_uint32 (be32toh (*((uint32_t *) c))));

  return 0;
}

int from_octave_str_oid (const octave_pq_connection &conn,
                         const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_oid (const octave_pq_connection &conn,
                         const octave_value &ov, oct_pq_dynvec_t &val)
{
  uint32_t oid = ov.uint_value ();

  if (error_state)
    {
      error ("can not convert octave_value to oid value");
      return 1;
    }

  OCT_PQ_PUT(val, uint32_t, htobe32 (oid))

  return 0;
}

oct_pq_conv_t conv_oid = {0, // 26
                          0,
                          oct_pq_el_oids_t (),
                          oct_pq_conv_cache_t (),
                          false,
                          false,
                          false,
                          "oid",
                          &to_octave_str_oid,
                          &to_octave_bin_oid,
                          &from_octave_str_oid,
                          &from_octave_bin_oid};

/* end type oid */

/* type float8 */

int to_octave_str_float8 (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  // not implemented

  return 1;
}

int to_octave_bin_float8 (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  union
  {
    double d;
    int64_t i;
  }
  swap;

  swap.i = be64toh (*((int64_t *) c));

  ov = octave_value (swap.d);

  return 0;
}

int from_octave_str_float8 (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  // not implemented

  return 1;
}

int from_octave_bin_float8 (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  union
  {
    double d;
    int64_t i;
  }
  swap;

  swap.d = ov.double_value ();

  if (error_state)
    {
      error ("can not convert octave_value to float8 value");
      return 1;
    }

  OCT_PQ_PUT(val, int64_t, htobe64 (swap.i))

  return 0;
}

oct_pq_conv_t conv_float8 = {0, // 701
                             0, // 1022
                             oct_pq_el_oids_t (),
                             oct_pq_conv_cache_t (),
                             false,
                             false,
                             false,
                             "float8",
                             &to_octave_str_float8,
                             &to_octave_bin_float8,
                             &from_octave_str_float8,
                             &from_octave_bin_float8};

/* end type float8 */

/* type float4 */

int to_octave_str_float4 (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  // not implemented

  return 1;
}

int to_octave_bin_float4 (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  union
  {
    float f;
    int32_t i;
  }
  swap;

  swap.i = be32toh (*((int32_t *) c));

  ov = octave_value (swap.f);

  return 0;
}

int from_octave_str_float4 (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  // not implemented

  return 1;
}

int from_octave_bin_float4 (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  union
  {
    float f;
    int32_t i;
  }
  swap;

  swap.f = ov.float_value ();

  if (error_state)
    {
      error ("can not convert octave_value to float4 value");
      return 1;
    }

  OCT_PQ_PUT(val, int32_t, htobe32 (swap.i))

  return 0;
}

oct_pq_conv_t conv_float4 = {0,
                             0,
                             oct_pq_el_oids_t (),
                             oct_pq_conv_cache_t (),
                             false,
                             false,
                             false,
                             "float4",
                             &to_octave_str_float4,
                             &to_octave_bin_float4,
                             &from_octave_str_float4,
                             &from_octave_bin_float4};

/* end type float4 */

/* type bytea */

int to_octave_str_bytea (const octave_pq_connection &conn,
                         const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_bytea (const octave_pq_connection &conn,
                         const char *c, octave_value &ov, int nb)
{
  uint8NDArray m (dim_vector (nb, 1));

  uint8_t *p = (uint8_t *) m.fortran_vec ();
  for (octave_idx_type i = 0; i < nb; i++)
    *(p++) = uint8_t (*(c++));

  ov = octave_value (m);

  return 0;
}

int from_octave_str_bytea (const octave_pq_connection &conn,
                           const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_bytea (const octave_pq_connection &conn,
                           const octave_value &ov, oct_pq_dynvec_t &val)
{
  uint8NDArray b = ov.uint8_array_value ();

  if (! error_state)
    {
      dim_vector dv = b.dims ();
      if (dv.length () > 2 || (dv(0) > 1 && dv(1) > 1))
        error ("bytea representation must be one-dimensional");
    }

  if (error_state)
    {
      error ("can not convert octave_value to bytea representation");
      return 1;
    }

  octave_idx_type nl = b.numel ();

  for (int i = 0; i < nl; i++)
    val.push_back (b(i).value ());

  return 0;
}

oct_pq_conv_t conv_bytea = {0,
                            0,
                            oct_pq_el_oids_t (),
                            oct_pq_conv_cache_t (),
                            false,
                            false,
                            false,
                            "bytea",
                            &to_octave_str_bytea,
                            &to_octave_bin_bytea,
                            &from_octave_str_bytea,
                            &from_octave_bin_bytea};

/* end type bytea */

/* type text */

int to_octave_str_text (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_text (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  std::string s (c, nb);

  ov = octave_value (s);

  return 0;
}

int from_octave_str_text (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_text (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  std::string s = ov.string_value ();

  if (error_state)
    {
      error ("can not convert octave_value to string");
      return 1;
    }

  octave_idx_type l = s.size ();

  for (int i = 0; i < l; i++)
    val.push_back (s[i]);

  return 0;
}

oct_pq_conv_t conv_text = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "text",
                           &to_octave_str_text,
                           &to_octave_bin_text,
                           &from_octave_str_text,
                           &from_octave_bin_text};

/* end type text */

/* type varchar */

oct_pq_conv_t conv_varchar = {0,
                              0,
                              oct_pq_el_oids_t (),
                              oct_pq_conv_cache_t (),
                              false,
                              false,
                              false,
                              "varchar",
                              &to_octave_str_text,
                              &to_octave_bin_text,
                              &from_octave_str_text,
                              &from_octave_bin_text};

/* end type varchar */

/* type bpchar */

oct_pq_conv_t conv_bpchar = {0,
                             0,
                             oct_pq_el_oids_t (),
                             oct_pq_conv_cache_t (),
                             false,
                             false,
                             false,
                             "bpchar",
                             &to_octave_str_text,
                             &to_octave_bin_text,
                             &from_octave_str_text,
                             &from_octave_bin_text};

/* end type bpchar */

/* type name */

oct_pq_conv_t conv_name = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "name",
                           &to_octave_str_text,
                           &to_octave_bin_text,
                           &from_octave_str_text,
                           &from_octave_bin_text};

/* end type name */

/* type int2 */

int to_octave_str_int2 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_int2 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = octave_value (octave_int16 (int16_t (be16toh (*((int16_t *) c)))));

  return 0;
}

int from_octave_str_int2 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_int2 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  int16_t i2 = ov.int_value ();

  if (error_state)
    {
      error ("can not convert octave_value to int2 value");
      return 1;
    }

  OCT_PQ_PUT(val, int16_t, htobe16 (i2))

  return 0;
}

oct_pq_conv_t conv_int2 = {0, // 26
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "int2",
                           &to_octave_str_int2,
                           &to_octave_bin_int2,
                           &from_octave_str_int2,
                           &from_octave_bin_int2};


/* end type int2 */

/* type int4 */

int to_octave_str_int4 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_int4 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = octave_value (octave_int32 (int32_t (be32toh (*((int32_t *) c)))));

  return 0;
}

int from_octave_str_int4 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_int4 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  int32_t i4 = ov.int_value ();

  if (error_state)
    {
      error ("can not convert octave_value to int4 value");
      return 1;
    }

  OCT_PQ_PUT(val, int32_t, htobe32 (i4))

  return 0;
}

oct_pq_conv_t conv_int4 = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "int4",
                           &to_octave_str_int4,
                           &to_octave_bin_int4,
                           &from_octave_str_int4,
                           &from_octave_bin_int4};


/* end type int4 */

/* type int8 */

int to_octave_str_int8 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_int8 (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = octave_value (octave_int64 (int64_t (be64toh (*((int64_t *) c)))));

  return 0;
}

int from_octave_str_int8 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_int8 (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  int64_t i8 = ov.int64_scalar_value ();

  if (error_state)
    {
      error ("can not convert octave_value to int8 value");
      return 1;
    }

  OCT_PQ_PUT(val, int64_t, htobe64 (i8))

  return 0;
}

oct_pq_conv_t conv_int8 = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "int8",
                           &to_octave_str_int8,
                           &to_octave_bin_int8,
                           &from_octave_str_int8,
                           &from_octave_bin_int8};


/* end type int8 */

/* type money */

oct_pq_conv_t conv_money = {0,
                            0,
                            oct_pq_el_oids_t (),
                            oct_pq_conv_cache_t (),
                            false,
                            false,
                            false,
                            "money",
                            &to_octave_str_int8,
                            &to_octave_bin_int8,
                            &from_octave_str_int8,
                            &from_octave_bin_int8};

/* end type money */

// helpers for time types

static inline octave_value time_8byte_to_octave (const char *c,
                                                 const bool &int_dt)
{
  if (int_dt)
    {
      return octave_value (octave_int64 (int64_t (be64toh (*((int64_t *) c)))));
    }
  else
    {
      union
      {
        double d;
        int64_t i;
      }
      swap;

      swap.i = be64toh (*((int64_t *) c));

      return octave_value (swap.d);
    }
}

static inline int time_8byte_from_octave (const octave_value &ov,
                                          oct_pq_dynvec_t &val,
                                          const bool &int_dt)
{
  if (int_dt)
    {
      // don't convert automatically because of possible overflow
      if (ov.is_float_type ())
        {
          error ("floating point octave_value provided for 8-byte time value, but postgresql is configured for int64");
          return 1;
        }

      int64_t i8 = ov.int64_scalar_value ();

      if (error_state)
        {
          error ("can not convert octave_value to int64 time value");
          return 1;
        }

      OCT_PQ_PUT(val, int64_t, htobe64 (i8))

      return 0;
    }
  else
    {
      // don't convert automatically because of possible loss of accuracy
      if (ov.is_integer_type ())
        {
          error ("integer type octave_value provided for 8-byte time value, but postgresql is configured for double");
          return 1;
        }

      union
      {
        double d;
        int64_t i;
      }
      swap;

      swap.d = ov.double_value ();

      if (error_state)
        {
          error ("can not convert octave_value to double time value");
          return 1;
        }

      OCT_PQ_PUT(val, int64_t, htobe64 (swap.i))

      return 0;
    }
}

// end helpers for time types

/* type timestamp */

int to_octave_str_timestamp (const octave_pq_connection &conn,
                             const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_timestamp (const octave_pq_connection &conn,
                             const char *c, octave_value &ov, int nb)
{
  ov = time_8byte_to_octave (c, conn.get_integer_datetimes ());

  return 0;
}

int from_octave_str_timestamp (const octave_pq_connection &conn,
                               const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_timestamp (const octave_pq_connection &conn,
                               const octave_value &ov, oct_pq_dynvec_t &val)
{
  return (time_8byte_from_octave (ov, val, conn.get_integer_datetimes ()));
}

oct_pq_conv_t conv_timestamp = {0,
                                0,
                                oct_pq_el_oids_t (),
                                oct_pq_conv_cache_t (),
                                false,
                                false,
                                false,
                                "timestamp",
                                &to_octave_str_timestamp,
                                &to_octave_bin_timestamp,
                                &from_octave_str_timestamp,
                                &from_octave_bin_timestamp};

/* end type timestamp */

/* type timestamptz */

oct_pq_conv_t conv_timestamptz = {0,
                                  0,
                                  oct_pq_el_oids_t (),
                                  oct_pq_conv_cache_t (),
                                  false,
                                  false,
                                  false,
                                  "timestamptz",
                                  &to_octave_str_timestamp,
                                  &to_octave_bin_timestamp,
                                  &from_octave_str_timestamp,
                                  &from_octave_bin_timestamp};

/* end type timestamptz */

/* type interval */

int to_octave_str_interval (const octave_pq_connection &conn,
                            const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_interval (const octave_pq_connection &conn,
                            const char *c, octave_value &ov, int nb)
{
  Cell tp (dim_vector (3, 1));

  tp(0) = time_8byte_to_octave (c, conn.get_integer_datetimes ());

  c += 8;

  tp(1) = octave_value (octave_int32 (int32_t (be32toh (*((int32_t *) c)))));

  c += 4;

  tp(2) = octave_value (octave_int32 (int32_t (be32toh (*((int32_t *) c)))));

  ov = octave_value (tp);

  return 0;
}

int from_octave_str_interval (const octave_pq_connection &conn,
                              const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_interval (const octave_pq_connection &conn,
                              const octave_value &ov, oct_pq_dynvec_t &val)
{
  Cell iv = ov.cell_value ();
  if (error_state || iv.numel () != 3)
    {
      error ("interval: can not convert octave_value to cell with 3 elements");
      return 1;
    }

  if (time_8byte_from_octave (iv(0), val, conn.get_integer_datetimes ()))
    return 1;

  for (int id = 1; id < 3; id++)
    {
      int32_t i4 = iv(id).int_value ();

      if (error_state)
        {
          error ("interval: can not convert octave_value to int4 value");
          return 1;
        }

      OCT_PQ_PUT(val, int32_t, htobe32 (i4))
    }

  return 0;
}

oct_pq_conv_t conv_interval = {0,
                               0,
                               oct_pq_el_oids_t (),
                               oct_pq_conv_cache_t (),
                               false,
                               false,
                               false,
                               "interval",
                               &to_octave_str_interval,
                               &to_octave_bin_interval,
                               &from_octave_str_interval,
                               &from_octave_bin_interval};

/* end type interval */

/* type time */

int to_octave_str_time (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_time (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = time_8byte_to_octave (c, conn.get_integer_datetimes ());

  return 0;
}

int from_octave_str_time (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_time (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return (time_8byte_from_octave (ov, val, conn.get_integer_datetimes ()));
}

oct_pq_conv_t conv_time = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "time",
                           &to_octave_str_time,
                           &to_octave_bin_time,
                           &from_octave_str_time,
                           &from_octave_bin_time};

/* end type time */

/* type timetz */

int to_octave_str_timetz (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_timetz (const octave_pq_connection &conn,
                          const char *c, octave_value &ov, int nb)
{
  Cell tp (dim_vector (2, 1));

  tp(0) = time_8byte_to_octave (c, conn.get_integer_datetimes ());

  c += 8;

  tp(1) = octave_value (octave_int32 (int32_t (be32toh (*((int32_t *) c)))));

  ov = octave_value (tp);

  return 0;
}

int from_octave_str_timetz (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_timetz (const octave_pq_connection &conn,
                            const octave_value &ov, oct_pq_dynvec_t &val)
{
  Cell iv = ov.cell_value ();
  if (error_state || iv.numel () != 2)
    {
      error ("timetz: can not convert octave_value to cell with 2 elements");
      return 1;
    }

  if (time_8byte_from_octave (iv(0), val, conn.get_integer_datetimes ()))
    return 1;

  int32_t i4 = iv(1).int_value ();

  if (error_state)
    {
      error ("timetz: can not convert octave_value to int4 value");
      return 1;
    }

  OCT_PQ_PUT(val, int32_t, htobe32 (i4))

  return 0;
}

oct_pq_conv_t conv_timetz = {0,
                             0,
                             oct_pq_el_oids_t (),
                             oct_pq_conv_cache_t (),
                             false,
                             false,
                             false,
                             "timetz",
                             &to_octave_str_timetz,
                             &to_octave_bin_timetz,
                             &from_octave_str_timetz,
                             &from_octave_bin_timetz};

/* end type timetz */

/* type date */

int to_octave_str_date (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  return 1;
}

int to_octave_bin_date (const octave_pq_connection &conn,
                        const char *c, octave_value &ov, int nb)
{
  ov = octave_value (octave_int32 (int32_t (be32toh (*((int32_t *) c)))));

  return 0;
}

int from_octave_str_date (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  return 1;
}

int from_octave_bin_date (const octave_pq_connection &conn,
                          const octave_value &ov, oct_pq_dynvec_t &val)
{
  int32_t i4 = ov.int_value ();

  if (error_state)
    {
      error ("date: can not convert octave_value to int4 value");
      return 1;
    }

  OCT_PQ_PUT(val, int32_t, htobe32 (i4))

  return 0;
}

oct_pq_conv_t conv_date = {0,
                           0,
                           oct_pq_el_oids_t (),
                           oct_pq_conv_cache_t (),
                           false,
                           false,
                           false,
                           "date",
                           &to_octave_str_date,
                           &to_octave_bin_date,
                           &from_octave_str_date,
                           &from_octave_bin_date};


/* end type date */

oct_pq_conv_t *t_conv_ptrs[OCT_PQ_NUM_CONVERTERS] = {&conv_bool,
                                                     &conv_oid,
                                                     &conv_float8,
                                                     &conv_float4,
                                                     &conv_text,
                                                     &conv_varchar,
                                                     &conv_bpchar,
                                                     &conv_name,
                                                     &conv_bytea,
                                                     &conv_int2,
                                                     &conv_int4,
                                                     &conv_int8,
                                                     &conv_money,
                                                     &conv_timestamp,
                                                     &conv_timestamptz,
                                                     &conv_interval,
                                                     &conv_time,
                                                     &conv_timetz,
                                                     &conv_date};

oct_pq_conv_ptrs_t conv_ptrs (OCT_PQ_NUM_CONVERTERS, t_conv_ptrs);
