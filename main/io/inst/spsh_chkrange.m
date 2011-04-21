## Copyright (C) 2010 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{topleftaddr}, @var{nrows}, @var{ncols}, @var{toprow}, @var{leftcol} ] = spsh_chkrange ( @var{range}, @var{rowsize}, @var{colsize}, @var{intf-type}, @var{filename})
## (Internal function) Get and check various cell and range address parameters for spreadsheet input.
##
## spsh_chkrange should not be invoked directly but rather through oct2xls or oct2ods.
##
## Example:
##
## @example
##   [tl, nrw, ncl, trw, lcl] = spsh_chkrange (crange, nr, nc, xtype, fileptr);
## @end example
##
## @end deftypefn

## Author: Philip Nienhuis, <prnienhuis@users.sf.net>
## Created: 2010-08-02
## Updates: 
## 2010-08-25 Option for supplying file pointer rather than interface_type & filename
##            (but this can be wasteful if the file ptr is copied)
## 2011-03-29 Bug fix - unrecognized pointer struct & wrong type error msg
## 2011-04-21 Bug fix - wouldn't properly detect OOXML from extension
##      ''    Added tests

function [ topleft, nrows, ncols, trow, lcol ] = spsh_chkrange (crange, nr, nc, intf, filename=[])

	if (nargin == 4)
		# File pointer input assumed
		if (isstruct (intf))
			xtype = intf.xtype;
			filename = intf.filename;
		else
			error ("Too few or improper arguments supplied.");
		endif
	else
		# Interface type & filename supplied
		xtype = intf;
	endif

	# Define max row & column capacity from interface type & file suffix
	switch xtype
		case {'COM', 'POI'}
			if (strcmp ('xls', tolower (filename(end-2:end))))
				# BIFF5 & BIFF8
				ROW_CAP = 65536;   COL_CAP = 256;
			else
				# OOXML (COM needs Excel 2007+ for this)
				ROW_CAP = 1048576; COL_CAP = 16384;
			endif
		case {'JXL', 'OXS'}
			# JExcelAPI & OpenXLS can only process BIFF5 & BIFF8
			ROW_CAP = 65536;   COL_CAP = 256;
		case {'OTK', 'JOD'}
			# ODS
			ROW_CAP = 65536;   COL_CAP = 1024;
		otherwise
			error (sprintf ("Unknown interface type - %s\n", xtype));
	endswitch

	if (isempty (deblank (crange)))
		trow = 1;
		lcol = 1;
		nrows = nr;
		ncols = nc;
		topleft= 'A1';
	elseif (isempty (strfind (deblank (crange), ':')))
		# Only top left cell specified
		[topleft, dummy1, dummy2, trow, lcol] = parse_sp_range (crange);
		nrows = nr;
		ncols = nc;
	else
		[topleft, nrows, ncols, trow, lcol] = parse_sp_range (crange);
	endif
	if (trow > ROW_CAP || lcol > COL_CAP)
		error ("Topleft cell (%s) beyond spreadsheet limits.");
	endif
	# Check spreadsheet capacity beyond requested topleft cell
	nrows = min (nrows, ROW_CAP - trow + 1);
	ncols = min (ncols, COL_CAP - lcol + 1);
	# Check array size and requested range
	nrows = min (nrows, nr);
	ncols = min (ncols, nc);

endfunction

# Test COM using ptr struct
%!test
%! intf = struct ("xtype", 'COM', "app", [], "filename", 'test.xls', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:IY67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 257, intf);
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 253, 2, 4]);

# Test COM using ptr struct
%!test
%! intf = struct ("xtype", 'COM', "app", [], "filename", 'test.xls', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:IY67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 257, 'COM', 'filename.xls');
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 253, 2, 4]);

# Test POI using ptr struct
%!test
%! intf = struct ("xtype", 'POI', "app", [], "filename", 'test.xls', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:IY67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 257, intf);
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 253, 2, 4]);

# Test POI OOXML using ptr struct
%!test
%! intf = struct ("xtype", "POI", "app", [], "filename", 'test.xlsx', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D3:xfe1058888';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 1200000, 20000, intf);
%! assert ([a1, a2, a3, a4, a5], ['D3', 1048574, 16381, 3, 4]);

# Test JXL using ptr struct
%!test
%! intf = struct ("xtype", "JXL", "app", [], "filename", 'test.xls', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:IY67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 257, intf);
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 253, 2, 4]);

# Test OTK using ptr struct
%!test
%! intf = struct ("xtype", 'OTK', "app", [], "filename", 'test.ods', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:AML67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 1200, intf);
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 1021, 2, 4]);

# Test JOD using ptr struct
%!test
%! intf = struct ("xtype", 'JOD', "app", [], "filename", 'test.ods', "workbook", [], "changed", 0, "limits", []);
%! tstrange = 'D2:AML67356';
%! [a1, a2, a3, a4, a5] = spsh_chkrange (tstrange, 65536, 1200, intf);
%! assert ([a1, a2, a3, a4, a5], ['D2', 65535, 1021, 2, 4]);
