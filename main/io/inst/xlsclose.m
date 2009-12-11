## Copyright (C) 2009 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} [@var{xls}] = xlsclose (@var{xls})
## Close the Excel spreadsheet pointed to in struct @var{xls}, if needed
## write the file to disk. An empty pointer struct will be returned.
## xlsclose will determine if the file must be written to disk based
## on information contained in @var{xls}.
##
## You need MS-Excel (95 - 2003), and/or the Java package > 1.2.6 plus Apache
## POI > 3.5 installed on your computer + proper javaclasspath set, to make
## this function work at all.
##
## @var{xls} must be a valid pointer struct made by xlsopen() in the same
## octave session.
##
## Beware: Excel invocations may be left running invisibly in case of COM errors.
##
## Examples:
##
## @example
##   xls1 = xlsclose (xls1);
##   (Close spreadsheet file pointed to in pointer struct xls1; xls1 is reset)
## @end example
##
## @seealso xlsclose, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo
##
## @end deftypefn


## Author: Philip Nienhuis
## Created: 2009-11-29
## Latest update: 2009-12-11

function [ xls ] = xlsclose (xls)

	if (strcmp (xls.xtype, 'COM'))
		# If file has been changed, write it out to disk.
		#
		# Note: COM / VB supports other Excel file formats as FileFormatNum:
		# 4 = .wks - Lotus 1-2-3 / Microsoft Works
		# 6 = .csv
		# -4158 = .txt 
		# 36 = .prn
		# 50 = .xlsb - xlExcel12 (Excel Binary Workbook in 2007 with or without macro's)
		# 51 = .xlsx - xlOpenXMLWorkbook (without macro's in 2007)
		# 52 = .xlsm - xlOpenXMLWorkbookMacroEnabled (with or without macro's in 2007)
		# 56 = .xls  - xlExcel8 (97-2003 format in Excel 2007)
		#
		# Probably to be incorporated as wb.SaveAs (filename, FileFormatNum)?
		# where filename is properly canonicalized with proper extension.
		# This functionality is not tried or implemented yet as there are no
		# checks if the installed Excel version can actually write the
		# desired formats; e.g., stock Excel 97 cannot write .xlsx; & Excel
		# always gives a pop-up when about to write non-native formats.
		# Moreover, in case of .csv, .wks, .txt we'll have to do something
		# about gracefully ignoring the worksheet pointer.
		# All To Be Sorted Out some time....
		unwind_protect
			xls.app.Application.DisplayAlerts = 0;
			if (xls.changed > 0)
				if (xls.changed == 2)
					# Probably a newly created, or renamed, Excel file
					printf ("Saving file %s ...\n", xls.filename);
					xls.workbook.SaveAs (canonicalize_file_name (xls.filename));
				elseif (xls.changed == 1)
					# Just updated exiting Excel file
					xls.workbook.Save ();
				endif
				xls.workbook.Close (canonicalize_file_name (xls.filename));
			endif
		unwind_protect_cleanup
			xls.app.Quit ();
			delete (xls.workbook);	# This statement actually closes the workbook
			delete (xls.app);	 	# This statement actually closes down Excel
		end_unwind_protect
		
	elseif (strcmp (xls.xtype, 'POI'))
		if (xls.changed > 0)
			if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
			xlsout = java_new ("java.io.FileOutputStream", xls.filename);
			xls.workbook.write (xlsout);
			xlsout.close ();
		endif

	elseif (strcmp (xls.xtype, 'JXL'))
		if (xls.changed > 0)
			if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
			(xls.workbook).write ();
		endif
		(xls.workbook).close ();
	
#	elseif   <other interfaces here>
		
	endif

	xls = [];

endfunction
