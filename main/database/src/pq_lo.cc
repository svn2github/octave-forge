/*

Copyright (C) 2013 Olaf Till <i7tiol@t-online.de>

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

#include "command.h"
#include <postgresql/libpq/libpq-fs.h>

// PKG_ADD: autoload ("pq_lo_import", "pq_interface.oct");
// PKG_ADD: autoload ("pq_lo_export", "pq_interface.oct");
// PKG_ADD: autoload ("pq_lo_unlink", "pq_interface.oct");


DEFUN_DLD (pq_lo_import, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{oid}} pq_lo_import (@var{connection}, @var{path})\n\
Imports the file in @var{path} on the client side as a large object into the database associated with @var{connection} and returns the Oid of the new large object.\n\
@end deftypefn")
{
  std::string fname ("pq_lo_import");

  octave_value retval;

  if (args.length () != 2 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return retval;
    }

  std::string path (args(1).string_value ());

  if (error_state)
    {
      error ("%s: second argument can not be converted to a string",
             fname.c_str ());

      return retval;
    }

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);

  PGconn *conn = oct_pq_conn.octave_pq_get_conn ();

  if (! conn)
    {
      error ("%s: connection not open", fname.c_str ());
      return retval;
    }

  bool make_tblock = false;
  switch (PQtransactionStatus (conn))
    {
    case PQTRANS_IDLE:
      make_tblock = true;
      break;
    case PQTRANS_INTRANS:
      break;
    case PQTRANS_INERROR:
      error ("%s: can't manipulate large objects within a failed transaction block",
             fname.c_str ());
      break;
    case PQTRANS_UNKNOWN:
      error ("%s: connection is bad", fname.c_str ());
      break;
    default: // includes PQTRANS_ACTIVE
      error ("%s: unexpected connection state", fname.c_str ());
    }

  if (error_state)
    return retval;

  if (make_tblock)
    {
      std::string cmd ("begin;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        {
          error ("%s: could not begin transaction", fname.c_str ());
          return retval;
        }
    }

  Oid oid;

  bool import_error = false;
  std::string msg;

  if (! (oid = lo_import (conn, path.c_str ())))
    {
      import_error = true;
      msg = PQerrorMessage (conn);
    }

  // if we started the transaction, commit it even in case of import failure
  bool commit_error = false;
  if (make_tblock)
    {
      std::string cmd ("commit;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        commit_error = true;
    }

  if (import_error)
    error ("%s: large object import failed: %s", fname.c_str (), msg.c_str ());

  if (commit_error)
    error ("%s: could not commit transaction", fname.c_str ());

  if (error_state)
    return retval;

  retval = octave_value (octave_uint32 (oid));

  return retval;
}


DEFUN_DLD (pq_lo_export, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} pq_lo_export (@var{connection}, @var{oid}, @var{path})\n\
Exports the large object of Oid @var{oid} in the database associated with @var{connection} to the file @var{path} on the client side.\n\
@end deftypefn")
{
  std::string fname ("pq_lo_export");

  octave_value retval;

  if (args.length () != 3 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return retval;
    }

  std::string path (args(2).string_value ());

  if (error_state)
    {
      error ("%s: third argument can not be converted to a string",
             fname.c_str ());

      return retval;
    }

  Oid oid = args(1).uint_value ();

  if (error_state)
    {
      error ("%s: second argument can not be converted to an oid",
             fname.c_str ());

      return retval;
    }

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);

  PGconn *conn = oct_pq_conn.octave_pq_get_conn ();

  if (! conn)
    {
      error ("%s: connection not open", fname.c_str ());
      return retval;
    }

  bool make_tblock = false;
  switch (PQtransactionStatus (conn))
    {
    case PQTRANS_IDLE:
      make_tblock = true;
      break;
    case PQTRANS_INTRANS:
      break;
    case PQTRANS_INERROR:
      error ("%s: can't manipulate large objects within a failed transaction block",
             fname.c_str ());
      break;
    case PQTRANS_UNKNOWN:
      error ("%s: connection is bad", fname.c_str ());
      break;
    default: // includes PQTRANS_ACTIVE
      error ("%s: unexpected connection state", fname.c_str ());
    }

  if (error_state)
    return retval;

  if (make_tblock)
    {
      std::string cmd ("begin;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        {
          error ("%s: could not begin transaction", fname.c_str ());
          return retval;
        }
    }

  bool export_error = false;
  std::string msg;

  if (lo_export (conn, oid, path.c_str ()) == -1)
    {
      export_error = true;
      msg = PQerrorMessage (conn);
    }

  // if we started the transaction, commit it even in case of export failure
  bool commit_error = false;
  if (make_tblock)
    {
      std::string cmd ("commit;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        commit_error = true;
    }

  if (export_error)
    error ("%s: large object export failed: %s", fname.c_str (), msg.c_str ());

  if (commit_error)
    error ("%s: could not commit transaction", fname.c_str ());

  return retval;
}


DEFUN_DLD (pq_lo_unlink, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} pq_lo_unlink (@var{connection}, @var{oid})\n\
Removes the large object of Oid @var{oid} from the database associated with @var{connection}.\n\
@end deftypefn")
{
  std::string fname ("pq_lo_unlink");

  octave_value retval;

  if (args.length () != 2 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return retval;
    }

  Oid oid = args(1).uint_value ();

  if (error_state)
    {
      error ("%s: second argument can not be converted to an oid",
             fname.c_str ());

      return retval;
    }

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);

  PGconn *conn = oct_pq_conn.octave_pq_get_conn ();

  if (! conn)
    {
      error ("%s: connection not open", fname.c_str ());
      return retval;
    }

  bool make_tblock = false;
  switch (PQtransactionStatus (conn))
    {
    case PQTRANS_IDLE:
      make_tblock = true;
      break;
    case PQTRANS_INTRANS:
      break;
    case PQTRANS_INERROR:
      error ("%s: can't manipulate large objects within a failed transaction block",
             fname.c_str ());
      break;
    case PQTRANS_UNKNOWN:
      error ("%s: connection is bad", fname.c_str ());
      break;
    default: // includes PQTRANS_ACTIVE
      error ("%s: unexpected connection state", fname.c_str ());
    }

  if (error_state)
    return retval;

  if (make_tblock)
    {
      std::string cmd ("begin;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        {
          error ("%s: could not begin transaction", fname.c_str ());
          return retval;
        }
    }

  bool unlink_error = false;
  std::string msg;

  if (lo_unlink (conn, oid) == -1)
    {
      unlink_error = true;
      msg = PQerrorMessage (conn);
    }

  // if we started the transaction, commit it even in case of unlink failure
  bool commit_error = false;
  if (make_tblock)
    {
      std::string cmd ("commit;");
      Cell params;
      Cell ptypes (1, 0);
      Cell rtypes;
      command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

      if (c.good ())
        c.process_single_result ();

      if (! c.good ())
        commit_error = true;
    }

  if (unlink_error)
    error ("%s: large object unlink failed: %s", fname.c_str (), msg.c_str ());

  if (commit_error)
    error ("%s: could not commit transaction", fname.c_str ());

  return retval;
}
