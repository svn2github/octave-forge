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

#include <iostream>
#include <fstream>

#include "command.h"

#define ERROR_RETURN_NO_PG_TYPE                                         \
 {                                                                      \
   error ("could not determine postgresql type for Octave parameter");  \
   return NULL;                                                         \
 }

command::command (octave_pq_connection &connection, std::string &cmd,
                  Cell &rtypes,std::string &who) :
  valid (1), conn (connection), caller (who), res (NULL), all_fetched (0),
  rettypes (rtypes)
{
  if (! (cptr = conn.octave_pq_get_conn ()))
    {
      valid = 0;
      error ("%s: connection not open", caller.c_str ());
    }

  if (! PQsendQuery (cptr, cmd.c_str ()))
    {
      valid = 0;
      error ("%s: could not dispatch command: %s", caller.c_str (),
             PQerrorMessage (cptr));
    }
  else
    {
      res = PQgetResult (cptr);
      check_first_result ();
    }
}

command::command (octave_pq_connection &connection, std::string &cmd,
                  Cell &params, Cell &ptypes, Cell &rtypes, std::string &who)
  : valid (1), conn (connection), caller (who), res (NULL), all_fetched (1),
    rettypes (rtypes)
{
  if (! (cptr = conn.octave_pq_get_conn ()))
    {
      valid = 0;
      error ("%s: connection not open", caller.c_str ());
    }

  int npars = params.length ();

  char *vals [npars];
  std::vector<oct_pq_dynvec_t> valsvec;
  valsvec.resize (npars);
  int pl [npars];
  int pf [npars];
  Oid oids [npars];

  for (int i = 0; i < npars; i++)
    {
      pf[i] = 1; // means binary format

      if (params(i).is_real_scalar () && params(i).isna ().bool_value ())
        {
          vals[i] = NULL;

          oids[i] = 0;
        }
      else
        {
          oct_type_t oct_type;
          oct_pq_conv_t *conv;
          oct_pq_from_octave_fp_t conv_fcn;

          if (ptypes(i).is_empty ())
            {
              oct_type = simple;

              if (! (conv = pgtype_from_octtype (params(i))))
                {
                  valid = 0;
                  break;
                }

              // array not possible here
              oids[i] = conv->oid;
            }
          else
            {
              std::string s = ptypes(i).string_value ();
              if (error_state)
                {
                  error ("%s: parameter type specification no string",
                         caller.c_str ());
                  valid = 0;
                  break;
                }

              if (! (conv = pgtype_from_spec (s, oct_type)))
                {
                  valid = 0;
                  break;
                }

              if (oct_type == array)
                oids[i] = conv->aoid;
              else
                oids[i] = conv->oid;
            }

          switch (oct_type)
            {
            case simple:
              conv_fcn = conv->from_octave_bin;
              if (conv_fcn (params(i), valsvec[i]))
                valid = 0;
              break;

            case array:
              if (from_octave_bin_array (params(i), valsvec[i], conv))
                valid = 0;
              break;

            case composite:
              if (from_octave_bin_composite (params(i), valsvec[i], conv))
                valid = 0;
              break;

            default:
              // should not get here
              error ("%s: internal error, undefined type identifier",
                     caller.c_str ());

              valid = 0;
            }

          if (! valid) break;

          vals[i] = &(valsvec[i].front ());
          pl[i] = valsvec[i].size ();
        }
    }

  if (valid)
    {
      BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;

      res = PQexecParams (cptr, cmd.c_str (), npars, oids, vals, pl, pf, 1);

      END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;

      check_first_result ();
    }
}

oct_pq_conv_t *command::pgtype_from_spec (std::string &name,
                                          oct_type_t &oct_type)
{
  oct_pq_conv_t *conv = NULL;

  // printf ("pgtype_from_spec(%s): simple ", name.c_str ());

  oct_type = simple; // default
  int l;
  while (name.size () >= 2 && ! name.compare (l = name.size () - 2, 2, "[]"))
    {
      name.erase (l, 2);
      oct_type = array;

      // printf ("array ");
    }

  oct_pq_name_conv_map_t::iterator iter;

  if ((iter = conn.name_conv_map.find (name.c_str ())) ==
      conn.name_conv_map.end ())
    error ("%s: no converter found for type %s", caller.c_str (),
           name.c_str ());
  else
    {
      // printf ("(looked up in name map) ");

      conv = iter->second;

      if (oct_type == array && ! conv->aoid)
        {
          error ("%s: internal error, type %s, specified as array, has no array type in system catalog", name.c_str ());
          return conv;
        }

      if (! (oct_type == array) && conv->is_composite)
        {
          oct_type = composite;

          // printf ("composite ");
        }
    }

  // printf ("\n");

  return conv;
}

oct_pq_conv_t *command::pgtype_from_spec (Oid oid, oct_type_t &oct_type)
{
  // printf ("pgtype_from_spec(%u): ", oid);

  oct_pq_conv_t *conv = NULL;

  oct_pq_conv_map_t::iterator iter;
  
  if ((iter = conn.conv_map.find (oid)) == conn.conv_map.end ())
    {
      error ("%s: no converter found for element oid %u",
             caller.c_str (), oid);
      return conv;
    }
  conv = iter->second;
  // printf ("(looked up %s in oid map) ", conv->name.c_str ());

  if (conv->aoid == oid)
    oct_type = array;
  else if (conv->is_composite)
    oct_type = composite;
  else
    oct_type = simple;

  // printf ("oct_type: %i\n", oct_type);

  return conv;
}

oct_pq_conv_t *command::pgtype_from_spec (Oid oid, oct_pq_conv_t *&c_conv,
                                          oct_type_t &oct_type)
{
  if (c_conv)
    {
      if (c_conv->aoid == oid)
        oct_type = array;
      else if (c_conv->is_composite)
        oct_type = composite;
      else
        oct_type = simple;
    }
  else
    c_conv = pgtype_from_spec (oid, oct_type);

  return c_conv;
}

octave_value command::process_single_result (const std::string &infile,
                                             const std::string &outfile,
                                             const Cell &cdata,
                                             const Cell &ctypes,
                                             bool coids,
                                             bool cin_var,
                                             bool cout_var)
{
  octave_value retval;

  // first result is already fetched
  if (! res && (res = PQgetResult (cptr)))
    state = PQresultStatus (res);

  if (! res)
    all_fetched = 1;
  else
    {
      switch (state)
        {
        case PGRES_BAD_RESPONSE:
          valid = 0;
          error ("%s: server response not understood", caller.c_str ());
          break;
        case PGRES_FATAL_ERROR:
          valid = 0;
          error ("%s: fatal error: %s", caller.c_str (),
                 PQresultErrorMessage (res));
          break;
        case PGRES_COMMAND_OK:
          retval = command_ok_handler ();
          break;
        case PGRES_TUPLES_OK:
          retval = tuples_ok_handler ();
          break;
        case PGRES_COPY_OUT:
          retval = copy_out_handler (outfile, cout_var);
          break;
        case PGRES_COPY_IN:
          retval = copy_in_handler (infile, cdata, ctypes, coids, cin_var);
          break;
        }

      if (res) // could have been changed by a handler
        {
          PQclear (res);
          res = NULL;
        }
    }

  return retval;
}

octave_value command::tuples_ok_handler (void)
{
  octave_map ret;

  int nt = PQntuples (res);
  int nf = PQnfields (res);

  Cell data (nt, nf);
  Cell columns (1, nf);

  bool rtypes_given;
  int l = rettypes.length ();
  if (l > 0)
    {
      if (l != nf)
        {
          error ("%s: wrong number of given returned types", caller.c_str ());
          valid = 0;
          return octave_value_list ();
        }
      rtypes_given = true;
    }
  else
    rtypes_given = false;

  for (int j = 0; j < nf; j++) // j is column
    {
      columns(j) = octave_value (PQfname (res, j));

      int f = PQfformat (res, j);

      oct_pq_to_octave_fp_t simple_type_to_octave;
      to_octave_array_fp_t array_to_octave;
      to_octave_composite_fp_t composite_to_octave;

      oct_pq_conv_t *conv;
      oct_type_t oct_type;

      // perform next block only if there are any rows, since
      // otherwise no converter will be needed and we can spare a
      // possible error of not finding a suitable one
      if (nt > 0)
        {
          if (rtypes_given) // for internal reading of system tables
            {
              std::string type = rettypes(j).string_value ();
              if (error_state)
                error ("%s: could not convert given type to string",
                       caller.c_str ());
              else
                conv = pgtype_from_spec (type, oct_type);

              if (error_state)
                {
                  valid = 0;
                  break;
                }
            }
          else
            if (! (conv = pgtype_from_spec (PQftype (res, j), oct_type)))
              {
                valid = 0;
                break;
              }

          if (f)
            {
              array_to_octave = &command::to_octave_bin_array;
              composite_to_octave = &command::to_octave_bin_composite;
              // will be NULL for non-simple converters
              simple_type_to_octave = conv->to_octave_bin;
            }
          else
            {
              array_to_octave = &command::to_octave_str_array;
              composite_to_octave = &command::to_octave_str_composite;
              // will be NULL for non-simple converters
              simple_type_to_octave = conv->to_octave_str;
            }
        }

      for (int i = 0; i < nt; i++) // i is row
        {
          if (PQgetisnull (res, i, j))
            data(i, j) = octave_value (octave_NA);
          else
            {
              char *v = PQgetvalue (res, i, j);
              int nb = PQgetlength (res, i, j);
              octave_value ov;

              switch (oct_type)
                {
                case simple:
                  if (simple_type_to_octave (v, ov, nb))
                    valid = 0;
                  break;

                case array:
                  if ((this->*array_to_octave) (v, ov, nb, conv))
                    valid = 0;
                  break;

                case composite:
                  if ((this->*composite_to_octave) (v, ov, nb, conv))
                    valid = 0;
                  break;

                default:
                  // should not get here
                  error ("%s: internal error, undefined type identifier",
                         caller.c_str ());

                  valid = 0;
                }

              if (valid)
                data(i, j) = ov;
              else
                break;
            }
        }

      if (! valid)
        break;
    }

  if (error_state)
    return octave_value_list ();
  else
    {
      ret.assign ("data", octave_value (data));
      ret.assign ("columns", octave_value (columns));

      return octave_value (ret);
    }
}

octave_value command::copy_out_handler (const std::string &outfile, bool var)
{
  octave_value retval;

  if (! outfile.empty ())
    {
      // store unchecked output in file

      std::ofstream ostr (outfile.c_str (), std::ios_base::out);
      if (ostr.fail ())
        error ("could not open output file %s", outfile.c_str ());

      char *data;
      int nb;
      while ((nb = PQgetCopyData (cptr, &data, 0)) > 0)
        {
          if (! (ostr.fail () || ostr.bad ()))
            {
              ostr.write (data, nb);
              if (ostr.bad ())
                error ("write to file failed");
            }
          PQfreemem (data);
        }

      if (! error_state)
        ostr.close ();

      if (nb == -2)
        error ("server error in copy-out: %s", PQerrorMessage (cptr));
      else
        {
          PQclear (res);

          if (res = PQgetResult (cptr))
            {
              if ((state = PQresultStatus (res)) == PGRES_FATAL_ERROR)
                error ("server error in copy-out: %s", PQerrorMessage (cptr));
            }
          else
            error ("unexpectedly got no result information");
        }
    }
  else
    error ("no filename given for copy-out");

  if (error_state)
    valid = 0;

  return retval;
}

octave_value command::copy_in_handler (const std::string &infile,
                                       const Cell &data,
                                       const Cell &cin_types,
                                       bool oids,
                                       bool var)
{
  octave_value retval;

#define OCT_PQ_READSIZE 4096

  char buff [OCT_PQ_READSIZE];

  if (! var)
    {
      // read unchecked input from file

      if (infile.empty ())
        {
          error ("no input file given");

          valid = 0;

          return retval;
        }

      std::ifstream istr (infile.c_str (), std::ios_base::in);
      if (istr.fail ())
        {
          error ("could not open input file %s", infile.c_str ());

          PQputCopyEnd (cptr, "could not open input file");

          error ("server error: %s", PQerrorMessage (cptr));

          valid = 0;

          return retval;
        }

      do
        {
          istr.read (buff, OCT_PQ_READSIZE);

          if (istr.bad ())
            {
              error ("could not read file %s", infile.c_str ());

              break;
            }
          else
            {
              int nb;

              if ((nb = istr.gcount ()) > 0)
                if (PQputCopyData (cptr, buff, nb) == -1)
                  {
                    error ("%s", PQerrorMessage (cptr));

                    break;
                  }
            }
        }
      while (! istr.eof ());

      istr.close ();

      if (error_state)
        {
          PQputCopyEnd (cptr, "copy-in interrupted");

          error ("%s", PQerrorMessage (cptr));
        }
      else
        {
          if (PQputCopyEnd (cptr, NULL) == -1)
            error ("%s", PQerrorMessage (cptr));
          else
            {
              PQclear (res);

              if (res = PQgetResult (cptr))
                {
                  if ((state = PQresultStatus (res)) == PGRES_FATAL_ERROR)
                    error ("server error in copy-in: %s", PQerrorMessage (cptr));
                }
              else
                error ("unexpectedly got no result information");
            }
        }
    }
  else
    {
      // copy in from octave variable

      dim_vector dv = data.dims ();
      octave_idx_type r = dv(0);
      octave_idx_type c = dv(1);

      octave_idx_type nf = PQnfields (res);
      if (c != nf + oids)
        {
          error ("variable for copy-in has %i columns, but should have %i",
                 c, nf + oids);

          PQputCopyEnd
            (cptr, "variable for copy-in has wrong number of columns");
        }
      else if (! PQbinaryTuples (res))
        {
          error ("copy-in from variable must use binary mode");

          PQputCopyEnd (cptr, "copy-in from variable must use binary mode");
        }
      else
        {
          for (octave_idx_type j = 0; j < c; j++)
            if (! PQfformat (res, j))
              {
                error ("copy-in from argument must use binary mode in all columns");

                PQputCopyEnd (cptr, "copy-in from argument must use binary mode in all columns");

                break;
              }
        }

      if (error_state)
        {
          error ("server error: %s", PQerrorMessage (cptr));

          valid = 0;

          return retval;
        }

#define COPY_HEADER_SIZE 19
      char header [COPY_HEADER_SIZE];
      memset (header, 0, COPY_HEADER_SIZE);
      strcpy (header, "PGCOPY\n\377\r\n\0");
      *((uint32_t *) (&header[11])) = htobe32 (uint32_t (oids) << 16);

      char trailer [2];
      *((int16_t *) (&trailer)) = htobe16 (int16_t (-1));

      if (PQputCopyData (cptr, header, COPY_HEADER_SIZE) == -1)
        {
          PQputCopyEnd (cptr, "could not send header");

          error ("server error: %s", PQerrorMessage (cptr));
        }
      else
        {
          oct_pq_conv_t *convs [c];
          memset (convs, 0, sizeof (convs));
          oct_type_t oct_types [c];

          for (octave_idx_type i = 0; i < r; i++) // i is row
            {
              int16_t fc = htobe16 (int16_t (nf));
              if (PQputCopyData (cptr, (char *) &fc, 2) == -1)
                {
                  error ("%s", PQerrorMessage (cptr));

                  PQputCopyEnd (cptr, "error sending field count");

                  error ("server error: %s", PQerrorMessage (cptr));

                  break;
                }

              // j is column of argument data
              for (octave_idx_type j = 0; j < c; j++)
                {
                  if (data(i, j).is_real_scalar () &&
                      data(i, j).isna ().bool_value ())
                    {
                      int32_t t = htobe32 (int32_t (-1));
                      if (PQputCopyData (cptr, (char *) &t, 4) == -1)
                        {
                          error ("could not send NULL in copy-in");

                          break;
                        }
                    }
                  else
                    {
                      if (! convs [j])
                        {
                          if ((j == 0) && oids)
                            {
                              std::string t ("oid");
                              convs[0] = pgtype_from_spec (t, oct_types[0]);
                            }
                          else
                            {
                              if (cin_types(j).is_empty ())
                                {
                                  oct_types[j] = simple;

                                  if (! (convs[j] =
                                         pgtype_from_octtype (data(i, j))))
                                    {
                                      error ("could not determine type in column %i for copy-in",
                                             j);

                                      break;
                                    }
                                }
                              else
                                {
                                  std::string s = cin_types(j).string_value ();
                                  if (error_state)
                                    {
                                      error ("column type specification no string");

                                      break;
                                    }

                                  if (! (convs[j] =
                                         pgtype_from_spec (s, oct_types[j])))
                                    {
                                      error ("invalid column type specification");

                                      break;
                                    }
                                }
                            }
                        } // ! convs [j]

                      oct_pq_dynvec_t val;

                      bool conversion_failed = false;
                      switch (oct_types[j])
                        {
                        case simple:
                          if (convs[j]->from_octave_bin (data(i, j), val))
                            conversion_failed = true;
                          break;

                        case array:
                          if (from_octave_bin_array (data(i, j), val, convs[j]))
                            conversion_failed = true;
                          break;

                        case composite:
                          if (from_octave_bin_composite (data(i, j), val,
                                                         convs[j]))
                            conversion_failed = true;
                          break;

                        default:
                          // should not get here
                          error ("internal error, undefined type identifier");
                        }

                      if (conversion_failed)
                        error ("could not convert data(%i, %i) for copy-in",
                               i, j);
                      else
                        {
                          uint32_t t = htobe32 (uint32_t (val.size ()));
                          if (PQputCopyData (cptr, (char *) &t, 4) == -1)
                            error ("could not send data length in copy-in");
                          else if (PQputCopyData (cptr, &(val.front ()),
                                                  val.size ()) == -1)
                            error ("could not send copy-in data");
                        }

                      if (error_state) break;
                    }
                } // columns of argument data

              if (error_state)
                {
                  PQputCopyEnd (cptr, "error sending copy-in data");

                  error ("server error: %s", PQerrorMessage (cptr));

                  break;
                }
            } // rows of argument data
        }

      if (! error_state)
        if (PQputCopyData (cptr, trailer, 2) == -1)
          {
            PQputCopyEnd (cptr, "could not send trailer");

            error ("%s", PQerrorMessage (cptr));
          }

      if (! error_state)
        if (PQputCopyEnd (cptr, NULL) == -1)
          error ("%s", PQerrorMessage (cptr));
        else
          {
            PQclear (res);

            if (res = PQgetResult (cptr))
              {
                if ((state = PQresultStatus (res)) == PGRES_FATAL_ERROR)
                  error ("server error in copy-in: %s", PQerrorMessage (cptr));
              }
            else
              error ("unexpectedly got no result information");
          }
    } // copy from variable

  if (error_state)
    valid = 0;

  return retval;
}

oct_pq_conv_t *command::pgtype_from_octtype (const octave_value &param)
{
  // printf ("pgtype_from_octtype: ");

  if (param.is_bool_scalar ())
    {
      // printf ("bool\n");
      return conn.name_conv_map["bool"];
    }
  else if (param.is_real_scalar ())
    {
      if (param.is_double_type ())
        {
          // printf ("float8\n");
          return conn.name_conv_map["float8"];
        }
      else if (param.is_single_type ())
        {
          // printf ("float4\n");
          return conn.name_conv_map["float4"];
        }
    }

  if (param.is_scalar_type ())
    {
      if (param.is_int16_type ())
        {
          // printf ("int2\n");
          return conn.name_conv_map["int2"];
        }
      else if (param.is_int32_type ())
        {
          // printf ("int4\n");
          return conn.name_conv_map["int4"];
        }
      else if (param.is_int64_type ())
        {
          // printf ("int8\n");
          return conn.name_conv_map["int8"];
        }
      else if (param.is_uint32_type ())
        {
          // printf ("oid\n");
          return conn.name_conv_map["oid"];
        }
    }

  if (param.is_uint8_type ())
    {
      // printf ("bytea\n");
      return conn.name_conv_map["bytea"];
    }
  else if (param.is_string ())
    {
      // printf ("text\n");
      return conn.name_conv_map["text"];
    }

  ERROR_RETURN_NO_PG_TYPE
}
