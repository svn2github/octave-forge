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
#include <octave/parse.h>
#include <octave/ov-struct.h>
#include <octave/Cell.h>

#include "command.h"

// PKG_disabled_ADD: autoload ("pq_exec", "pq_interface.oct");
// PKG_disabled_DEL: autoload ("pq_exec", "pq_interface.oct", "remove");
// PKG_ADD: autoload ("__pq_exec_params__", "pq_interface.oct");
// PKG_DEL: autoload ("__pq_exec_params__", "pq_interface.oct", "remove");


#if 0

// I left this here because of its (formerly working) functionality of
// reading more than one result. But the code (and the helptext, too)
// has not been adapted to general changes and is not working, and it
// would need converters for text mode to be useful. Anyway I don't
// see why one should need to execute many commands with one line,
// except if one wants to use some unchanged external SQL code. I'll
// probably wait till someone expresses such a need.

DEFUN_DLD (pq_exec, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{id}} pq_exec (@var{connection}, @var{command})\n\
@deftypefnx {Loadable Function} {@var{id}} pq_exec (@var{connection}, @var{command}, @var{copydata}, @dots{})\n\
Sends the string @var{command}, which should contain one or more SQL commands, over the connection @var{connection} and returns multiple output values, one for each command. For queries (commands potentially returning data), the output will be a structure with fields @code{data} (containing a cell array with the data) and @code{columns} (containing the column headers). For other commands, the output will be the number of affected rows in the database. For each command in @var{command} containing a @code{COPY FROM STDIN}, an additional argument @var{copydata} must be supplied which is either a cell-array with suitable data or a handle for a function which will return parts of this cell-array successively, one for each call, and @code{0} when ready.\n\
\n\
@end deftypefn")
{
  std::string fname ("pq_exec");

  octave_value_list retval;

  if (args.length () < 2 || args.length () > 3 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return retval;
    }

  std::string cmd (args(1).string_value ());

  if (error_state)
    {
      error ("%s: second argument can not be converted to a string", fname.c_str ());

      return retval;
    }

  const octave_base_value& rep = (args(0).get_rep ());

  const octave_pq_connection &oct_pq_conn =
    dynamic_cast<const octave_pq_connection&> (rep);

  Cell rettypes; // not implemented here

  command c (*(oct_pq_conn.get_rep ()), cmd, rettypes, fname);

  if (c.good ())
    {
      while (true)
        {
          octave_value val;

          val = c.process_single_result ();

          if (! c.good () || c.all_results_fetched ())
            break;
          else
            {
              int l = retval.length ();

              retval.resize (l + 1);

              retval (l) = val;
            }
        }
    }

  return retval;
}

#endif // code disabled

DEFUN_DLD (__pq_exec_params__, args, nargout,
           "-*- texinfo -*-\n\
undifined internal function, meant to be called by @code{pq_exec_params}")
{
  std::string fname ("__pq_exec_params__");

  octave_value retval;

  int nargs = args.length ();

  if (nargs < 2 || nargs > 4 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return retval;
    }

  std::string cmd (args(1).string_value ());

  if (error_state)
    {
      error ("%s: second argument can not be converted to a string", fname.c_str ());

      return retval;
    }

  const octave_base_value &rep = args(0).get_rep ();

  const octave_pq_connection &oct_pq_conn =
    dynamic_cast<const octave_pq_connection&> (rep);


  /*
  printf ("oid map:\n");
  for (oct_pq_conv_map_t::iterator it = oct_pq_conn.get_rep ()->conv_map.begin ();
       it != oct_pq_conn.get_rep ()->conv_map.end (); it++)
    {
      printf ("key: %u; ", it->first);
      print_conv (it->second);
    }
  printf ("\n");

  printf ("name map:\n");
  for (oct_pq_name_conv_map_t::iterator it = oct_pq_conn.get_rep ()->name_conv_map.begin ();
       it != oct_pq_conn.get_rep ()->name_conv_map.end (); it++)
    {
      printf ("key: %s; ", it->first);
      print_conv (it->second);
    }
  printf ("\n");
  */


  Cell params;

  octave_scalar_map settings;

  if (nargs == 3)
    {
      if (args(2).is_cell ())
        params = args(2).cell_value ();
      else
        settings = args(2).scalar_map_value ();

      if (error_state)
        {
          error ("%s: third argument neither cell-array nor scalar structure",
                 fname.c_str ());

          return retval;
        }
    }
  else if (nargs == 4)
    {
      params = args(2).cell_value ();
      if (error_state)
        {
          error ("%s: could not convert third argument to cell-array",
                 fname.c_str ());

          return retval;
        }
      settings = args(3).scalar_map_value ();
      if (error_state)
        {
          error ("%s: could not convert fourth argument to scalar structure");

          return retval;
        }
    }

  int nparams = params.length ();

  dim_vector pdims = params.dims ();

  if (pdims.length () > 2 || (pdims(0) > 1 && pdims(1) > 1))
    {
      error ("%s: cell-array of parameters must not be more than one-dimensional",
             fname.c_str ());

      return retval;
    }

  // get option settings

  octave_value_list f_args (3);

  octave_value_list f_ret;

  f_args(0) = octave_value (settings);
  f_args(1) = octave_value ("param_types");
  f_args(2) = octave_value (Cell (1, nparams));

  f_ret = feval ("getdbopts", f_args, 1);
  Cell ptypes = f_ret(0).cell_value ();
  if (error_state)
    {
      error ("%s: could not convert param_types to cell",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_in_path");
  f_args(2) = octave_value ("");

  f_ret = feval ("getdbopts", f_args, 1);
  std::string cin_path = f_ret(0).string_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_in_path to string",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_out_path");
  f_args(2) = octave_value ("");

  f_ret = feval ("getdbopts", f_args, 1);
  std::string cout_path = f_ret(0).string_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_out_path to string",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_in_data");
  f_args(2) = octave_value (Cell ());

  f_ret = feval ("getdbopts", f_args, 1);
  Cell cin_data = f_ret(0).cell_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_in_data to cell",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_in_with_oids");
  f_args(2) = octave_value (false);

  f_ret = feval ("getdbopts", f_args, 1);
  bool cin_with_oids = f_ret(0).bool_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_in_with_oids to bool",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_in_types");
  f_args(2) = octave_value (Cell ());

  f_ret = feval ("getdbopts", f_args, 1);
  Cell cin_types = f_ret(0).cell_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_in_types to cell",
             fname.c_str ());

      return retval;
    }

  f_args(1) = octave_value ("copy_in_from_variable");
  f_args(2) = octave_value (false);

  f_ret = feval ("getdbopts", f_args, 1);
  bool cin_from_variable = f_ret(0).bool_value ();
  if (error_state)
    {
      error ("%s: could not convert copy_in_from_variable to bool",
             fname.c_str ());

      return retval;
    }

  // check option settings

  if (ptypes.length () != nparams)
    {
      error ("%s: if given, cell-array of parameter types must have same length as cell-array of parameters",
             fname.c_str ());

      return retval;
    }

  dim_vector cind_dv = cin_data.dims ();
  if (cind_dv.length () > 2)
    {
      error ("%s: copy-in data must not be more than two-dimensional",
             fname.c_str ());

      return retval;
    }

  if (cin_types.is_empty ())
    cin_types.resize (dim_vector (1, cind_dv(1)));
  if (cin_types.numel () != cind_dv(1))
    {
      error ("%s: copy_in_types has wrong number of elements");

      return retval;
    }

  //

  Cell rtypes;

  command c (*(oct_pq_conn.get_rep ()), cmd, params, ptypes, rtypes, fname);

  if (c.good ())
    retval = c.process_single_result
      (cin_path, cout_path, cin_data, cin_types, cin_with_oids,
       cin_from_variable);

  return retval;
}
