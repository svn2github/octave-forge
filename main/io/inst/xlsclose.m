## Copyright (C) 2009,2010 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefnx {Function File} [@var{xls}] = xlsclose (@var{xls}, @var{filename})
## Close the Excel spreadsheet pointed to in struct @var{xls}, if needed
## write the file to disk. Based on information contained in @var{xls},
## xlsclose will determine if the file should be written to disk.
##
## If no errors occured during writing, the xls file pointer struct will be
## reset and -if COM interface was used- ActiveX/Excel will be closed.
## However if errors occurred, the file pinter will be ontouched so you can
## clean up before a next try with xlsclose().
## Be warned that until xlsopen is called again with the same @var{xls} pointer
## struct and @var{_keepxls_} omitted or set to false, hidden Excel or Java
## applications with associated (possibly large) memory chunks are kept alive
## taking up resources.
##
## @var{filename} can be used to write changed spreadsheet files to
## an other file than opened with xlsopen(); unfortunately this doesn't work
## with JXL (JExcelAPI) interface.
##
## You need MS-Excel (95 - 2010), and/or the Java package > 1.2.6 plus Apache
## POI > 3.5 and/or JExcelAPI installed on your computer + proper
## javaclasspath set, to make this function work at all.
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
## @seealso xlsopen, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-29
## Updates: 
## 2010-01-03 (checked OOXML support)
## 2010-08-25 See also: xlsopen (instead of xlsclose)
## 2010-10-20 Improved tracking of file changes and need to write it to disk
## 2010-10-27 Various changes to catch errors when writing to disk;
##     "      Added input arg "keepxls" for use with xlswrite.m to save the
##     "      untouched file ptr struct in case of errors rather than wipe it
## 2010-11-12 Replaced 'keepxls' by new filename arg; catch write errors and
##            always keep file pointer in case of write errors

function [ xls ] = xlsclose (xls, filename=[])

	if (~isempty (filename))
		if (ischar (filename))
			if (xls.changed == 0)
				warning ("File %s wasn't changed, new filename ignored.", filename);
			else
				if (strcmp (xls.xtype, 'JXL'))
					warning ("JXL doesn't support changing filename, new filename ignored.");
				elseif ~(strcmp (xls.xtype, 'COM') || strmatch ('.xls', filename))
					# Excel / ActiveX will write any filename extension
					error ('No .xls or .xlsx filename extension specified');
				else
					### For multi-user environments, uncomment below AND relevant stanza in xlsopen
					# In case of COM, be sure to first close the open workbook
					#if (strcmp (xls.xtype, ÇOM'))
					#	xls.app.Application.DisplayAlerts = 0;
					#	xls.workbook.close();
					#	xls.app.Application.DisplayAlerts = 0;
					#endif
					xls.filename = filename;
				endif
			endif
		endif
	endif

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
		# (see Excel Help, VB reference, Enumerations, xlFileType)
		
		# xls.changed = 0: no changes: just close;
		#               1: existing file with changes: save, close.
		#               2: new file with data added: save, close
		#               3: new file, no added added (empty): close & delete on disk

		xls.app.Application.DisplayAlerts = 0;
		try
			if (xls.changed > 0 && xls.changed < 3)
				if (xls.changed == 2)
					# Probably a newly created, or renamed, Excel file
					printf ("Saving file %s ...\n", xls.filename);
					xls.workbook.SaveAs (canonicalize_file_name (xls.filename));
				elseif (xls.changed == 1)
					# Just updated existing Excel file
					xls.workbook.Save ();
				endif
				xls.changed = 0;
				xls.workbook.Close (canonicalize_file_name (xls.filename));
			endif
			xls.app.Quit ();
			delete (xls.workbook);	# This statement actually closes the workbook
			delete (xls.app);	 	# This statement actually closes down Excel
		catch
			xls.app.Application.DisplayAlerts = 1;
		end_try_catch
		
	elseif (strcmp (xls.xtype, 'POI'))
		if (xls.changed > 0 && xls.changed < 3)
			try
				xlsout = java_new ("java.io.FileOutputStream", xls.filename);
				if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
				xls.workbook.write (xlsout);
				xlsout.close ();
				xls.changed = 0;
			catch
#				xlsout.close ();
			end_try_catch
		endif

	elseif (strcmp (xls.xtype, 'JXL'))
		if (xls.changed > 0 && xls.changed < 3)
			try
				if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
				xls.workbook.write ();
				xls.workbook.close ();
				if (xls.changed == 3)
					# Upon entering write mode, JExcelAPI always makes a disk file
					# Incomplete new files (no data added) had better be deleted.
					xls.workbook.close ();
					delete (xls.filename); 
				endif
				xls.changed = 0;
			catch
			end_try_catch
		endif

#	elseif   <other interfaces here>
		
	endif

	if (xls.changed)
		warning (sprintf ("File %s could not be saved. Read-only or in use elsewhere?\nFile pointer preserved.", xls.filename));
	else
		xls = [];
	endif

endfunction
