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
// PKG_ADD: autoload ("pq_exec_params", "pq_interface.oct");
// PKG_ADD: __all_db_opts__ ("pq_exec_params");


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

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);

  Cell rettypes; // not implemented here

  command c (oct_pq_conn, cmd, rettypes, fname);

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

DEFUN_DLD (pq_exec_params, args, nargout,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} pq_exec_params (@var{connection}, @var{command})\n\
@deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params})\n\
@deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{settings})\n\
@deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params}, @var{settings})\n\
Sends the string @var{command}, which must contain a single SQL command, over the connection @var{connection}. Parameters in @var{command} can be replaced by $1, $2, etc and their values given in the one-dimensional cell-array @var{params}. Parameters of composite type sent this way must have their type defined in the database. For typeconversions, the package maintains a notion of defined types, which should be refreshed with @code{pq_update_types} if types are defined or dropped after establishing the connection. @var{settings} is a structure of settings, it can be created by @code{setdbopts}.\n\
\n\
Settings currently understood by @code{pq_exec_params}:\n\
\n\
@code{param_types}: One-dimensional cell-array with type specifications for parameters in @var{params}. If present, must have the same length as @var{params}. Entries may be empty if no specification is necessary (see below). Type specifications are strings corresponding to the entries returned by @code{SELECT typname FROM pg_type WHERE typarray != 0 OR typtype = 'c';}, optionally having @code{[]} appended (without space) to indicate an array.\n\
\n\
For queries (commands potentially returning data), the output will be a structure with fields @code{data} (containing a cell array with the data, columns correspond to returned database columns, rows correspond to returned tuples) and @code{columns} (containing the column headers). Copy commands do not work as yet. For other commands, the output will be the number of affected rows in the database.\n\
\n\
Mapping of currently implemented Postgresql types to Octave types\n\
\n\
The last column indicates whether specification of type (see above) is necessary for conversion from Octave type to Postgresql type, i.e. if Postgresql type is not deduced from the type of the Octave variable.\n\
\n\
@multitable {Postgresql} {Octave type blah blah blah blah blah} {Spec.}\n\
@headitem Postgresql @tab Octave @tab Spec.\n\
@item bool\n\
@tab logical scalar\n\
@tab no\n\
@item oid\n\
@tab uint32 scalar\n\
@tab no\n\
@item float8\n\
@tab double scalar\n\
@tab no\n\
@item float4\n\
@tab single scalar\n\
@tab no\n\
@item text\n\
@tab string\n\
@tab no\n\
@item varchar\n\
@tab string\n\
@tab yes\n\
@item bpchar\n\
@tab string\n\
@tab yes\n\
@item name\n\
@tab string of length < @code{NAMEDATALEN} (often 64)\n\
@tab yes\n\
@item bytea\n\
@tab one-dimensional array of uint8\n\
@tab no\n\
@item int2\n\
@tab int16 scalar\n\
@tab no\n\
@item int4\n\
@tab int32 scalar\n\
@tab no\n\
@item int8\n\
@tab int64 scalar\n\
@tab no\n\
@item money\n\
@tab int64 scalar, which is 100 times the currency value to enable storing the 'small currency' (e.g. Cent) fraction in the last two digits\n\
@tab yes\n\
@item any array\n\
@tab Structure with fields @code{data} (holding a cell-array with entries of a type corresponding to the Postgresql element type), @code{ndims} (holding the number of dimensions of the corresponding Postgresql array, since this can not be deduced from the dimensions of the Octave cell-array in all cases), and optionally (but always present in returned values) @code{lbounds} (a row vector of enumeration bases for all dimensions, default is @code{ones (1, ndims)}, see Postgresql documentation). Array elements may not correspond to arrays in Postgresql (use additional dimensions for this), but may correspond to composite types, which is allowed to lead to arbitrarily deep nesting.\n\
@tab yes\n\
@item any composite type\n\
@tab One-dimensional cell-array with entries of types corresponding to the respective Postgresql types. Entries may also correspond to an array-type or composite type; this is allowed to lead to arbitrarily deep nesting.\n\
@tab yes\n\
@end multitable\n\
Octaves @code{NA} corresponds to a Postgresql NULL value (not @code{NaN}, which is interpreted as a value of a float type!).\n\
@seealso{pq_update_types}\n\
@end deftypefn")
{
  std::string fname ("pq_exec_params");

  octave_value retval;

  int nargs = args.length ();

  if (nargs == 1 && args(0).is_string () &&
      args(0).string_value () == "defaults")
    {
      octave_value_list f_args (8);
      Matrix a;
      Cell c;

      f_args(0) = octave_value ("param_types");
      f_args(1) = octave_value (a);
      f_args(2) = octave_value ("copy_in_path");
      f_args(3) = octave_value ("");
      f_args(4) = octave_value ("copy_out_path");
      f_args(5) = octave_value ("");
      f_args(6) = octave_value ("copy_in_data");
      f_args(7) = octave_value (c);

      return feval ("setdbopts", f_args, 1);
    }

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

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);


  /*
  printf ("oid map:\n");
  for (oct_pq_conv_map_t::iterator it = oct_pq_conn.conv_map.begin ();
       it != oct_pq_conn.conv_map.end (); it++)
    {
      printf ("key: %u; ", it->first);
      print_conv (it->second);
    }
  printf ("\n");

  printf ("name map:\n");
  for (oct_pq_name_conv_map_t::iterator it = oct_pq_conn.name_conv_map.begin ();
       it != oct_pq_conn.name_conv_map.end (); it++)
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
      error ("could not convert param_types to cell");

      return retval;
    }

  f_args(1) = octave_value ("copy_in_path");
  f_args(2) = octave_value ("");

  f_ret = feval ("getdbopts", f_args, 1);
  std::string cin_path = f_ret(0).string_value ();
  if (error_state)
    {
      error ("could not convert copy_in_path to string");

      return retval;
    }

  f_args(1) = octave_value ("copy_out_path");
  f_args(2) = octave_value ("");

  f_ret = feval ("getdbopts", f_args, 1);
  std::string cout_path = f_ret(0).string_value ();
  if (error_state)
    {
      error ("could not convert copy_out_path to string");

      return retval;
    }

  f_args(1) = octave_value ("copy_in_data");
  f_args(2) = octave_value (Cell ());

  f_ret = feval ("getdbopts", f_args, 1);
  Cell cin_data = f_ret(0).cell_value ();
  if (error_state)
    {
      error ("could not convert copy_in_data to cell");

      return retval;
    }

  // check option settings

  if (ptypes.length () != nparams)
    {
      error ("%s: if given, cell-array of parameter types must have same length as cell-array of parameters",
             fname.c_str ());

      return retval;
    }

  if (nargout && ! cout_path.empty ())
    {
      error ("%s: copy out pathname and output argument may not be both given",
             fname.c_str ());

      return retval;
    }

  if (! cin_path.empty () && ! cin_data.is_empty ())
    {
      error ("%s: copy in pathname and copy in data may not be both given",
             fname.c_str ());

      return retval;
    }

  //

  Cell rtypes;

  command c (oct_pq_conn, cmd, params, ptypes, rtypes, fname);

  if (c.good ())
    retval = c.process_single_result (cin_path, cout_path, nargout, cin_data);

  return retval;
}
