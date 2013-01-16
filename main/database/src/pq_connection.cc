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

#include "pq_connection.h"
#include "command.h"

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_pq_connection, "PGconn", "PGconn")

octave_pq_connection::octave_pq_connection (std::string arg)
: postgres (0), conv_map (), name_conv_map (&map_str_cmp)
{
  static bool type_registered = false;

  if (! type_registered) register_type ();

  conn = PQconnectdb (arg.c_str ());

  if (! conn || PQstatus (conn) == CONNECTION_BAD)
    {
      if (conn)
        {
          PQfinish (conn);

          conn = NULL;
        }

      error ("PQ connection attempt failed");
    }
  else
    {
      // init name converter-map (kind of "bootstrapping")
      for (int i = 0; i < OCT_PQ_NUM_CONVERTERS; i++)
        name_conv_map[conv_ptrs[i]->name.c_str ()] = conv_ptrs[i];

      if (octave_pq_get_postgres_oid () ||
          octave_pq_fill_base_types () ||
          octave_pq_get_composite_types () ||
          octave_pq_get_enum_types ())
        {
          PQfinish (conn);

          conn = NULL;

          error ("could not read types");
        }
    }
}

octave_pq_connection::~octave_pq_connection (void)
{
  if (conn)
    {
      PQfinish (conn);

      octave_pq_delete_non_constant_types ();
    }
}

void octave_pq_connection::octave_pq_close (void)
{
  if (conn)
    {
      PQfinish (conn);

      octave_pq_delete_non_constant_types ();

      conn = NULL;
    }
  else
    error ("PGconn object not open");
}

void octave_pq_connection::octave_pq_delete_non_constant_types (void)
{
  // In the first map, allocated types are usually referenced twice
  // (by oid and aoid). Yet we need no refcount as long as we go
  // through the name map as the last, since there (the same) types
  // are only referenced once.

  std::vector<oct_pq_conv_map_t::iterator> t_it_v;

  for (oct_pq_conv_map_t::iterator it = conv_map.begin ();
       it != conv_map.end ();
       it++)
    if (it->second->is_not_constant)
      t_it_v.push_back (it);

  for (std::vector<oct_pq_conv_map_t::iterator>::iterator it = t_it_v.begin ();
       it != t_it_v.end (); it++)
    conv_map.erase (*it);

  std::vector<oct_pq_name_conv_map_t::iterator> t_name_it_v;

  for (oct_pq_name_conv_map_t::iterator it = name_conv_map.begin ();
       it != name_conv_map.end ();
       it++)
    {
      oct_pq_conv_t *conv = it->second;

      if (conv->is_not_constant)
        {
          t_name_it_v.push_back (it);

          delete conv;
        }
    }

  for (std::vector<oct_pq_name_conv_map_t::iterator>::iterator it =
         t_name_it_v.begin ();
       it != t_name_it_v.end (); it++)
    name_conv_map.erase (*it);
}

int octave_pq_connection::octave_pq_get_postgres_oid (void)
{
  Cell p, pt, rt (1, 1);

  rt(0) = octave_value ("oid");

  std::string cmd ("select oid from pg_roles where rolname = 'postgres';"),
    caller ("octave_pq_get_postgres_oid");

  command c (*this, cmd, p, pt, rt, caller);
  if (! c.good ())
    {
      error ("could not read pg_roles");
      return 1;
    }

  octave_value res = c.process_single_result ();
  if (error_state)
    return 1;

  postgres = res.scalar_map_value ().contents ("data").cell_value ()(0).
    int_value ();
  if (error_state)
    return 1;

  return 0;
}

int octave_pq_connection::octave_pq_fill_base_types (void)
{
  // assert postgres oid had been determined
  if (! postgres.int_value ()) return 1;

  Cell p (1, 1), pt (1, 1), rt (3, 1);
  p(0) = postgres;
  pt(0) = octave_value ("oid");
  rt(0) = octave_value ("oid");
  rt(1) = octave_value ("name");
  rt(2) = octave_value ("oid");

  std::string cmd ("select oid, typname, typarray from pg_type where (typowner = $1 AND typtype = 'b' AND typarray != 0) OR typname = 'record';"),
    caller ("octave_pq_fill_base_types");

  command c (*this, cmd, p, pt, rt, caller);
  if (! c.good ())
    {
      error ("octave_pq_fill_base_types: could not read pg_type");
      return 1;
    }

  octave_value res = c.process_single_result ();
  if (error_state)
    return 1;

  Cell tpls = res.scalar_map_value ().contents ("data").cell_value ();
  if (error_state)
    {
      error
        ("octave_pq_fill_base_types: could not convert result data to cell");
      return 1;
    }

  // make a temporary map of server base types (cell row numbers) for searching
  typedef std::map<std::string, int, bool (*) (const std::string &,
                                               const std::string &)>
    bt_map_t;
  bt_map_t bt_map (&map_string_cmp);
  for (int i = 0; i < tpls.rows (); i++)
    bt_map[tpls(i, 1).string_value ()] = i;
  if (error_state)
    {
      error ("octave_pq_fill_base_types: could not read returned result");
      return 1;
    }

  for (int i = 0; i < OCT_PQ_NUM_CONVERTERS; i++)
    {
      bt_map_t::iterator bt_it;
      if ((bt_it = bt_map.find (conv_ptrs[i]->name)) == bt_map.end ())
        {
          error ("octave_pq_fill_base_types: type %s not found in pg_types",
                 conv_ptrs[i]->name.c_str ());
          return 1;
        }
      // fill in oid and aoid into static records of converters
      conv_ptrs[i]->oid = tpls(bt_it->second, 0).int_value ();
      conv_ptrs[i]->aoid = tpls(bt_it->second, 2).int_value ();

      // fill in map of converters over oid with oid and, if not zero,
      // also with aoid
      conv_map[conv_ptrs[i]->oid] = conv_ptrs[i];
      if (conv_ptrs[i]->aoid != 0)
        conv_map[conv_ptrs[i]->aoid] = conv_ptrs[i];
    }
  if (error_state)
    {
      error ("octave_pq_fill_base_types: could not read returned result");
      return 1;
    }

  return 0;
}

int octave_pq_connection::octave_pq_get_composite_types (void)
{
  Cell p, pt, rt (4, 1);
  rt(0) = octave_value ("oid");
  rt(1) = octave_value ("name");
  rt(2) = octave_value ("oid");
  rt(3) = octave_value ("oid");

  std::string cmd ("select oid, typname, typarray, typrelid from pg_type where typtype = 'c';"),
    caller ("octave_pq_get_composite_types");

  command c (*this, cmd, p, pt, rt, caller);
  if (! c.good ())
    {
      error ("octave_pq_get_composite_types: could not read pg_type");
      return 1;
    }

  octave_value res = c.process_single_result ();
  if (error_state)
    return 1;

  Cell tpls = res.scalar_map_value ().contents ("data").cell_value ();
  if (error_state)
    {
      error ("octave_pq_get_composite_types: could not convert result data to cell");
      return 1;
    }

  for (int i = 0; i < tpls.rows (); i++)
    {
      Oid oid = tpls(i, 0).int_value ();
      Oid aoid = tpls(i, 2).int_value ();
      Oid relid = tpls(i, 3).int_value ();
      std::string name = tpls(i, 1).string_value ();
      if (error_state)
        {
          error ("octave_pq_get_composite_types: could not read returned result");
          return 1;
        }

      // must be allocated and filled before creating the name map
      // entry, to get a remaining location for the c-string used as
      // key
      oct_pq_conv_t *t_conv = new oct_pq_conv_t;
      t_conv->oid = oid;
      t_conv->aoid = aoid;
      t_conv->relid = relid;
      t_conv->is_composite = true;
      t_conv->is_enum = false;
      t_conv->is_not_constant = true;
      t_conv->name = name;
      t_conv->to_octave_str = NULL;
      t_conv->to_octave_bin = NULL;
      t_conv->from_octave_str = NULL;
      t_conv->from_octave_bin = NULL;

      oct_pq_conv_t *&by_oid = conv_map[oid],
        *&by_name = name_conv_map[t_conv->name.c_str ()];
      if (by_oid || by_name)
        {
          error ("octave_pq_get_composite_types: internal error, key already in typemap (by_oid: %u/%li, by name: %s/%li)",
                 oid, by_oid, t_conv->name.c_str (), by_name);
          if (! by_oid) conv_map.erase (oid);
          if (! by_name) name_conv_map.erase (t_conv->name.c_str ());
          delete t_conv;
          return 1;
        }

      by_oid = by_name = t_conv;

      if (aoid)
        {
          oct_pq_conv_t *&by_aoid = conv_map[aoid];
          if (by_aoid)
            {
              error ("octave_pq_get_composite_types: internal error, aoid key %u already in typemap", aoid);
              conv_map.erase (oid);
              name_conv_map.erase (t_conv->name.c_str ());
              delete t_conv;
              return 1;
            }

          by_aoid = by_oid;
        }

    }

  return 0;
}

int octave_pq_connection::octave_pq_get_enum_types (void)
{
  Cell p, pt, rt (3, 1);
  rt(0) = octave_value ("oid");
  rt(1) = octave_value ("name");
  rt(2) = octave_value ("oid");

  std::string cmd ("select oid, typname, typarray from pg_type where typtype = 'e';"),
    caller ("octave_pq_get_enum_types");

  command c (*this, cmd, p, pt, rt, caller);
  if (! c.good ())
    {
      error ("octave_pq_get_enum_types: could not read pg_type");
      return 1;
    }
 
  octave_value res = c.process_single_result ();
  if (error_state)
    return 1;

  Cell tpls = res.scalar_map_value ().contents ("data").cell_value ();
  if (error_state)
    {
      error ("octave_pq_get_enum_types: could not convert result data to cell");
      return 1;
    }

  for (int i = 0; i < tpls.rows (); i++)
    {
      Oid oid = tpls(i, 0).int_value ();
      Oid aoid = tpls(i, 2).int_value ();
      std::string name = tpls(i, 1).string_value ();
      if (error_state)
        {
          error ("octave_pq_get_enum_types: could not read returned result");
          return 1;
        }

      // must be allocated and filled before creating the name map
      // entry, to get a remaining location for the c-string used as
      // key
      oct_pq_conv_t *t_conv = new oct_pq_conv_t;
      t_conv->oid = oid;
      t_conv->aoid = aoid;
      t_conv->relid = 0;
      t_conv->is_composite = false;
      t_conv->is_enum = true;
      t_conv->is_not_constant = true;
      t_conv->name = name;
      t_conv->to_octave_str = NULL;
      t_conv->to_octave_bin = NULL;
      t_conv->from_octave_str = NULL;
      t_conv->from_octave_bin = NULL;

      // we trust there is always an array type in the table
      oct_pq_conv_t *&by_oid = conv_map[oid], *&by_aoid = conv_map[aoid],
        *&by_name = name_conv_map[t_conv->name.c_str ()];
      if (by_oid || by_aoid || by_name)
        {
          error ("octave_pq_get_enum_types: internal error, key already in typemap");
          if (! by_oid) conv_map.erase (oid);
          if (! by_aoid) conv_map.erase (aoid);
          if (! by_name) name_conv_map.erase (t_conv->name.c_str ());
          delete t_conv;
          return 1;
        }

      by_oid = by_aoid = by_name = t_conv;

    }

  return 0;
}

int octave_pq_connection::octave_pq_refresh_types (void)
{
  octave_pq_delete_non_constant_types ();

  if (octave_pq_get_composite_types () || octave_pq_get_enum_types ())
    {
      if (conn)
        PQfinish (conn);
      conn = NULL;
      error ("octave_pq_refresh_types: could not read types");
      return 1;
    }
  else
    return 0;
}

int octave_pq_connection::octave_pq_get_cols (Oid relid, std::vector<Oid> &oids)
{
  // printf ("octave_pq_get_cols(relid %u): ", relid);

  Cell p (1, 1), pt (1, 1), rt (2, 1);
  p(0) = octave_value (octave_uint32 (relid));
  pt(0) = octave_value ("oid");
  rt(0) = octave_value ("oid");
  rt(1) = octave_value ("int2");

  std::string cmd ("select atttypid, attnum from pg_attribute where attrelid = $1;"),
    caller ("octave_pq_get_cols");

  command c (*this, cmd, p, pt, rt, caller);
  if (! c.good ())
    {
      error ("%s: could not read pg_type", caller.c_str ());
      return 1;
    }

  octave_value res = c.process_single_result ();
  if (error_state)
    return 1;

  Cell tpls = res.scalar_map_value ().contents ("data").cell_value ();
  if (error_state)
    {
      error
        ("%s: could not convert result data to cell", caller.c_str ());
      return 1;
    }

  octave_idx_type r = tpls.rows ();

  // printf ("%i colums, ", r);

  oids.resize (r);

  // "column" number (attnum) is one-based, so subtract 1
  for (octave_idx_type i = 0; i < r; i++)
    {
      octave_idx_type pos = tpls(i, 1).idx_type_value () - 1;

      // printf ("%u at pos %i, ", tpls(i, 0).uint_value (), pos);

      if (pos >= r)
        {
          error ("%s: internal error (?system catalog erroneous?): column position %i greater than ncols %i for relid %u",
                 caller.c_str (), pos, r, relid);
          return 1;
        }

      oids[pos] = tpls(i, 0).uint_value ();
    }
  if (error_state)
    {
      error ("%s: could not convert result data", caller.c_str ());
      return 1;
    }

  // printf ("\n");

  return 0;
}
