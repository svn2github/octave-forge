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

#ifndef __OCT_PQ_CONNECTION__

#define __OCT_PQ_CONNECTION__

#include <octave/oct.h>

#include <libpq-fe.h>

#include "converters.h"

class
octave_pq_connection : public octave_base_value
{
public:

  octave_pq_connection (std::string);

  ~octave_pq_connection (void);

  void octave_pq_close (void);

  int octave_pq_refresh_types (void);

  PGconn *octave_pq_get_conn (void) { return conn; }

  oct_pq_conv_map_t conv_map;

  oct_pq_name_conv_map_t name_conv_map;

  const bool &get_integer_datetimes (void) const { return integer_datetimes; }


  // Octave internal stuff

  bool is_constant (void) const { return true; }

  bool is_defined (void) const { return true; }

  bool is_true (void) const { return conn != 0; }

  void print_raw (std::ostream& os, bool pr_as_read_syntax = false) const
  {
    indent (os);
    os << "<PGconn object>";
    newline (os);
  }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const
  {
    print_raw (os);
  }

  bool print_as_scalar (void) const { return true; }

private:

  // needed by Octave for register_type()
  octave_pq_connection (void) : conn (NULL) { }

  PGconn *conn;

  // Oid of postgres_user, needed to distinguish base types from
  // others.
  octave_value postgres;

  void octave_pq_delete_non_constant_types (void);

  // returns zero on success
  int octave_pq_get_postgres_oid (void);

  // returns zero on success
  int octave_pq_fill_base_types (void);

  // returns zero on success
  int octave_pq_get_composite_types (void);

  // returns zero on success
  int octave_pq_get_enum_types (void);

  // server configuration
  bool integer_datetimes;

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif // __OCT_PQ_CONNECTION__
