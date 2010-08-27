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
## @deftypefn {Function File} @var{ods} = odsopen (@var{filename})
## @deftypefnx {Function File} @var{ods} = odsopen (@var{filename}, @var{readwrite})
## @deftypefnx {Function File} @var{ods} = odsopen (@var{filename}, @var{readwrite}, @var{reqintf})
## Get a pointer to an OpenOffice_org spreadsheet in the form of return
## argument @var{ods}.
##
## Calling odsopen without specifying a return argument is fairly useless!
##
## To make this function work at all, you need the Java package > 1.2.5 plus
## ODFtoolkit (version 0.7.5 or 0.8.6) & xercesImpl, and/or jOpenDocument
## installed on your computer + proper javaclasspath set. These interfaces are
## referred to as OTK and JOD, resp., and are preferred in that order by default
## (depending on their presence).
##
## @var{filename} must be a valid .ods OpenOffice.org file name. If @var{filename}
## does not contain any directory path, the file is saved in the current
## directory.
##
## @var{readwrite} must be set to 1 if writing to spreadsheet is desired
## immediately after calling odsopen(). It merely serves proper handling
## of file errors (e.g., "file not found" or "new file created").
##
## Optional input argument @var{reqintf} can be used to override the ODS
## interface automatically selected by odsopen. Currently implemented interfaces
## are 'OTK' (Java / ODFtoolkit) or 'JOD' (Java / jOpenDocument).
##
## Examples:
##
## @example
##   ods = odsopen ('test1.ods');
##   (get a pointer for reading from spreadsheet test1.ods)
##
##   ods = odsopen ('test2.ods', [], 'JOD');
##   (as above, indicate test2.ods will be read from; in this case using
##    the jOpenDocument interface is requested)
## @end example
##
## @seealso odsclose, odsread, ods2oct, odsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Updates: 
## 2009-12-30 ....
## 2010-01-17 Make sure proper dimensions are checked in parsed javaclasspath
## 2010-01-24 Added warning when trying to create a new spreadsheet using jOpenDocument
## 2010-03-01 Removed check for rt.jar in javaclasspath
## 2010-03-04 Slight texinfo adaptation (reqd. odfdom version = 0.7.5)
## 2010-03-14 Updated help text (section on readwrite)
## 2010-06-01 Added check for jOpenDocument version + suitable warning
## 2010-06-02 Added ";" to supress debug stuff around lines 115
##      "     Moved JOD version check to subfunc getodsinterfaces
##      "     Fiddled ods.changed flag when creating a spreadsheet to avoid unnamed 1st sheets
## 2010-08-23 Added version field "odfvsn" to ods file ptr, set in getodsinterfaces() (odfdom)
##      "     Moved JOD version check to this func from subfunc getodsinterfaces()
## 2010-08-27 Improved help text
##
## Latest change on subfunction below: 2010-08-23

function [ ods ] = odsopen (filename, rw=0, reqinterface=[])

	persistent odsinterfaces; persistent chkintf;
	if (isempty (chkintf))
		odsinterfaces = struct ( "OTK", [], "JOD", [] );
		chkintf = 1;
	endif
	
	if (nargout < 1) usage ("ODS = odsopen (ODSfile, [Rw]). But no return argument specified!"); endif

	if (~isempty (reqinterface))
		# Try to invoke requested interface for this call. Check if it
		# is supported anyway by emptying the corresponding var.
		if (strcmp (tolower (reqinterface), tolower ('OTK')))
			printf ("Java/ODFtoolkit interface requested... ");
			odsinterfaces.OTK = []; odsinterfaces.JOD = 0;
		elseif (strcmp (tolower (reqinterface), tolower ('JOD')))
			printf ("Java/jOpenDocument interface requested... "); 
			odsinterfaces.OTK = 0; odsinterfaces.JOD = [];
		else
			usage (sprintf ("Unknown .ods interface \"%s\" requested. Only OTK or JOD supported", reqinterface));
		endif
		[odsinterfaces] = getodsinterfaces (odsinterfaces);

		# Well, is the requested interface supported on the system?
		if (~odsinterfaces.(toupper (reqinterface)))
			# No it aint
			error (" ...but %s is not supported.", toupper (reqinterface));
		endif
	endif
	
	# Var rw is really used to avoid creating files when wanting to read, or
	# not finding not-yet-existing files when wanting to write.

	if (rw) rw = 1; endif		# Be sure it's either 0 or 1 initially

	# Check if ODS file exists
	fid = fopen (filename, 'rb');
	if (fid < 0)
		if (~rw)
			err_str = sprintf ("File %s not found\n", filename);
			error (err_str)
		else
			printf ("Creating file %s\n", filename);
			rw = 2;
		endif
	else
		# close file anyway to avoid Java errors
		fclose (fid);
	endif

# Check for the various ODS interfaces. No problem if they've already
# been checked, getodsinterfaces (far below) just returns immediately then.

	[odsinterfaces] = getodsinterfaces (odsinterfaces);

# Supported interfaces determined; now check ODS file type.

	chk1 = strcmp (tolower (filename(end-3:end)), '.ods');
	if (~chk1)
		error ("Currently ods2oct can only read reliably from .ods files")
	endif

	ods = struct ("xtype", [], "app", [], "filename", [], "workbook", [], "changed", 0, "limits", [], "odfvsn", []);

	# Preferred interface = OTK (ODS toolkit & xerces), so it comes first. 

	if (odsinterfaces.OTK)
		# Parts after user gfterry in
		# http://www.oooforum.org/forum/viewtopic.phtml?t=69060
		odftk = 'org.odftoolkit.odfdom.doc';
		if (rw == 2)
			# New spreadsheet
			wb = java_invoke ([odftk '.OdfSpreadsheetDocument'], 'newSpreadsheetDocument');
			ods.changed = 2;
		else
			# Existing spreadsheet
			wb = java_invoke ([odftk '.OdfDocument'], 'loadDocument', filename);
		endif
		ods.workbook = wb.getContentDom ();		# Reads the entire spreadsheet
		ods.xtype = 'OTK';
		ods.app = wb;
		ods.filename = filename;
		ods.odfvsn = odsinterfaces.odfvsn;

	elseif (odsinterfaces.JOD)
		file = java_new ('java.io.File', filename);
		jopendoc = 'org.jopendocument.dom.spreadsheet.SpreadSheet';
		if (rw ==2)
			# Create an empty 2 x 2 default TableModel template
			tmodel= java_new ('javax.swing.table.DefaultTableModel', 2, 2);
			wb = java_invoke (jopendoc, 'createEmpty', tmodel);
			ods.changed = 2;
		else
			wb = java_invoke (jopendoc, 'createFromFile', file);
		endif
		ods.workbook = wb;
		ods.filename = filename;
		ods.xtype = 'JOD';
		ods.app = 'file';
		# Check jOpenDocument version
		sh = ods.workbook.getSheet (0);
		cl = sh.getCellAt (0, 0);
		try
			# 1.2b3 has public getValueType ()
			cl.getValueType ();
			ods.odfvsn = 3;
		catch
			# 1.2b2 has not
			ods.odfvsn = 2;
			printf ("NOTE: jOpenDocument v. 1.2b2 has limited functionality. Try upgrading to 1.2b3+\n");
		end_try_catch

#	elseif 
#		<other interfaces here>

	else
		warning ("No support for OpenOffice.org .ods I/O"); 
		ods = [];

	endif

	if (~isempty (reqinterface))
		# Reset all found interfaces for re-testing in the next call. Add interfaces if needed.
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
## @deftypefn {Function File} @var{odsinterfaces} = getodsinterfaces (@var{odsinterfaces})
## Get supported OpenOffice.org .ods file read/write interfaces from
## the system.
## Each interface for which the corresponding field is set to empty
## will be checked. So by manipulating the fields of input argument
## @var{odsinterfaces} it is possible to specify which
## interface(s) should be checked.
##
## Currently implemented interfaces comprise:
## - Java & ODFtoolkit (www.apache.org)
## - Java & jOpenDocument (www.jopendocument.org)
##
## Examples:
##
## @example
##   odsinterfaces = getodsinterfaces (odsinterfaces);
## @end example

## Author: Philip Nienhuis
## Created: 2009-12-27
## Updates:
## 2010-01-14
## 2010-01-17 Make sure proper dimensions are checked in parsed javaclasspath
## 2010-04-11 Introduced check on odfdom.jar version - only 0.7.5 works properly
## 2010-06-02 Moved in check on JOD version
## 2010-06-05 Experimental odfdom 0.8.5 support
## 2010-06-## dropped 0.8.5, too buggy
## 2010-08-22 Experimental odfdom 0.8.6 support
## 2010-08-23 Added odfvsn (odfdom version string) to output struct argument
##     "      Bugfix: moved JOD version check to main function (it can't work here)

function [odsinterfaces] = getodsinterfaces (odsinterfaces)

	if (isempty (odsinterfaces.OTK) && isempty (odsinterfaces.JOD))
		chk1 = 1;
		printf ("Supported interfaces: ");
	else
		chk1= 0;
	endif

	# Try Java & ODF toolkit
	if (isempty (odsinterfaces.OTK))
		odsinterfaces.OTK = 0;
		try
			tmp1 = javaclasspath;
			# If we get here, at least Java works. Now check for proper entries
			# in class path. Under *nix first the classpath must be split up.
			if (isunix) tmp1 = strsplit (char(tmp1), ":"); endif
			if (size (tmp1, 1) > size (tmp1,2)) tmp1 = tmp1'; endif
			jpchk = 0; entries = {"odfdom", "xercesImpl.jar"};
			for ii=1:size (tmp1, 2)
				tmp2 = strsplit (char (tmp1(1, ii)), "\\/");
				for jj=1:size (entries, 2)
					if (strmatch (entries{1, jj}, tmp2{size (tmp2, 2)})), ++jpchk; endif
				endfor
			endfor
			if (jpchk >= 2)		# Apparently all requested classes present.
				# Only now we can check for proper odfdom version (only 0.7.5 & 0.8.6 work OK).
				# The odfdom team deemed it necessary to change the version call so we need this:
				odfdvsn = ' ';
				try
					# New in 0.8.6
					odfvsn = java_invoke ('org.odftoolkit.odfdom.JarManifest', 'getOdfdomVersion');
				catch
					odfdvsn = java_invoke ('org.odftoolkit.odfdom.Version', 'getApplicationVersion');
				end_try_catch
				if ~(strcmp (odfvsn, '0.7.5') || strcmp (odfvsn, '0.8.6'))
					warning ("\nodfdom version %s is not supported - use v. 0.7.5 or 0.8.6.\n", odfvsn);
				else	
					odsinterfaces.OTK = 1;
					printf (" Java/ODFtoolkit (OTK) OK. ");
					chk1 = 1;
				endif
				odsinterfaces.odfvsn = odfvsn;
			else
				warning ("\n Java support OK but not all required classes (.jar) in classpath");
			endif
		catch
			# ODFtoolkit support nonexistent
		end_try_catch
	endif

	# Try Java & jOpenDocument
	if (isempty (odsinterfaces.JOD))
		odsinterfaces.JOD = 0;
		try
			tmp1 = javaclasspath;
			# If we get here, at least Java works. Now check for proper entries
			# in class path. Under unix the classpath must first be split up
			if (isunix) tmp1 = strsplit (char(tmp1), ":"); endif
			if (size (tmp1, 1) > size (tmp1,2)) tmp1 = tmp1'; endif
			jpchk = 0; entries = {"jOpenDocument"};
			for ii=1:size (tmp1, 2)
				tmp2 = strsplit (char (tmp1(1, ii)), "\\/");
				for jj=1:size (entries, 2)
					if (strmatch (entries{1, jj}, tmp2{size (tmp2, 2)})), ++jpchk; endif
				endfor
			endfor
			if (jpchk >= 1)
				odsinterfaces.JOD = 1;
				printf (" Java/jOpenDocument (JOD) OK. ");
				chk1 = 1;
			else
				warning ("\nJava support OK but required classes (.jar) not all in classpath");
			endif
		catch
			# No jOpenDocument support
		end_try_catch
	endif
	
	# ---- Other interfaces here, similar to the ones above

	if (chk1) printf ("\n"); endif
	
endfunction