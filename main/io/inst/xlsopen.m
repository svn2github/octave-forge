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
## @deftypefn {Function File} @var{xls} = xlsopen (@var{filename})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite}, @var{reqintf})
## Get a pointer to an Excel spreadsheet in the form of return argument
## @var{xls}.
##
## Calling xlsopen without specifying a return argument is fairly useless!
##
## To make this function work at all, you need MS-Excel (95 - 2003), and/or
## the Java package > 1.2.5 plus either Apache POI > 3.5 or JExcelAPI
## installed on your computer + proper javaclasspath set. These interfaces
## are referred to as COM, POI and JXL, resp., and are preferred in that
## order by default (depending on their presence).
## For OOXML support, in addition to Apache POI support you also need the
## following jars in your javaclasspath: poi-ooxml-schemas-3.5.jar,
## xbean.jar and dom4j-1.6.1.jar (or later versions).
##
## @var{filename} should be a valid .xls or xlsx Excel file name; but if you use the
## COM interface you can specify any extension that your installed Excel version
## can read AND write. If @var{filename} does not contain any directory path,
## the file is saved in the current directory.
##
## If @var{readwrite} is set to 0 (default value) or omitted, the Excel file
## is opened for reading. If @var{readwrite} is set to True or 1, an Excel
## file is opened (or created) for reading & writing.
##
## Optional input argument @var{reqintf} can be used to override the Excel
## interface automatically selected by xlsopen. Currently implemented interfaces
## are 'COM' (Excel / COM), 'POI' (Java / Apache POI) or 'JXL' (Java / JExcelAPI).
##
## Beware: Excel invocations may be left running invisibly in case of COM errors.
##
## Examples:
##
## @example
##   xls = xlsopen ('test1.xls');
##   (get a pointer for reading from spreadsheet test1.xls)
##
##   xls = xlsopen ('test2.xls', 1, 'POI');
##   (as above, indicate test2.xls will be written to; in this case using Java
##    and the Apache POI interface are requested)
## @end example
##
## @seealso xlsclose, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-29
## Last updates
## 2010-01-03 Added OOXML support
## 2010-01-10 Changed (java) interface preference order to COM->POI->JXL

function [ xls ] = xlsopen (filename, xwrite=0, reqinterface=[])

	persistent xlsinterfaces; persistent chkintf;
	if (isempty (chkintf))
		xlsinterfaces = struct ( "COM", [], "POI", [], "JXL", [] );
		chkintf = 1;
	endif
	
	if (nargout < 1) usage ("XLS = xlsopen (Xlfile, [Rw]). But no return argument specified!"); endif

	if (~isempty (reqinterface))
		# Try to invoke requested interface for this call. Check if it
		# is supported anyway by emptying the corresponding var.
		if (strcmp (tolower (reqinterface), tolower ('COM')))
			printf ("Excel/COM interface requested... ");
			xlsinterfaces.COM = []; xlsinterfaces.POI = 0; xlsinterfaces.JXL = 0;
		elseif (strcmp (tolower (reqinterface), tolower ('POI')))
			printf ("Java/Apache POI interface requested... ");
			xlsinterfaces.COM = 0; xlsinterfaces.POI = []; xlsinterfaces.JXL = 0;
		elseif (strcmp (tolower (reqinterface), tolower ('JXL')))
			printf ("Java/JExcelAPI interface requested... "); 
			xlsinterfaces.COM = 0; xlsinterfaces.POI = 0; xlsinterfaces.JXL = [];
		else
			usage (sprintf ("Unknown .xls interface \"%s\" requested. Only COM, POI or JXL supported", reqinterface));
		endif
		xlsinterfaces = getxlsinterfaces (xlsinterfaces);
		# Well, is the requested interface supported on the system?
		if (~xlsinterfaces.(toupper (reqinterface)))
			# No it aint
			error (" ...but that's not supported!");
		endif
	endif
	
	# Var xwrite is really used to avoid creating files when wanting to read, or
	# not finding not-yet-existing files when wanting to write.
	
	if (xwrite) xwrite = 1; endif		# Be sure it's either 0 or 1 initially

	# Check if Excel file exists
	fid = fopen (filename, 'rb');
	if (fid < 0)
		if (~xwrite)
			err_str = sprintf ("File %s not found\n", filename);
			error (err_str)
		else
			printf ("Creating file %s\n", filename);
			xwrite = 2;
		endif
	else
		# close file anyway to avoid COM or Java errors
		fclose (fid);
	endif
	
# Check for the various Excel interfaces. No problem if they've already
# been checked, getxlsinterfaces (far below) just returns immediately then.

	xlsinterfaces = getxlsinterfaces (xlsinterfaces);

# Supported interfaces determined; Excel file type check moved to seperate interfaces.
	chk1 = strcmp (tolower (filename(end-3:end)), '.xls');
	chk2 = strcmp (tolower (filename(end-4:end-1)), '.xls');
	
	xls = struct ("xtype", 'NONE', "app", [], "filename", [], "workbook", [], "changed", 0, "limits", []); 
	
	# Interface preference order is defined below: currently COM -> POI -> JXL
	
	if (xlsinterfaces.COM)
		# Excel functioning has been tested above & file exists, so we just invoke it
		xls.xtype = 'COM';
		app = actxserver ("Excel.Application");
		xls.app = app;
		if (xwrite < 2)
			# Open workbook
			wb = app.Workbooks.Open (canonicalize_file_name (filename));
		elseif (xwrite == 2)
			# Create a new workbook
			wb = app.Workbooks.Add ();
		endif
		xls.workbook = wb;
		xls.filename = filename;
	
	elseif (xlsinterfaces.POI)
		if ~(chk1 || chk2)
			error ("Unsupported file format for xls2oct / Apache POI.")
		endif
		xls.xtype = 'POI';
		# Get handle to workbook
		if (xwrite == 2)
			if (chk1)
				wb = java_new ('org.apache.poi.hssf.usermodel.HSSFWorkbook');
			elseif (chk2)
				wb = java_new ('org.apache.poi.xssf.usermodel.XSSFWorkbook');
			endif
			xls.app = 'new_POI'
		else
			try
				xlsin = java_new ('java.io.FileInputStream', filename);
				wb = java_invoke ('org.apache.poi.ss.usermodel.WorkbookFactory', 'create', xlsin);
				xls.app = xlsin;
			catch
				error ("File format not supported");
			end_try_catch
		endif
		xls.workbook = wb;
		xls.filename = filename;
		
	elseif (xlsinterfaces.JXL)
		if (~chk1)
			error ("Currently xls2oct / JXL can only read reliably from .xls files")
		endif
		xls.xtype = 'JXL';
		xlsin = java_new ('java.io.File', filename);
		if (xwrite == 2)
			# Get handle to new xls-file
			wb = java_invoke ('jxl.Workbook', 'createWorkbook', xlsin);
		else
			# Open existing file
			wb = java_invoke ('jxl.Workbook', 'getWorkbook', xlsin);
		endif
		xls.app = xlsin;
		xls.workbook = wb;
		xls.filename = filename;

		# 	elseif ---- other interfaces

	else
		warning ("No support for Excel .xls I/O"); 
	endif

	if (~isempty (xls))
		# From here on xwrite is tracked via xls struct in the various lower
		# level r/w routines and it is only used to determine if an informative
		# message is to be given when saving a newly created xls file.
	
		xls.changed = xwrite;

		# Until something was written to existing files we keep status "unchanged".
		# xls.changed = 0 (existing/only read from), 1 (existing/data added), 2 (new).

		if (xls.changed == 1) xls.changed = 0; endif
		
	endif
	
# Rounding up. If none of the xlsinterfaces is supported we're out of luck.
	
	if (~isempty (reqinterface))
		# Reset found interfaces for re-testing in the next call. Add interfaces if needed.
		chkintf = [];
	endif
	
endfunction


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
## @deftypefn {Function File} @var{xlsinterfaces} = getxlsinterfaces (@var{xlsinterfaces})
## Get supported Excel .xls file read/write interfaces from the system.
## Each interface for which the corresponding field is set to empty
## will be checked. So by manipulating the fields of input argument
## @var{xlsinterfaces} it is possible to specify which
## interface(s) should be checked.
##
## Currently implemented interfaces comprise:
## - ActiveX / COM (native Excel in the background)
## - Java & Apache POI
## - Java & JExcelAPI
##
## Examples:
##
## @example
##   xlsinterfaces = getxlsinterfaces (xlsinterfaces);
## @end example

## Author: Philip Nienhuis
## Created: 2009-11-29
## Last updated 2009-12-27

function [xlsinterfaces] = getxlsinterfaces (xlsinterfaces)

	if (isempty (xlsinterfaces.COM) && isempty (xlsinterfaces.POI) && isempty (xlsinterfaces.JXL))
		chk1 = 1;
		printf ("Supported interfaces: ");
	else
		chk1= 0;
	endif

	# Check if MS-Excel COM ActiveX server runs
	if (isempty (xlsinterfaces.COM))
		xlsinterfaces.COM = 0;
		try
			app = actxserver ("Excel.application");
			# If we get here, the call succeeded & COM works.
			xlsinterfaces.COM = 1;
			# Close Excel
			app.Quit();
			delete(app);
			printf (" Excel (COM) OK. ");
			chk1 = 1;
		catch
			# COM non-existent
		end_try_catch
	endif

	# Try Java & Apache POI
	if (isempty (xlsinterfaces.POI))
		xlsinterfaces.POI = 0;
		try
			tmp1 = javaclasspath;
			# If we get here, at least Java works. Now check for proper entries
			# in class path. Under *nix the classpath must first be split up
			if (isunix) tmp1 = strsplit (char(tmp1), ":"); endif
			# Check basic .xls (BIFF8) support
			jpchk1 = 0; entries1 = {"rt.jar", "poi-3", "poi-ooxml"};
			for ii=1:size (tmp1, 2)
				tmp2 = strsplit (char (tmp1(1, ii)), "\\/");
				for jj=1:size (entries1, 2)
					if (strmatch (entries1{1, jj}, tmp2{size (tmp2, 2)})), ++jpchk1; endif
				endfor
			endfor
			if (jpchk1 > 2)
				xlsinterfaces.POI = 1;
				printf (" Java/Apache (POI) OK. ");
				chk1 = 1;
			else
				warning ("\n Java support OK but not all required classes (.jar) in classpath");
			endif
			# OOXML extras
			jpchk2 = 0; entries2 = {"xbean.jar", "poi-ooxml-schemas", "dom4j"};
			for ii=1:size (tmp1, 2)
				tmp2 = strsplit (char (tmp1(1, ii)), "\\/");
				for jj=1:size (entries2, 2)
					if (strmatch (entries2{1, jj}, tmp2{size (tmp2, 2)})), ++jpchk2; endif
				endfor
			endfor
			if (jpchk2 > 2) printf ("(& OOXML OK)  "); endif
		catch
			# POI non-existent
		end_try_catch
	endif

	# Try Java & JExcelAPI
	if (isempty (xlsinterfaces.JXL))
		xlsinterfaces.JXL = 0;
		try
			tmp1 = javaclasspath;
			# If we get here, at least Java works. Now check for proper entries
			# in class path. Under unix the classpath must first be split up
			if (isunix) tmp1 = strsplit (char(tmp1), ":"); endif
			jpchk = 0; entries = {"rt.jar", "jxl.jar"};
			for ii=1:size (tmp1, 2)
				tmp2 = strsplit (char (tmp1(1, ii)), "\\/");
				for jj=1:size (entries, 2)
					if (strmatch (entries{1, jj}, tmp2{size (tmp2, 2)})), ++jpchk; endif
				endfor
			endfor
			if (jpchk > 1)
				xlsinterfaces.JXL = 1;
				printf (" Java/JExcelAPI (JXL) OK. ");
				chk1 = 1;
			else
				warning ("\nJava support OK but required classes (.jar) not all in classpath");
			endif
		catch
			# JXL non-existent
		end_try_catch
	endif
	
	# ---- Other interfaces here, similar to the ones above

	if (chk1) printf ("\n"); endif
	
endfunction