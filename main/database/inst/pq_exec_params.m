## Copyright (C) 2013 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} pq_exec_params (@var{connection}, @var{command})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{settings})
## @deftypefnx {Loadable Function} pq_exec_params (@var{connection}, @var{command}, @var{params}, @var{settings})
##
## Sends the string @var{command}, which must contain a single SQL
## command, over the connection @var{connection}. Parameters in
## @var{command} can be replaced by $1, $2, etc and their values given
## in the one-dimensional cell-array @var{params}. Parameters of
## composite type sent this way must have their type defined in the
## database. For typeconversions, the package maintains a notion of
## defined types, which should be refreshed with @code{pq_update_types}
## if types are defined or dropped after establishing the connection, or
## if the schema search path changes. @var{settings} is a structure of
## settings, it can be created by @code{setdbopts}.
##
## Settings currently understood by @code{pq_exec_params}:
##
## @table @code
## @item param_types
## One-dimensional cell-array with type specifications for parameters in
## @var{params}. If present, must have the same length as @var{params}.
## Entries may be empty if no specification is necessary (see below).
## Type specifications are strings corresponding to the entries returned
## by @code{SELECT typname FROM pg_type WHERE typarray != 0 OR typtype =
## 'c';}, optionally having @code{[]} appended (without space) to
## indicate an array. Type specifications can be schema-qualified,
## otherwise they refer to the visible type with that name.
## @item copy_in_path, copy_out_path
## Path to files at the client side for @code{copy from stdin} and
## @code{copy to stdout}, respectively.
## @item copy_in_from_variable
## Logical scalar, default @code{false}. If @code{true}, @code{copy from
## stdin} uses data from an Octave variable instead of from a file.
## @item copy_in_data
## 2-dimensional cell-array with columns of suitable type (see below) --
## will be used instead of a file as data for @code{copy from stdin} if
## @code{copy_in_from_variable} is @code{true}.
## @item copy_in_types
## If some columns in @code{copy_in_data} need a type specification (see
## below), @code{copy_in_types} has to be set to a cell-array with type
## specifications, with an entry (possibly empty) for each column.
## @item copy_in_with_oids
## If you want to copy in with oids when using data from an Octave
## variable, the first column of the data must contain the OIDs and
## @code{copy_in_with_oids} has to be set to @code{true} (default
## @code{false}); @code{with oids} should be specified together with
## @code{copy from stdin} in the command, otherwise Postgresql will
## ignore the copied oids.
## @end table
##
## There is no way to @code{copy to stdout} into an Octave variable, but
## a @code{select} command can be used for this purpose.
##
## For queries (commands potentially returning data), the output will be
## a structure with fields @code{data} (containing a cell array with the
## data, columns correspond to returned database columns, rows
## correspond to returned tuples), @code{columns} (containing the column
## headers), and @code{types} (a  structure-vector with the postgresql
## data types of the columns, subfields @code{name} (string with
## typename), @code{is_array} (boolean), @code{is_composite} (boolean),
## @code{is_enum} (boolean), and @code{elements} (if @code{is_composite
## == true}, structure-vector of element types, containing fields
## corresponding to those of @code{types})). For copy commands nothing
## is returned. For other commands, the output will be the number of
## affected rows in the database.
##
## Mapping of currently implemented Postgresql types to Octave types
##
## The last column indicates whether specification of type (see above)
## is necessary for conversion from Octave type to Postgresql type, i.e.
## if Postgresql type is not deduced from the type of the Octave
## variable. As long as the Postgresql type is deduced correctly or is
## user-specified, it is often sufficent to provide an Octave type that
## can be converted to the Octave type given in the table.
##
## @multitable {Postgresql} {Octave type blah blah blah blah blah} {Spec.}
## @headitem Postgresql @tab Octave @tab Spec.
## @item bool
## @tab logical scalar
## @tab no
## @item oid
## @tab uint32 scalar
## @tab no
## @item float8
## @tab double scalar
## @tab no
## @item float4
## @tab single scalar
## @tab no
## @item text
## @tab string
## @tab no
## @item varchar
## @tab string
## @tab yes
## @item bpchar
## @tab string
## @tab yes
## @item name
## @tab string of length < @code{NAMEDATALEN} (often 64)
## @tab yes
## @item bytea
## @tab array of uint8, one-dimensional if converted from postgresql data
## @tab no
## @item int2
## @tab int16 scalar
## @tab no
## @item int4
## @tab int32 scalar
## @tab no
## @item int8
## @tab int64 scalar
## @tab no
## @item money
## @tab int64 scalar, which is 100 times the currency value to enable
## storing the 'small currency' (e.g. Cent) fraction in the last two
## digits
## @tab yes
## @item timestamp
## @tab 8-byte-time-value (see below), positive or negative difference
## to 2000-01-01 00:00
## @tab yes
## @item timestamptz
## @tab as timestamp
## @tab yes
## @item time
## @tab 8-byte-time-value (see below)
## @tab yes
## @item timetz
## @tab 2-element cell array with 8-byte-time-value (see below, time of
## day) and int32 scalar (time zone in seconds, negative east of UTC)
## @tab yes
## @item date
## @tab int32 scalar, positive or negative difference to 2000-01-01
## @tab yes
## @item interval
## @tab 3-element cell array with 8-byte-time-value (see below), int32
## (days), and int32 (months)
## @tab yes
## @item point
## @tab geometric point data for one point (see below)
## @tab no
## @item lseg
## @tab geometric point data for two points (see below)
## @tab no
## @item line (not yet implemented by postgresql-9.2.4)
## @tab as lseg
## @tab yes
## @item box
## @tab as lseg
## @tab yes
## @item circle
## @tab real vector (but the restrictions for type uint8 as in geometric
## element type apply, as explained below) with 3 elements, no. 1 and 2
## centre coordinates, no. 3 radius
## @tab no
## @item polygon
## @tab geometric point data (see below)
## @tab yes
## @item path
## @tab structure with fields @code{closed} (boolean, is path closed?)
## and @code{path} (geometric point data, see below).
## @tab yes
## @item inet
## @tab uint8 array of 4 or 5 elements for IPv4 or uint16 array of 8 or
## 9 elements for IPv6. 5th or 9th element, respectively, contain number
## of set bits in network mask, the default (if there are only 4 or 8
## elements, respectively) is all bits set.
## @tab yes
## @item cidr
## @tab as inet
## @tab yes
## @item macaddr
## @tab uint8 array of 6 elements
## @tab yes
## @item bit
## @tab structure with fields @code{bitlen} (int32, number of valid
## bits) and @code{bits} (uint8 array, 8 bits per entry, first entry
## contains the leftmost bits, last entry may contain less than 8 bits)
## @tab yes
## @item varbit
## @tab as bit
## yes
## @item uuid
## @tab uint8 array of 16 elements
## @tab yes
## @item xml
## @tab string
## @tab yes
## @item any array
## @tab Structure with fields @code{data} (holding a cell-array with
## entries of a type corresponding to the Postgresql element type),
## @code{ndims} (holding the number of dimensions of the corresponding
## Postgresql array, since this can not be deduced from the dimensions
## of the Octave cell-array in all cases), and optionally (but always
## present in returned values) @code{lbounds} (a row vector of
## enumeration bases for all dimensions, default is @code{ones (1,
## ndims)}, see Postgresql documentation). Array elements may not
## correspond to arrays in Postgresql (use additional dimensions for
## this), but may correspond to composite types, which is allowed to
## lead to arbitrarily deep nesting.
## @tab yes
## @item any composite type
## @tab One-dimensional cell-array with entries of types corresponding
## to the respective Postgresql types. Entries may also correspond to an
## array-type or composite type; this is allowed to lead to arbitrarily
## deep nesting.
## @tab yes
## @item any enum type
## @tab string
## @tab yes
## @end multitable
##
## 8-byte-time-value: int64 scalar, representing microseconds, if server
## is configured for integer date/time; double scalar, representing
## seconds, if server is configured for float date/time (deprecated).
## There is no automatic conversion from an octave variable, an error is
## thrown if the wrong of both types is supplied. One can use
## @code{pq_conninfo} to query the respective server configuration.
##
## geometric point data: any real array (but if of type uint8, the
## geometric type name must always be specified, for otherwise uint8
## would be considered as bytea) with even number of elements. Two
## adjacent elements (adjacent if indexed with a single index) define a
## pair of 2D point coordinates. In converting from postgresql data,
## dimensions of Octave geometric point data will be chosen to be (2,
## n_points) and elements will be of format double.
##
## Octaves @code{NA} corresponds to a Postgresql NULL value (not
## @code{NaN}, which is interpreted as a value of a float type!).
##
## @seealso {pq_update_types, pq_conninfo}
## @end deftypefn

## PKG_ADD: __all_db_opts__ ("pq_exec_params");

function ret = pq_exec_params (conn, varargin)

  ## This wrapper is necessary to work around calling PKG_ADD
  ## instructions of each added path immediately, before all paths of a
  ## package are added. In 'pkg install', m-function path is set before
  ## oct-function path, and left set, so this would work here. But in
  ## 'pkg build', if the package is not already installed, these paths
  ## are temporarily and separately set.

  if ((nargs = nargin) == 0)
    print_usage ();
  endif

  if (nargs == 1 && ischar (conn) && strcmp (conn, "defaults"))

    ret = setdbopts ("param_types", [], ...
                     "copy_in_path", "", ...
                     "copy_out_path", "", ...
                     "copy_in_data", [], ...
                     "copy_in_with_oids", false, ...
                     "copy_in_types", [], ...
                     "copy_in_from_variable", false);

  else

    t_ret = __pq_exec_params__ (conn, varargin{:});

    if (! ischar (t_ret)) ## marker for a copy command
      ret = t_ret;
    endif

  endif

endfunction
